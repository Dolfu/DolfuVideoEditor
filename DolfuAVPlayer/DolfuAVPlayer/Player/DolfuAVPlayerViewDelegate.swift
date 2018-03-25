//
//  DolfuAVPlayerTimeObserverProtocol.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 21..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import Foundation

/// DolfuAVPlayerView의 이벤트 Delegate
@objc public protocol DolfuAVPlayerViewDelegate {
    
    /// 현재 재생중인 부분의 변경시
    @objc optional func changedNowPlaySeconds(seconds:Float64)
    
    /// Player의 재생상태 변경시
    @objc optional func changedPlayStatus(isNowPlaying:Bool)
}

