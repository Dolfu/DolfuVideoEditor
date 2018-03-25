//
//  DolfuFrameSliderLayer.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 19..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit

public class DolfuFrameSliderTrackLayer: CALayer {
    weak var frameSlider: DolfuFrameSlider?
    
    override public func draw(in cgContext: CGContext) {
        guard let slider = frameSlider else {
            return
        }
        
        let boundsWidth = Double(bounds.width)
        let boundsHeight = Double(bounds.height)
        
        let lowValuePosition = Double(slider.positionForValue(slider.lowValue))
        let highValuePosition = Double(slider.positionForValue(slider.highValue))
        
        // 재생영역으로 선택한 구간 표현
        cgContext.setFillColor(UIColor.clear.cgColor)
        let rectHighlight = CGRect(x: lowValuePosition, y: 0.0, width: highValuePosition - lowValuePosition, height: boundsHeight)
        cgContext.fill(rectHighlight)
        
        // 비재생 영역의 왼쪽영역
        cgContext.setFillColor(UIColor.black.cgColor)
        cgContext.setAlpha(0.7)
        let rectLeftNoneHighlight = CGRect(x: 0, y: 0, width: lowValuePosition, height: boundsHeight)
        cgContext.fill(rectLeftNoneHighlight)
        
        // 비재생 영역의 오른쪽 영역
        cgContext.setFillColor(UIColor.black.cgColor)
        cgContext.setAlpha(0.7)
        let rectRightNoneHighlight = CGRect(x: highValuePosition, y: 0, width: boundsWidth - highValuePosition, height: boundsHeight)
        cgContext.fill(rectRightNoneHighlight)
        
        // 재생영역 상단부 라인
        cgContext.setFillColor(UIColor.orange.cgColor)
        cgContext.setAlpha(1)
        let rectHighlightTopBar = CGRect(x: lowValuePosition, y: 0, width: highValuePosition - lowValuePosition, height: 2)
        cgContext.fill(rectHighlightTopBar)
        
        // 재생영역 하단부 라인
        cgContext.setFillColor(UIColor.orange.cgColor)
        let rectHighlightBottomBar = CGRect(x: lowValuePosition, y: boundsHeight - 2, width: highValuePosition - lowValuePosition, height: 2)
        cgContext.fill(rectHighlightBottomBar)
        
        // 현재 재생영역 표기
        let nowPlayPostion = CGFloat(slider.positionForValue(slider.nowPlayValue))
        cgContext.setFillColor(UIColor.white.cgColor)
        let rectNowPlayStatusBar = CGRect(x: nowPlayPostion - 1, y: 0, width: 2, height: bounds.height)
        cgContext.fill(rectNowPlayStatusBar)
    }
}
