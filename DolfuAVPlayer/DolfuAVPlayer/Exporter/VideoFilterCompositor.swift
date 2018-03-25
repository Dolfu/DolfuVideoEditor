//
//  VideoFilterCompositor.swift
//  DolfuAVPlayer
//
//  Created by 김효빈 on 2018. 3. 21..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import Foundation
import AVKit

/**
 필터 렌더링 관련 커스터마이징 Compositor
 AVFoundation은 AVVideoComposition내 정의한 instruction의 처리를 위해 현재 VideoFilterCompositor(AVVideoCompositing)의 인스턴스를 사용.
 현재의 경우 instruction은 VideoFilterCompositionInstruction 이다.
 
 - 발취: [Apple](https://developer.apple.com/documentation/avfoundation/avvideocompositing)
 - 원본: [jojodmo/VideoFilterExporter](https://github.com/jojodmo/VideoFilterExporter.git)
*/
class VideoFilterCompositor:NSObject, AVVideoCompositing {
    
    /// kCVPixelBufferPixelFormatTypeKey : 나중에 값 변경가능
    var requiredPixelBufferAttributesForRenderContext: [String : Any] = [
        kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32),
        kCVPixelBufferOpenGLESCompatibilityKey as String : NSNumber(value: true),
        kCVPixelBufferOpenGLCompatibilityKey as String : NSNumber(value: true)
    ]
    
    // You may alter the value of kCVPixelBufferPixelFormatTypeKey to fit your needs
    var sourcePixelBufferAttributes: [String : Any]? = [
        kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32),
        kCVPixelBufferOpenGLESCompatibilityKey as String : NSNumber(value: true),
        kCVPixelBufferOpenGLCompatibilityKey as String : NSNumber(value: true)
    ]
    
    let renderQueue = DispatchQueue(label: "dolfu.renderingqueue", attributes: [])
    let renderContextQueue = DispatchQueue(label: "dolfu.rendercontextqueue", attributes: [])
    
    var renderContext: AVVideoCompositionRenderContext!
    override init(){
        super.init()
    }
    
    func startRequest(_ request: AVAsynchronousVideoCompositionRequest){
        autoreleasepool(){
            self.renderQueue.sync{
                /// 생성된 VideoFilterCompositionInstruction 가져옴. VideoFilterCompositionInstruction내 포함된 필터목록 불러오기 위함.
                guard let instruction = request.videoCompositionInstruction as? VideoFilterCompositionInstruction else{
                    request.finish(with: NSError(domain: "dolfu.videoEditor", code: 760, userInfo: nil))
                    return
                }
                
                /// track의 frame얻어옴. 얻어온 frame의 pixel값을 이용하여 아래에서 filter삽입을 위한 ciimage 생성.
                guard let pixels = request.sourceFrame(byTrackID: instruction.trackID) else{
                    request.finish(with: NSError(domain: "dolfu.videoEditor", code: 761, userInfo: nil))
                    return
                }
                
                /// VideoFilterCompositionInstruction 객체 생성시 추가한 filter처리.
                ///
                var image = CIImage(cvPixelBuffer: pixels)
                for filter in instruction.filters{
                    filter.setValue(image, forKey: kCIInputImageKey)
                    image = filter.outputImage ?? image
                }
                
                /// 동영상내 위에서 만든 필터가 삽입된 이미지를 추가하기위해 CVPixelBuffer생성.
                let newBuffer: CVPixelBuffer? = self.renderContext.newPixelBuffer()
                
                /// 생성한 CVPixelBuffer에 이미지를 넣고, 동영상의 컨텍스트내에 추가하여 렌더링.
                if let buffer = newBuffer{
                    instruction.context.render(image, to: buffer)
                    request.finish(withComposedVideoFrame: buffer)
                }
                else{
                    request.finish(withComposedVideoFrame: pixels)
                }
            }
        }
    }
    
    /// Context 변경된 경우.
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext){
        self.renderContextQueue.sync{
            self.renderContext = newRenderContext
        }
    }

}
