//
//  ForIndicatorViewClass.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 20..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import DolfuUtils

/**
 NVActivityIndicatorView 생성시 동일코드 반복을 줄이기위함
 - initIndicatorView: NVActivityIndicatorView를 생성 및 반환
 */
class ForIndicatorViewClass{
    /**
     NVActivityIndicatorView를 생성 및 반환
     - Parameters:
        - screenSize: NVActivityIndicatorView를 출력할 화면의 Size
     
     - Throws: test Throws
     
     - Returns: 생성된 NVActivityIndicatorView
     - 출처: [NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView.git)
    */
    static func initIndicatorView(screenSize:CGSize) -> NVActivityIndicatorView{
        let indicatorViewWidth:CGFloat = 200
        let indicatorViewFrame = CGRect(x: CGFloat(screenSize.width - indicatorViewWidth) / 2, y: CGFloat(screenSize.height - indicatorViewWidth) / 2, width: indicatorViewWidth, height: indicatorViewWidth)
        let indicatorView = NVActivityIndicatorView(frame: indicatorViewFrame, type: NVActivityIndicatorType.ballRotateChase, color: ColorConvertClass.hexStringToUIColor(hex: "#EFB71B"), padding: 10)
        return indicatorView
    }
}
