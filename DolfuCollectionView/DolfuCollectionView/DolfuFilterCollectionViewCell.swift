//
//  FilterCollectionViewCell.swift
//  DolfuCollectionView
//
//  Created by 김효빈 on 2018. 3. 24..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit

/// 편집화면에서 사용되는 필터 Picker의 collectionViewCell
public class DolfuFilterCollectionViewCell: UICollectionViewCell {
    let margin:CGFloat = 4
    var imageView:UIImageView = UIImageView()
    var isApplyFilter = true
    var labelFilterName:UILabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// imageView 설정
    /// filter 명 라벨 추가.
    func initChileViews(){
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        setImageViewFrame(isSelected: false, image: UIImage())
        addSubview(labelFilterName)
    }
    
    /// 이미지와 필터명을 UI에 적용
    public func setImageWithFilterName(image:UIImage, filterName:String){
        initChileViews()
        
        imageView.image = image
        labelFilterName.textColor = .white
        labelFilterName.font = UIFont.systemFont(ofSize: 10)
        labelFilterName.frame = CGRect(x: margin, y: margin, width: self.bounds.size.width - margin * 2, height: 10)
        
        if(filterName == ""){
            labelFilterName.text = "원본"
            isApplyFilter = false
        } else {
            labelFilterName.text = filterName
            isApplyFilter = true
        }
        setImageViewFrame(isSelected: isSelected, image: image)
    }
    
    /// CELL이 선택된 경우 사이즈 줄여서 선택된것처럼 보이게 처리.
    public func setImageViewFrame(isSelected:Bool, image:UIImage){
        if(isSelected){
            self.imageView.frame = CGRect(x: self.margin, y: self.margin, width: self.bounds.size.width - self.margin * 2, height: self.bounds.size.height - self.margin * 2)
            self.backgroundColor = .yellow
        }else{
            self.imageView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
            self.backgroundColor = .clear
        }
        self.imageView.image = image
    }
}
