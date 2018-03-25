//
//  DolfuFrameSlider.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 18..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit

/// Player의 프레임 이동을 위한 Slider
public class DolfuFrameSlider: UIControl {
    /// DolfuFrameSlider의 background가 되는 전체 track의 layer
    fileprivate let trackLayer = DolfuFrameSliderTrackLayer()
    
    /// DolfuFrameSlider의 출력 영역 시작부분 설정 layer
    fileprivate let lowThumbLayer = DolfuFrameSliderThumbLayer()
    
    /// DolfuFrameSlider의 출력 영역 끝부분 설정 layer
    fileprivate let highThumbLayer = DolfuFrameSliderThumbLayer()
    
    /// 시작/끝 설정 layer의 크기
    fileprivate var thumbWidth: CGFloat = 12
    
    /// tracking 시작시 기존지점 저장 변수
    fileprivate var previouslocation = CGPoint()
    
    /// 시작 layer 영역의 사용자 touch 여부
    @IBInspectable public var lowLayerIsSelected = Bool()
    
    /// track의 최소값
    @IBInspectable public var minValue: Double = 0.0 {
        willSet(newValue) {
            assert(newValue < maxValue, "must minValue < maxValue")
            //assert(newValue < maxValue, "RangeSlider: minimumValue should be lower than maximumValue")
        }
        didSet {
            refreshLayerFrames()
        }
    }
    
    /// track의 최대값
    @IBInspectable public var maxValue: Double = 100 {
        willSet(newValue) {
            assert(newValue > minValue, "must minValue < maxValue")
            //assert(newValue > minValue, "RangeSlider: maximumValue should be greater than minimumValue")
        }
        didSet {
            refreshLayerFrames()
        }
    }
    
    /// 출력 시작영역 값
    @IBInspectable public var lowValue: Double = 0.0 {
        didSet {
            refreshLayerFrames()
        }
    }
    
    /// 출력 끝영역 값
    @IBInspectable public var highValue: Double = 100 {
        didSet {
            refreshLayerFrames()
        }
    }

    /// 현재 재생중인 부분의 값
    @IBInspectable public var nowPlayValue: Double = 0.0 {
        didSet {
            refreshLayerFrames()
        }
    }
    
    override public var frame: CGRect {
        didSet {
            refreshLayerFrames()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initLayers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLayers()
    }
    
    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        refreshLayerFrames()
    }
    
    /// 전체 layer, 출력 시작 layer, 출력 끝 layer
    func initLayers(){
        layer.backgroundColor = UIColor.clear.cgColor
        
        trackLayer.frameSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        lowThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowThumbLayer)
        
        highThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(highThumbLayer)
    }

    /// 전체/시작/끝 layer 새로고침
    public func refreshLayerFrames(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
     
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: 0)
        trackLayer.setNeedsDisplay()
        
        let lowThumbPositionX = Double(positionForValue(lowValue)) - Double(thumbWidth)/2.0
        lowThumbLayer.frame = CGRect(x: lowThumbPositionX, y: 0, width: Double(thumbWidth), height: Double(self.bounds.height))
        lowThumbLayer.setNeedsDisplay()
        
        let highThumbPositionX = Double(positionForValue(highValue)) - Double(thumbWidth)/2.0
        highThumbLayer.frame = CGRect(x: highThumbPositionX, y: 0, width: Double(thumbWidth), height: Double(self.bounds.height))
        highThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    /// 사용자 tracking 시작
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previouslocation = touch.location(in: self)
        
        if lowThumbLayer.frame.contains(previouslocation) {
            lowThumbLayer.highlighted = true
            lowLayerIsSelected = lowThumbLayer.highlighted
            
        } else if highThumbLayer.frame.contains(previouslocation) {
            highThumbLayer.highlighted = true
            lowLayerIsSelected = lowThumbLayer.highlighted
            
        }
        return lowThumbLayer.highlighted || highThumbLayer.highlighted
    }
    
    /// 사용자 tracking 진행
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let deltaLocation = Double(location.x - previouslocation.x)
        let deltaValue = (maxValue - minValue) * deltaLocation / Double(bounds.width - bounds.height)
        
        previouslocation = location
        
        if lowThumbLayer.highlighted {
            lowValue = boundValue(lowValue + deltaValue, lowerValue: minValue, upperValue: highValue - distanceBetweenThumbs)
        } else if highThumbLayer.highlighted {
            highValue = boundValue(highValue + deltaValue, lowerValue: lowValue + distanceBetweenThumbs, upperValue: maxValue)
        }
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    /// 사용자 tracking 끝
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowThumbLayer.highlighted = false
        highThumbLayer.highlighted = false
    }
    
    /// 보여지는 영역대비 시작/끝 layer의 크기
    var distanceBetweenThumbs: Double {
        return 0.6 * Double(thumbWidth) * (maxValue - minValue) / Double(bounds.width)
    }
    
    /// 사용자 tracking시 실제 보여질 highlight(시작/끝)
    func boundValue(_ value: Double, lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    /// 현재뷰가 화면에 보여질때(refreshLayerFrames) 실제 화면상에 보여지는 좌표 계산
    func positionForValue(_ value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minValue) / (maxValue - minValue) + Double(thumbWidth/2.0)
    }
}
