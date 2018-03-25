//
//  DolfuCollectionViewCell.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 18..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit
import Photos
import DolfuUtils

/// ViewController의 collectionView Cell
public class DolfuCollectionViewCell: UICollectionViewCell {
    let margin:CGFloat = 4
    var labelRunningTime:UILabel = UILabel()
    
    var avAsset:AVAsset? = nil
    
    var asset:PHAsset? = nil
    var imageView:UIImageView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// asset 설정.
    /// asset으로부터 thumbnail image 로드
    public func setAsset(asset:PHAsset){
        self.asset = asset
        if !self.subviews.contains(self.imageView){
            self.addSubview(self.imageView)
        }
        self.setImageViewFrame(isSelected: isSelected)
        
        if !self.subviews.contains(self.labelRunningTime){
            self.labelRunningTime.text = ""
            self.labelRunningTime.textColor = .white
            self.labelRunningTime.font = UIFont.systemFont(ofSize: 11)
            self.labelRunningTime.frame = CGRect(x: margin, y: margin, width: self.bounds.size.width - margin, height: 11)
            self.addSubview(self.labelRunningTime)
        }
        self.setAVRunningTime()
    }
    
    /// cell선택시 preview화면으로 asset 반환
    public func getAsset(callback:@escaping (_ avAsset: AVAsset?) -> Void){
        callback(self.avAsset)
//        UtilAsset.convertPHAssetToAVAsset(phAsset: self.asset!) { (resultAsset) in
//            callback(resultAsset)
//        }
    }
    
    /// asset으로부터 재생시간 로드
    func setAVRunningTime(){
        UtilAsset.convertPHAssetToAVAsset(phAsset: self.asset!) { (resultAsset) in
            if resultAsset != nil {
                let avAsset:AVAsset = resultAsset as! AVURLAsset
                let thumbTime: CMTime = avAsset.duration
                let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
                
                let minute:Int = thumbtimeSeconds / 60
                let second:Int = thumbtimeSeconds % 60
                
                DispatchQueue.main.async {
                    self.labelRunningTime.text = "\(minute):\(String(format:"%02d", second))" as String
                }
                self.avAsset = resultAsset
            }else {
                self.avAsset = nil
            }
        }/*
        PHCachingImageManager().requestAVAsset(forVideo: self.asset!, options: nil) { (asset, audioMix, args) in
            if asset != nil {
                let avAsset:AVAsset = asset as! AVURLAsset
                let thumbTime: CMTime = avAsset.duration
                let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
                
                let minute:Int = thumbtimeSeconds / 60
                let second:Int = thumbtimeSeconds % 60
                
                DispatchQueue.main.async {
                    self.labelRunningTime.text = "\(minute):\(String(format:"%02d", second))" as String
                }
            }
        }*/
    }
    
    /// asset으로부터 thumbnail 이미지 로드
    func loadImageFromAsset(){
        DispatchQueue.main.async {
            self.imageView.image = UtilAsset.getThumbnailImageFromPHAsset(asset: self.asset!, staticSize: self.imageView.bounds.size.width)
        }
    }
    
    /// cell이 선택될경우 프레임 사이즈 변환 및 색상 적용
    public func setImageViewFrame(isSelected:Bool){
        if(isSelected){
            imageView.frame = CGRect(x: margin, y: margin, width: self.bounds.size.width - margin * 2, height: self.bounds.size.height - margin * 2)
            self.backgroundColor = .yellow
        }else{
            imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        }
        loadImageFromAsset()
    }
}
