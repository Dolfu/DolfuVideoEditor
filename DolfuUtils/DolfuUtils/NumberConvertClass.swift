//
//  NumberConvertClass.swift
//  DolfuUtils
//
//  Created by 김효빈 on 2018. 3. 21..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import Foundation

/// 숫자 컨버팅 관련 클래스
public class NumberConvertClass{
    
    /**
     소숫점 자리수 설정
     - Params:
         - value: 변환할 소수
         - roundUnit: 결과값의 소숫점 자리수
     - Return: 결과
     */
    public static func roundCGFloat(value:CGFloat, roundUnit:Int) -> Float64{
        let multiplier = pow(10.0, CGFloat(roundUnit))
        let result:Float64 = Float64(round(value * multiplier) / multiplier)
        print("\(result)")
        return result
    }
}
