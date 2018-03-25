//
//  AlbumModel.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 24..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import Foundation
import Photos

public class AlbumModel {
    let name:String
    let count:Int
    let collection:PHAssetCollection
    init(name:String, count:Int, collection:PHAssetCollection) {
        self.name = name
        self.count = count
        self.collection = collection
    }
}
