//
//  VideoFilterExporter.swift
//  DolfuAVPlayer
//
//  Created by 김효빈 on 2018. 3. 21..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import Foundation
import AVKit

/**
 compositor에 의해 수행되는 instruction. 필터 삽입을 위한 커스터마이징 클래스
 이 클래스 생성시 필터목록과, 필터가 삽입될 트랙ID 를 삽입.
 생성된 VideoFilterCompositionInstruction 개체는 VideoFilterCompositor에서 필터 렌더링시 CIContext에 추가하여 사용.
 - 원본: [jojodmo/VideoFilterExporter](https://github.com/jojodmo/VideoFilterExporter.git)
 */
class VideoFilterCompositionInstruction:AVMutableVideoCompositionInstruction{
    let trackID:CMPersistentTrackID
    let filters:[CIFilter]
    let context:CIContext
    
    override var requiredSourceTrackIDs: [NSValue]{
        get {
            return [NSNumber(value:Int(self.trackID))]
        }
    }
    
    /**
     중복처리 방지
     - 참고 : [containsTweening]: (https://developer.apple.com/documentation/avfoundation/avvideocompositioninstructionprotocol/1389376-containstweening)
     */
    override var containsTweening: Bool{
        get{
            return false
        }
    }
    
    init(trackID:CMPersistentTrackID, filters:[CIFilter], context:CIContext) {
        self.trackID = trackID
        self.filters = filters
        self.context = context
        
        super.init()
        
        /// 필터 추가됨에 따른 후처리 필요여부 => true 설정.
        self.enablePostProcessing = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
