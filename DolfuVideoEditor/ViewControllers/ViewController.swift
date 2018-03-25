//
//  ViewController.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 18..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit
import Photos
import Dropdowns
import NVActivityIndicatorView
import DolfuCollectionView
import DolfuAVPlayer
import DolfuUtils

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate, EditQuestionViewDelegate {
    /// var 선언
    var albums:[AlbumModel] = []
    var loadAssets:[PHAsset] = []
    var indicatorView:NVActivityIndicatorView!
    
    @IBOutlet weak var buttonAccessAgree: UIBarButtonItem!
    @IBOutlet weak var dolfuCollectionView: UICollectionView!
    
    /// viewcontroller override function - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initIndicatorView()
        indicatorView.startAnimating()
        DispatchQueue.main.async {
            self.initCollectionViewSize()
            self.indicatorView.stopAnimating()
        }
    }
    
    /// viewcontroller override function - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        checkPhotoLibraryPermission()
    }
    
    /// collectionView의 레이아웃 재정의
    func initCollectionViewSize(){
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        let collectionViewSize = (UIScreen.main.bounds.size.width - 4.0) / 4.0
        layout.itemSize = CGSize(width: collectionViewSize, height: collectionViewSize)
        dolfuCollectionView.collectionViewLayout = layout
        
    }
    
    /// initIndicatorView
    func initIndicatorView(){
        indicatorView = ForIndicatorViewClass.initIndicatorView(screenSize: self.view.bounds.size)
        self.view.addSubview(indicatorView)
    }
    
    /// 사용자 퍼미션 승인된 경우. 뷰로드
    func loadComponents(isAccept:Bool){
        DispatchQueue.main.async {
            self.buttonAccessAgree.isEnabled = !isAccept
            self.indicatorView.stopAnimating()
            self.loadAlbumsFromPhotoLibrary()
        }
    }
    
    
    /// 사용자 퍼미션 체크
    func checkPhotoLibraryPermission() {
        indicatorView.startAnimating()
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:///권한이 '사용가능'인 경우 => 사용자의 앨범목록 로드
            loadComponents(isAccept: true)
            break
        case .denied, .restricted :/// 권한이 '거절'인 경우 => 권한설정여부 팝업 로드
            loadComponents(isAccept: false)
            break
        case .notDetermined:/// 권한을 한번도 설정한적 없는경우. 최초실행
            PHPhotoLibrary.requestAuthorization() { status in
                print("status \(status)")
                switch status {
                case .authorized:
                    self.loadComponents(isAccept: true)
                    break
                case .denied, .restricted:
                    self.loadComponents(isAccept: false)
                    break
                case .notDetermined:
                    self.loadComponents(isAccept: false)
                    break
                }
            }
        }
    }
    
    /// 권한설정 팝업
    func showPhotoLibraryQuestionAlertController(){
        let alertController = UIAlertController(title: "이 앱이 사용자의 사진에 접근하려고 합니다.", message: "설정 버튼을 누르면 설정화면으로 이동합니다.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let settingsAction = UIAlertAction(title: "설정", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "설정 안함(종료)", style: .default){ (_) -> Void in
            exit(0)
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// 사용자 앨범 로드
    func loadAlbumsFromPhotoLibrary(){
        albums.removeAll()
        var albumNames:[String] = []
        
        let options = PHFetchOptions()
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: options)
        
        userAlbums.enumerateObjects{ (object: AnyObject!, count: Int, stop: UnsafeMutablePointer) in
            if object is PHAssetCollection {
                let obj:PHAssetCollection = object as! PHAssetCollection
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                
                let newAlbum = AlbumModel(name: obj.localizedTitle!, count: obj.estimatedAssetCount, collection:obj)
                self.albums.append(newAlbum)
                albumNames.append(newAlbum.name)
            }
        }
        self.loadTitleView(albumList: albumNames)
    }
    
    /// collectionView 관련 함수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadAssets.count
    }
    
    /// collectionView 관련 함수
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:DolfuCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dolfuCollectionViewCell", for: indexPath) as! DolfuCollectionViewCell
        cell.setAsset(asset: self.loadAssets[indexPath.row])
        return cell
    }
    
    /// collectionView 관련 함수
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) == nil else {
            let cell:DolfuCollectionViewCell = (collectionView.cellForItem(at: indexPath) as! DolfuCollectionViewCell)
            cell.setImageViewFrame(isSelected: true)
            print("didSelectItemAt")
            DispatchQueue.main.async {
                cell.getAsset(callback: { (avAsset) in
                    if avAsset != nil {
                        self.presentEditQuestionViewController(sender: cell, asset: avAsset!)
                    } else {
                        let alert = UIAlertController(title: "불가", message: "편집할수 없는 파일형식입니다.", preferredStyle: UIAlertControllerStyle.alert)
                        let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                })
            }
            return
        }
    }
    
    ///셀 미리보기 화면 출력
    func presentEditQuestionViewController(sender:UIView, asset:AVAsset){
        print("asdf")
        DispatchQueue.main.async {
            self.indicatorView.startAnimating()
            ///선택한 셀에대한 미리보기 화면 출력
            let editQuestionVC = self.storyboard!.instantiateViewController(withIdentifier: "editQuestionVC") as! EditQuestionViewController
            editQuestionVC.avAsset = asset
            editQuestionVC.delegate = self
            editQuestionVC.modalPresentationStyle = .popover
            editQuestionVC.popoverPresentationController?.permittedArrowDirections = .any
            editQuestionVC.popoverPresentationController?.delegate = self
            editQuestionVC.popoverPresentationController?.sourceView = sender
            editQuestionVC.popoverPresentationController?.sourceRect = sender.bounds
            self.present(editQuestionVC, animated: true) {
                self.indicatorView.stopAnimating()
            }
        }
        
        //self.present(editQuestionVC, animated: true, completion: nil)
    }
    
    /// collectionView 관련 함수
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("didDeselectItemAt")
        guard collectionView.cellForItem(at: indexPath) == nil else{
            
            let cell:DolfuCollectionViewCell = collectionView.cellForItem(at: indexPath) as! DolfuCollectionViewCell
            cell.setImageViewFrame(isSelected: false)
            return
        }
    }
    
    /**
     타이블뷰 로드. PhotoLib로부터 불러온 앨범 목록을 타이블뷰 메뉴로 사용
     - Params:
        - albumList: 앨범목록
     - 출처: [Dropdowns.git](https://github.com/hyperoslo/Dropdowns.git)
     */
    func loadTitleView(albumList:[String]){
        guard albumList.isEmpty else {
            let titleView = TitleView(navigationController: self.navigationController!, title: albumList[0], items: albumList)
            Config.List.backgroundColor = UIColor.white
            Config.List.DefaultCell.Text.color = UIColor.black
            Config.topLineColor = UIColor.orange
            
            titleView?.action = { [weak self] index in
                self?.loadCollectionViewCells(index: index)
            }
            self.navigationItem.titleView = titleView
            self.loadCollectionViewCells(index: 0)
            return
        }
    }
    
    /// 현재 선택한 앨범의 Asset을 collectionView Cell에 추가. 완료후 CollectionView 다시 로드
    func loadCollectionViewCells(index:Int){
        self.indicatorView.startAnimating()
        self.loadAssets.removeAll()
        
        let album = self.albums[index]
        let options = PHFetchOptions()
        let assets = PHAsset.fetchAssets(in: album.collection, options: options)
        if(assets.count > 0){
            var index:Int = 0
            while index < assets.count{
                if(assets[index].mediaType == .video){
                    self.loadAssets.append(assets[index])
                }
                index += 1
            }
        }
        
        DispatchQueue.main.async {
            
            self.dolfuCollectionView.reloadData()
            Thread.sleep(forTimeInterval: 1)
            self.indicatorView.stopAnimating()
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    /// 버튼이벤트 : 권한설정하기 버튼 클릭
    @IBAction func clickAccessAgree(_ sender: Any) {
        showPhotoLibraryQuestionAlertController()
    }
    
    /// 버튼이벤트 : 편집시작 버튼 클리
    func clickEditStartFromEditQuestionVC() {
        let indexPaths:[IndexPath] = dolfuCollectionView.indexPathsForSelectedItems!
        guard indexPaths.count == 0 else {
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "editVC") as! DolfuEditViewController
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController.originPHAsset = self.loadAssets[indexPaths[0].row]
            self.present(viewController, animated: true, completion: nil)
            
            return
        }
    }
}
