//
//  AssetConvertClass.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 20..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import Foundation
import Photos
import AVKit
import CoreImage

/**
 PHAsset 과 AVAsset 관련 util
 - convertPHAssetToAVAsset: PHAsset -> AVAsset 변환 함수
 */
public class UtilAsset {
    
    /**
     PHAsset -> AVAsset 변환 함수
     - Parameters:
     - phAsset: 변환하고자 하는 원본 PHAsset
     - complete: @escaping:AVAsset? (변환이 완료된 optional(AVAsset)을 반환. 실패인 경우 nil)
     */
    public static func convertPHAssetToAVAsset(phAsset:PHAsset, complete: @escaping(_:AVAsset?)->()){
        PHCachingImageManager().requestAVAsset(forVideo: phAsset, options:nil) { (resultAVAsset, audioMix, args) in
            complete(resultAVAsset)
            return
        }
        complete(nil)
    }
    
    /**
     videotrack 의 orientation 얻어옴
     - Params:
        - videoTrack: orientation을 얻어올 원본
     - Returns: UIIterfaceOrientation
     */
    public static func getOrientationOfAVAssetTrack(videoTrack:AVAssetTrack) -> UIInterfaceOrientation{
        let size:CGSize = videoTrack.naturalSize
        let transform:CGAffineTransform = videoTrack.preferredTransform
        
        if (size.width == transform.tx && size.height == transform.ty){
            print("landscapeRight")
            return UIInterfaceOrientation.landscapeRight;
        }
        else if (transform.tx == 0 && transform.ty == 0){
            print("landscapeLeft")
            return UIInterfaceOrientation.landscapeLeft;
        }
        else if (transform.tx == 0 && transform.ty == size.width){
            print("portraitUpsideDown")
            return UIInterfaceOrientation.portraitUpsideDown;
        }
        else{
            print("portrait")
            return UIInterfaceOrientation.portrait;
        }
    }
    
    /**
     phasset으로부터 thumbnailImage를 얻어옴
     - Params:
        - asset: 원본 phasset
        - staticSize: 결과 이미지의 사이즈
     - Returns: UIImage
     */
    public static func getThumbnailImageFromPHAsset(asset: PHAsset, staticSize: CGFloat) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        option.resizeMode = .exact
        option.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
            if result != nil {
                var minimumLength:CGFloat = 0
                var positionX:CGFloat = 0
                var positionY:CGFloat = 0
                if(asset.pixelHeight < asset.pixelWidth){
                    positionX = CGFloat((result?.size.width)! - (result?.size.height)!) / 2
                    minimumLength = (result?.size.height)!
                }else{
                    positionY = CGFloat((result?.size.height)! - (result?.size.width)!) / 2
                    minimumLength = (result?.size.width)!
                }
                
                let crop = CGRect(x: positionX, y: positionY, width: minimumLength, height: minimumLength)
                let croppedCGImage = result!.cgImage?.cropping(to: crop)
                let croppedImage = UIImage(cgImage: croppedCGImage!)
                
                thumbnail = croppedImage
            }
        })
        return thumbnail
    }
    
    /**
     이미지에 필터를 적용하여 반환
     - Params:
        - inputImage: 원본이미지
        - filterName: 적용할 필터명
     - Returns: 필터가 적용된 결과 이미지
     */
    public static func getFilterApplyThumbnailImageFromOriginImageWithFilterName(inputImage:UIImage, filterName:String) -> UIImage?{
        let context = CIContext()
        let filter = CIFilter(name: filterName)!
        filter.setDefaults()
        let image = CIImage(cgImage: inputImage.cgImage!)
        filter.setValue(image, forKey: kCIInputImageKey)
        let result = filter.outputImage!
        let cgImage = context.createCGImage(result, from: result.extent)
        return UIImage(cgImage: cgImage!)
        
    }
}

