//
//  DolfuAVPlayerView.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 20..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit
import AVKit
import DolfuUtils
import GLKit

/// Video 재생 및 편집을 위한 View
public class DolfuAVPlayerView: UIView {
    //var indicatorView:NVActivityIndicatorView!

    /// 원본 파일 Asset
    private var originAVAsset:AVAsset? = nil
    
    /// 편집에 사용되는 Asset
    private var editingAVAsset:AVAsset? = nil
    
    /// 동영상 재생 AVPlayer
    private var avPlayer:AVPlayer! = nil
    
    /// AVPlayer의 Layer
    private var avPlayerLayer:AVPlayerLayer! = nil
    
    /// 총재생시간(초)
    private var totalSeconds:CGFloat! = 0//private var thumbtimeSeconds:CGFloat!
    
    /// 현재 View의 Delegate
    public var delegate:DolfuAVPlayerViewDelegate?
    
    var videoPlaybackPosition: CGFloat = 0.0
    
    /// 현재 적용된 필터
    /// nil인경우 필터 적용이 안된상태
    var applyFilter:CIFilter? = nil
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// avplayer 의 원본 asset set
    public func setAVAsset(avAsset:AVAsset){
        self.originAVAsset = avAsset.copy() as? AVAsset
        self.editingAVAsset = avAsset.copy() as? AVAsset
        
        setAVPlayer()
    }
    
    /// avplayer set
    private func setAVPlayer(){
        totalSeconds = CGFloat(CMTimeGetSeconds((editingAVAsset?.duration)!))
        
        avPlayer = AVPlayer(playerItem: AVPlayerItem(asset: editingAVAsset!))
        avPlayer.rate = 1
        
        self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
        self.avPlayerLayer.frame = self.bounds
        self.avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        self.layer.addSublayer(self.avPlayerLayer)
        
        self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        self.avPlayer.addPeriodicTimeObserver(forInterval: CMTime(value:1, timescale:10), queue: DispatchQueue.main) { (progressTime) in
            self.delegate?.changedNowPlaySeconds!(seconds: CMTimeGetSeconds(progressTime))
        }
    }
    
    /// 편집전 원본 AVAsset GET
    public func getOriginAVAsset() -> AVAsset{
        return originAVAsset!
    }
    
    /// 필터 추가
    public func setNewFilter(ciFilter:CIFilter?){
        if ciFilter != nil {
            /// videocomposition 생성 및 비디오 소스에 필터 삽입
            let videoComposition = AVMutableVideoComposition(asset: editingAVAsset!, applyingCIFiltersWithHandler: { request in
                let source = request.sourceImage.clampedToExtent()
                ciFilter?.setValue(source, forKey: kCIInputImageKey)
                let output = ciFilter?.outputImage!.cropped(to: request.sourceImage.extent)
                request.finish(with: output!, context: nil)
            })
            
            replaceNewAVPlayerItemWithVideoComposition(videoComposition: videoComposition)
            applyFilter = ciFilter
        }else {
            replaceNewAVPlayerItemWithVideoComposition(videoComposition: nil)
            applyFilter = nil
        }
    }
    
    /// 필터 제거
    public func removeFilterFromAVPlayerItem(){
        replaceNewAVPlayerItemWithVideoComposition(videoComposition: nil)
        applyFilter = nil
    }
    
    /// avplayer의 currentitem 교체
    func replaceNewAVPlayerItemWithVideoComposition(videoComposition:AVVideoComposition?){
        DispatchQueue.main.async {
            self.doPauseAtAVPlayer()
            //기존 재생중인 시간값 저장
            let currentPlayTime = self.avPlayer.currentItem?.currentTime()
            
            // 새 playeritem 생성
            let newPlayerItem = AVPlayerItem(asset: self.editingAVAsset!)
            
            if videoComposition != nil {
                newPlayerItem.videoComposition = videoComposition!
            }
            
            //새로운 playeritem으로 교체
            self.avPlayer.replaceCurrentItem(with: nil)
            self.avPlayer.replaceCurrentItem(with: newPlayerItem)
            
            /// 기존 재생 시간 적용
            self.avPlayer.currentItem?.seek(to: currentPlayTime!, completionHandler: nil)
            
            self.doPlayingAtAVPlayer()
        }
    }
    
    
    /// 현재 필터 반환
    public func getNowFilter() -> CIFilter? {
        return applyFilter
    }
    
    /// 현재 필터이름 반환
    public func getNowFilterName() -> String {
        if applyFilter == nil {
            return ""
        }else {
            return (applyFilter?.name)!
        }
    }
    
    /// 플레이어를 재생
    public func doPlayingAtAVPlayer(){
        guard avPlayer == nil else {
            self.avPlayer.play()
            delegate?.changedPlayStatus!(isNowPlaying: true)
            return
        }
    }
    
    /// 플레이어를 정지
    public func doPauseAtAVPlayer(){
        guard avPlayer == nil else {
            self.avPlayer.pause()
            delegate?.changedPlayStatus!(isNowPlaying: false)
            return
        }
    }
    
    /**
     플레이어의 재생상태 전환
     */
    public func doChangePlayingStatus(){
        if avPlayer.isNowPlaying {
            doPauseAtAVPlayer()
        }else{
            doPlayingAtAVPlayer()
        }
    }
    
    public func getTotalSeconds() -> CGFloat{
        return totalSeconds
    }
    
    /// 비디오 재생부 set
    public func seekVideo(toPos position: CGFloat) {
        self.videoPlaybackPosition = position
        let time: CMTime = CMTimeMakeWithSeconds(Float64(self.videoPlaybackPosition), self.avPlayer.currentTime().timescale)
        self.avPlayer.currentItem?.seek(to: time, completionHandler: nil)
    }
}

extension AVPlayer {
    var isNowPlaying: Bool {
        return rate != 0 && error == nil
    }
}



