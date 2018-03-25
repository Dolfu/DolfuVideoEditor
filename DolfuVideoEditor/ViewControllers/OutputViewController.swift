//
//  OutputViewController.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 21..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit
import AVKit
import Photos
import NVActivityIndicatorView
import DolfuAVPlayer
import DolfuUtils

/// 출력화면
class OutputViewController: UIViewController, DolfuAVPlayerViewDelegate {
    var indicatorView:NVActivityIndicatorView!
    var applyFilter:CIFilter? = nil
    var avAsset:AVAsset? = nil
    var startTime:Double = 0
    var endTime:Double = 0
    
    @IBOutlet weak var playerView: DolfuAVPlayerView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initIndicatorView()
        initPlayerView()
    }
    
    /// viewDidDisappear - 현재 컨트롤러가 disappear될경우 player 멈춤
    override func viewDidDisappear(_ animated: Bool) {
        playerView.doPauseAtAVPlayer()
    }
    
    /// 플레이어뷰 initialize.
    /// 편집화면으로 부터 넘겨받은 원본 asset과 선택된 필터목록, 구간잘라내기 영역을 적용.
    func initPlayerView(){
        let tempAsset = avAsset!.copy() as! AVAsset
        playerView.setAVAsset(avAsset: tempAsset)
        playerView.seekVideo(toPos: CGFloat(startTime))
        playerView.delegate = self
        playerView.setNewFilter(ciFilter: applyFilter)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapOnVideoLayer))
        self.playerView.addGestureRecognizer(tap)
        self.tapOnVideoLayer(tap: tap)
        
        playerView.doPlayingAtAVPlayer()
    }
    
    /// NVActivityIndicatorView initialize
    func initIndicatorView(){
        indicatorView = ForIndicatorViewClass.initIndicatorView(screenSize: self.view.bounds.size)
        self.view.addSubview(indicatorView)
    }
    
    ///DolfuAVPlayerViewDelegate
    func changedNowPlaySeconds(seconds: Float64) {
        if(seconds > endTime){
            playerView.seekVideo(toPos: CGFloat(startTime))
            //playerView.doPauseAtAVPlayer()
        }
    }
    
    ///DolfuAVPlayerViewDelegate
    func changedPlayStatus(isNowPlaying: Bool) {
        
    }
    
    /// 플레이어뷰 선택시, 플레이어 재생상태 변경
    @objc func tapOnVideoLayer(tap: UITapGestureRecognizer)
    {
        self.playerView.doChangePlayingStatus()
    }
    
    /// 뒤로 버튼 이벤트
    @IBAction func clickBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /// 저장 버튼 이벤트
    @IBAction func clickSave(_ sender: Any) {
        indicatorView.startAnimating()
        playerView.doPauseAtAVPlayer()
        
        /// 구간 잘라내기 영역
        let cropRange:CMTimeRange = CMTimeRange(start: CMTime(seconds: self.startTime, preferredTimescale: 1000), end: CMTime(seconds: self.endTime, preferredTimescale: 1000))
        
        buttonBack.isEnabled = false
        buttonSave.isEnabled = false
        
        var filters:[CIFilter] = []
        if applyFilter != nil {
            filters.append(applyFilter!)
        }
        
        /// Video export시작
        /// 완료된 VideoAsset을 저장할 신규 디렉토리 생성.
        DataSavingClass.createNewDirectoryAndFileURL { (url) in
            
            /// Exporter 선언
            let exporter = VideoFilterExport(asset: self.avAsset!, filters: filters, cropTimeRange: cropRange)
            
            /// export 작업수행
            exporter.export(outputURL: url! as URL, callback: { (resultURL) in
                /// export 작업 수행후, 카메라롤의 위에 생성한 URL에 저장.
                DataSavingClass.saveToCameraRoll(saveURL: resultURL!, callback: { (result) in
                    DispatchQueue.main.async {
                        self.indicatorView.stopAnimating()
                        self.buttonBack.isEnabled = true
                        self.buttonSave.isEnabled = true
                    }
                    if result {
                        /// 정상저장된 경우
                        let alertController = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        /// 저장 실패한 경우
                        let alertController = UIAlertController(title: "Fail", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            })
        }
    }
}
