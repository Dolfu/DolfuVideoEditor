//
//  DolfuFrameSliderThumbLayer.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 19..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit

public class DolfuFrameSliderThumbLayer:CALayer{
    
    /// 필터가 현재 선택된 상태인지
    var highlighted: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// lay draw
    /// 필터가 현재 선택된 상태인지(highlighted) 에따라 다르게 보여줌
    override public func draw(in cgContext: CGContext) {
        
        if highlighted {
            let thumbPath = UIBezierPath(roundedRect: bounds, cornerRadius: 0)
            cgContext.setFillColor(UIColor.yellow.cgColor)
            cgContext.addPath(thumbPath.cgPath)
            cgContext.fillPath()
        } else {
            cgContext.setFillColor(UIColor.orange.cgColor)
            cgContext.fill(bounds)
        }
    }
}
