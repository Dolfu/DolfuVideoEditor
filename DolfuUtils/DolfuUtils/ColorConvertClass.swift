//
//  ColorConvertClass.swift
//  DolfuUtils
//
//  Created by 김효빈 on 2018. 3. 24..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import Foundation

/// UIColor 컨버팅
public class ColorConvertClass{
    
    /**
     Hex String 값으로부터 UIColor를 변환하여 반환한다.
     - Params:
        - hex: ex) #df1584
     - Return: 변환된 UIColor
     */
    public static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
