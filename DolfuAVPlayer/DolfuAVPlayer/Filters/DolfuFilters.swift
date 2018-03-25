//
//  DolfuFilters.swift
//  DolfuAVPlayer
//
//  Created by 김효빈 on 2018. 3. 22..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import Foundation

/// 필터명 모음
public struct DolfuFilters {
    
    /// 이용가능한 필터명 GET
    public static func avaliableFilters() -> [String] {
        
        let avaliableFilters = [
            "CIBoxBlur",
            "CIDiscBlur",
            "CIGaussianBlur",
            "CIMaskedVariableBlur",
            "CIMedianFilter",
            "CIMotionBlur",
            "CINoiseReduction",
            "CIColorCrossPolynomial",
            "CIColorCube",
            "CIColorCubeWithColorSpace",
            "CIColorInvert",
            "CIColorMonochrome",
            "CIColorPosterize",
            "CIFalseColor",
            "CIMaskToAlpha",
            "CIMaximumComponent",
            "CIMinimumComponent",
            "CIPhotoEffectChrome",
            "CIPhotoEffectFade",
            "CIPhotoEffectInstant",
            "CIPhotoEffectMono",
            "CIPhotoEffectNoir",
            "CIPhotoEffectProcess",
            "CIPhotoEffectTonal",
            "CIPhotoEffectTransfer",
            "CISepiaTone",
            "CIVignette",
            "CIVignetteEffect"
        ]
        
        return avaliableFilters
    }
}
