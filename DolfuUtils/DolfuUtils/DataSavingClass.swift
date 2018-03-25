//
//  DataSavingClass.swift
//  DolfuUtils
//
//  Created by 김효빈 on 2018. 3. 24..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import Foundation
import Photos

/// 데이터 저장 관련 클래스
public class DataSavingClass{
    
    /// 신규 .MP4 형태의 파일을 저장할 신규 URL 생성. 1~1000000 사이의 랜덤값. 만약 동일한 명칭이 존재하면 기존파일 삭제
    public static func createNewDirectoryAndFileURL(completion:@escaping (NSURL?) -> Void){
        let fileManager = FileManager.default
        guard let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            return
        }
        var outputURL = documentDirectory.appendingPathComponent("dolfus")
        do{
            let randomNo: UInt32 = arc4random_uniform(1000000) + 1;
            
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("dolfu\(randomNo).mp4")
            
            //동일한 명칭이 존재하면 기존파일 삭제
            _ = try? fileManager.removeItem(at: outputURL)
            
            completion(outputURL as NSURL)
        }catch {
            print("error \(error)")
            completion(nil)
        }
    }
    
    /**
     동영상 파일을 저장한다.
     - Params:
        - saveURL: 파일이 저장될 URL
     */
    public static func saveToCameraRoll(saveURL: URL, callback:@escaping (Bool) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: saveURL)
        }) { saved, error in
            if !saved {
                print("error saveToCameraRoll: \(String(describing: error))")
            }
            callback(saved)
        }
    }
}
