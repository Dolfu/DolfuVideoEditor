//
//  VideoFilterExport.swift
//  DolfuAVPlayer
//
//  Created by 김효빈 on 2018. 3. 21..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import GLKit
import DolfuUtils

/**
 비디오내 필터삽입 및 Export를 위한 클래스
 - 원본: [jojodmo/VideoFilterExporter](https://github.com/jojodmo/VideoFilterExporter.git)
 */
public class VideoFilterExport{
    let avAsset: AVAsset
    var filters: [CIFilter]
    let context: CIContext
    
    var cropTimeRange:CMTimeRange
    
    init(asset: AVAsset, filters: [CIFilter], cropTimeRange:CMTimeRange, context: CIContext){
        self.avAsset = asset
        self.filters = filters
        self.cropTimeRange = cropTimeRange
        self.context = context
    }
    
    public convenience init(asset: AVAsset, filters: [CIFilter], cropTimeRange:CMTimeRange){
        let eagl = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        let context = CIContext(eaglContext: eagl!, options: [kCIContextWorkingColorSpace : NSNull()])
        
        self.init(asset: asset, filters: filters, cropTimeRange:cropTimeRange, context: context)
    }
    
    public func export(outputURL url: URL, callback: @escaping (_ url: URL?) -> Void){
        /// 전체 재생시간만큼 timerange생성
        let fullTimeRange:CMTimeRange = CMTimeRangeMake(kCMTimeZero, self.avAsset.duration)
        
        /// asset track 가져옴.
        guard let track: AVAssetTrack = self.avAsset.tracks(withMediaType: AVMediaType.video).first else{callback(nil); return}
        
        /// 원본 asset의 orientation 가져옴
        let orientation = UtilAsset.getOrientationOfAVAssetTrack(videoTrack: track)
        
        /// composition 생성. 최종적으로 Export시 사용되는 asset
        let composition = AVMutableComposition()
        
        /// 트랙의 크기를 가져와 composition의 크기 설정. portrait 영상인 경우 export시 회전되어버리는 현상 관련 처음 composition의 크기를 portrait하게 설정.
        if(orientation.isLandscape) {
            composition.naturalSize = track.naturalSize
        } else {
            composition.naturalSize = CGSize(width: track.naturalSize.height, height: track.naturalSize.width)
        }
        
        /// composition에 videotrack, audiotrack 생성
        let videoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        /// 생성한 videotrack에 원본 asset의 video 삽입
        do{try videoTrack?.insertTimeRange(fullTimeRange, of: track, at: kCMTimeZero)}
        catch _{callback(nil); return}
        
        /// 생성한 audioTrack에 원본 asset의 audio 삽입.
        if let audio = self.avAsset.tracks(withMediaType: AVMediaType.audio).first{
            do{try audioTrack?.insertTimeRange(fullTimeRange, of: audio, at: kCMTimeZero)}
            catch _{callback(nil); return}
        }
        
        /// videotrack으로 부터 composition의 트랙을 수정하기위한 layer instruction 개체 생성.
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack!)
        
        /// 트랙 ID 설정
        layerInstruction.trackID = (videoTrack?.trackID)!
        
        /// orientation에 따른 CIAffineTransform 필터를 추가(composition영역에 layer가 오도록 맞춤)
        if orientation != .landscapeLeft {
            self.filters.append(getCIAffinTransformFilterFromAssetOrientation(orientation: orientation, trackNaturalSize: track.naturalSize)!)
        }
        
        /// 필터 추가를 위한 VideoFilterCompositionInstruction 개체 생성.
        /// instruction 개체 내 트랙ID, 필터목록 삽입. compositor에 의해 렌더링될때에 각프레임에 추가됨.
        let instruction = VideoFilterCompositionInstruction(trackID: (videoTrack?.trackID)!, filters: self.filters, context: self.context)
        
        /// instruction 개체에 timeRange 설정
        instruction.timeRange = fullTimeRange
        
        /// instruction 개체에 layer instruction 설정.
        instruction.layerInstructions = [layerInstruction]
        
        /// videocomposition 개체 생성. 최종적으로 export할때의 videocomposition.
        let videoComposition = AVMutableVideoComposition()
        
        /// videocomposition 개채의 custom compositor class 설정.
        /// videocomposition의 compositor는 videocomposition이 export시 video compose 과정에서 사용자정의 수정항목(현재의 경우 필터)을 compose 하도록 수행.
        videoComposition.customVideoCompositorClass = VideoFilterCompositor.self
        
        /// videocomposition 개체의 frame duration 설정.
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        /// videocomposition 개체가 렌더링될 크기 설정. composition과 동일하게 videocomposition의 렌더링 영역을 orientation에 맞게 설정.
        if orientation.isLandscape {
            videoComposition.renderSize = (videoTrack?.naturalSize)!
        } else {
            videoComposition.renderSize = CGSize(width: (videoTrack?.naturalSize.height)!, height: (videoTrack?.naturalSize.width)!)
        }
        
        /// videocomposition 개체의 instructions 설정.
        videoComposition.instructions = [instruction]
        
        /// export session 생성. 원본이될 composition, 화질 설정
        let session: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        
        /// 위에서 생성한 videocomposition 개체를 session에 담음
        session.videoComposition = videoComposition
        
        /// export시 내보내질 url 설정
        session.outputURL = url
        
        /// export시 내보내질 파일 타입 설정
        session.outputFileType = AVFileType.mp4
        
        /// export시 내보내질 timeRange설정. 특정재생영역 추출을 위해 cropTimeRange를 timerange로 설정.
        session.timeRange = cropTimeRange
        
        /// export session 수행
        session.exportAsynchronously(){
            DispatchQueue.main.async{
                callback(url)
            }
        }
    }
    
    /// orientation에 따른 CIAffineTransform 필터를 가져옴(composition영역에 layer가 오도록 맞춤)
    func getCIAffinTransformFilterFromAssetOrientation(orientation:UIInterfaceOrientation, trackNaturalSize:CGSize) -> (CIFilter?){
        
        let extent = CGRect(x: 0, y: 0, width: trackNaturalSize.width, height: trackNaturalSize.height)
        
        if orientation == .portrait {
            /// portrait인 경우
            let degrees = 270
            let angle:CGFloat = (CGFloat(degrees) / 90.0) * CGFloat(Double.pi / 2)
            var tx = CGAffineTransform(translationX: 0, y: extent.width)
            tx = tx.rotated(by: angle)
            let transformFilter = CIFilter(name: "CIAffineTransform")!
            transformFilter.setDefaults()
            transformFilter.setValue(tx, forKey: kCIInputTransformKey)
            return transformFilter
        } else if orientation == .portraitUpsideDown {
            /// portraitUpsideDown인 경우
            let degrees = 90
            let angle:CGFloat = (CGFloat(degrees) / 90.0) * CGFloat(Double.pi / 2)
            var tx = CGAffineTransform(translationX: extent.height, y: 0)
            tx = tx.rotated(by: angle)
            let transformFilter = CIFilter(name: "CIAffineTransform")!
            transformFilter.setDefaults()
            transformFilter.setValue(tx, forKey: kCIInputTransformKey)
            return transformFilter
        } else if orientation == .landscapeRight {
            /// landscapeRight인 경우
            let degrees = 180
            let angle:CGFloat = (CGFloat(degrees) / 90.0) * CGFloat(Double.pi / 2)
            var tx = CGAffineTransform(translationX: extent.width, y: extent.height)
            tx = tx.rotated(by: angle)
            let transformFilter = CIFilter(name: "CIAffineTransform")!
            transformFilter.setDefaults()
            transformFilter.setValue(tx, forKey: kCIInputTransformKey)
            return transformFilter
        } else {
            return nil
        }
    }
}

