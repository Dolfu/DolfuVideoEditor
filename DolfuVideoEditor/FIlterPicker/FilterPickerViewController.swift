//
//  FilterPickerViewController.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 21..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit
import Photos
import DolfuAVPlayer
import DolfuCollectionView
import DolfuUtils

/// FilterPickerViewController
/// 편집화면에서 Filter 선택을 위한 팝업화면
class FilterPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// 기존 선택된 필터명
    var receivedSelectedFilterName:String = ""
    
    /// 기존 샌택된 필터 인덱스
    var beforeSelectedIndex = 0
    
    /// 필터링하기 이전의 원본 Asset
    var phAsset:PHAsset? = nil
    
    /// 필터링처리된 이미지 배열
    var images:[UIImage] = []
    
    /// 필터명 배열
    var availableFilters:[String] = []

    ///FilterPickerViewDelegate
    public var delegate:FilterPickerViewDelegate?
    
    /// 필터링된 이미지 리스트가 보여질 CollectionView
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async {
            self.initCollectionViewSize()
            let originImage:UIImage = UtilAsset.getThumbnailImageFromPHAsset(asset: self.phAsset!, staticSize: self.filterCollectionView.bounds.size.height)
            self.makeTempPHAssets(originImage:originImage, filters: DolfuFilters.avaliableFilters())
            
            self.filterCollectionView.selectItem(at: IndexPath(item: self.beforeSelectedIndex, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.bottom)
        }
    }
    
    /// 원본이미지를 각필터별로 적용하여 새로운 필터링된 이미지 배열 생성
    func makeTempPHAssets(originImage:UIImage, filters:[String]){
        clearFilterList()
        addNewFilter(image: originImage, filterName: "")
        
        var index = 0
        while index < filters.count {
            let convertedImage = UtilAsset.getFilterApplyThumbnailImageFromOriginImageWithFilterName(inputImage: originImage, filterName: filters[index])
            if convertedImage != nil {
                addNewFilter(image: convertedImage!, filterName: filters[index])
                if receivedSelectedFilterName == filters[index] {
                    beforeSelectedIndex = index
                }else{
                    beforeSelectedIndex = 0
                }
            }
            
            index += 1
        }
        filterCollectionView.reloadData()
    }
    
    /// 필터 목록 초기화
    func clearFilterList(){
        self.images.removeAll()
        self.availableFilters.removeAll()
    }
    
    /// 새로운 필터를 목록에 추가
    func addNewFilter(image:UIImage, filterName:String){
        self.images.append(image)
        self.availableFilters.append(filterName)
    }
    
    /// collectionView initialize
    func initCollectionViewSize(){
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionViewSize = filterCollectionView.bounds.size.height
        layout.itemSize = CGSize(width: collectionViewSize, height: collectionViewSize)
        layout.scrollDirection = .horizontal
        filterCollectionView.collectionViewLayout = layout
    }
    
    /// collectionView 관련 함수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    /// collectionView 관련 함수
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:DolfuFilterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dolfuFilterCollectionViewCell", for: indexPath) as! DolfuFilterCollectionViewCell
        cell.setImageWithFilterName(image: images[indexPath.row], filterName: availableFilters[indexPath.row])
        return cell
    }
    
    /// collectionView 관련 함수
    /// cell이 선택된 경우 선택된 cell의 CIFilter를 리턴
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) == nil else {
            let cell:DolfuFilterCollectionViewCell = (collectionView.cellForItem(at: indexPath) as! DolfuFilterCollectionViewCell)
            cell.setImageViewFrame(isSelected: true, image: images[indexPath.row])
            if indexPath.row == 0 {
                delegate?.changeCIFilter(ciFilter: nil)
            } else {
                let ciFilter = CIFilter(name: self.availableFilters[indexPath.row])
                ciFilter?.setDefaults()
                delegate?.changeCIFilter(ciFilter: ciFilter)
            }
            return
        }
    }
    
    /// collectionView 관련 함수
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) == nil else{
            let cell:DolfuFilterCollectionViewCell = collectionView.cellForItem(at: indexPath) as! DolfuFilterCollectionViewCell
            cell.setImageViewFrame(isSelected: false, image: images[indexPath.row])
            return
        }
    }
}
