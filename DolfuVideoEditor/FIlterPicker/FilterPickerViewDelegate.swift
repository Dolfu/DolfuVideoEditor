//
//  FilterPickerViewDelegate.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 21..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit

/// FilterPickerView Delegate
public protocol FilterPickerViewDelegate {
    
    /// 새로운 필터를 선택시
    func changeCIFilter(ciFilter:CIFilter?)
    
    /// 필터적용안함
    func removeCIFilter()
}
