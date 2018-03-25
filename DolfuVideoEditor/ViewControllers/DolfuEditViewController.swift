//
//  DolfuEditViewController.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 20..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit
import Photos
import AVKit
import NVActivityIndicatorView
import DolfuFrameSlider
import DolfuAVPlayer
import DolfuUtils
import ColorSlider

class DolfuEditViewController: UIViewController, DolfuAVPlayerViewDelegate, UIPopoverPresentationControllerDelegate, FilterPickerViewDelegate {
    ///사용자가 추출을 위해 선택한 시간 range 표기 레이블
    @IBOutlet weak var labelTimeRange: UILabel!
    
    ///DolfuFrameSlider가 추가될 부모 뷰
    @IBOutlet weak var seekBarBackgroundView: UIView!
    
    ///DolfuAVPlayerView
    @IBOutlet weak var playerView: DolfuAVPlayerView!
    
    /// 화면 전환 등에 쓰이는 indicatorView
    var indicatorView:NVActivityIndicatorView!
    
    /// 컬러필터 팝업
    var filterAlertController:UIAlertController? = nil
    
    /// 프레임 슬라이더
    var frameSliderView: DolfuFrameSlider? = nil
    
    /// Player의 재생상태 변경 버튼
    @IBOutlet weak var buttonPlayStatus: UIButton!
    
    /// 하단 버튼영역의 parent View. filterPickerVC의 popover을 위해 선언
    @IBOutlet weak var buttonsBackgroundView: UIView!
    
    /// ViewController로 부터 넘겨받는 편집을 위한 원본 PHAsset
    var originPHAsset:PHAsset? = nil
    
    var originAVAsset:AVAsset? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initIndicatorView()
        self.indicatorView.startAnimating()
        
        /// 원본 PHAsset 을 AVAsset으로 변환 후 각 함수 수행
        UtilAsset.convertPHAssetToAVAsset(phAsset: self.originPHAsset!) { (avAsset) in
            guard avAsset != nil else {return}
            DispatchQueue.main.async {
                self.originAVAsset = avAsset!.copy() as? AVAsset
                self.initPlayerView(avAsset: avAsset!)
                self.initFrameSliderBackgroundImage(avAsset: avAsset!)
                self.initFrameSliderView()
                
                self.indicatorView.stopAnimating()
                //self.playerView.doPlayingAtAVPlayer()
            }
        }
    }
    
    /// viewDidDisappear - 현재 컨트롤러가 disappear될경우 player 멈춤
    override func viewDidDisappear(_ animated: Bool) {
        playerView.doPauseAtAVPlayer()
    }
    
    /// NVActivityIndicatorView initialize
    func initIndicatorView(){
        indicatorView = ForIndicatorViewClass.initIndicatorView(screenSize: self.view.bounds.size)
        self.view.addSubview(indicatorView)
    }
    
    /// DolfuAVPlayerView initialize
    func initPlayerView(avAsset:AVAsset){
        self.playerView.delegate = self
        self.playerView.setAVAsset(avAsset: avAsset)
    }
    
    /// FrameSlider의 배경이 되는 이미지 initialize
    func initFrameSliderBackgroundImage(avAsset:AVAsset){
        let visibleFrameImageCount:Int = 6
        
        let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset:avAsset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter    = kCMTimeZero;
        assetImgGenerate.requestedTimeToleranceBefore   = kCMTimeZero;
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        let maxLength = "\(playerView.getTotalSeconds())" as NSString
        let thumbAverage = playerView.getTotalSeconds() / CGFloat(visibleFrameImageCount)
        var startTime:CGFloat = 0
        var startXPosition:CGFloat = 0.0
        
        var index = 0
        while index < visibleFrameImageCount {
            
            let imageButton = UIButton()
            let xPositionForEach = CGFloat(self.seekBarBackgroundView.frame.width) / CGFloat(visibleFrameImageCount)
            imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height:CGFloat(self.seekBarBackgroundView.frame.height))
            do {
                let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),Int32(maxLength.length))
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: img)
                imageButton.setImage(image, for: .normal)
            } catch _ as NSError {
                print("error (error)")
            }
            
            startXPosition = startXPosition + xPositionForEach
            startTime = startTime + thumbAverage
            imageButton.isUserInteractionEnabled = false
            seekBarBackgroundView.addSubview(imageButton)
            
            index += 1
        }
    }
    
    /// 프레임 슬라이더 initialize
    func initFrameSliderView(){
        frameSliderView = DolfuFrameSlider(frame: CGRect(x: 0, y: 0, width: seekBarBackgroundView.bounds.width, height: seekBarBackgroundView.bounds.height))
        frameSliderView?.addTarget(self, action: #selector(rangeSliderValueChanged), for: UIControlEvents.valueChanged)
        frameSliderView?.minValue = 0.0
        frameSliderView?.maxValue = Double(playerView.getTotalSeconds())
        frameSliderView?.lowValue = 0.0
        frameSliderView?.highValue = Double(playerView.getTotalSeconds())
        setTimeRangeText(startTime: (frameSliderView?.lowValue)!, endTime: (frameSliderView?.highValue)!)
        seekBarBackgroundView.addSubview(frameSliderView!)
    }
    
    ///MARK: DolfuAVPlayerViewDelegate
    /**
     플레이어의 현재 재생부 변경
     - Parameters:
        - seconds: 현재 재생중인 시간
     */
    func changedNowPlaySeconds(seconds: Float64) {
        self.frameSliderView?.nowPlayValue = seconds
        self.frameSliderView?.refreshLayerFrames()
        
        if((self.frameSliderView?.highValue)! < seconds){
            self.playerView.seekVideo(toPos: CGFloat((self.frameSliderView?.lowValue)!))
        }
    }
    
    /**
     플레이어 재생상태 변경에 따른 재생버튼 텍스트 변경
     - Parameters:
        - isNowPlaying: true-재생중, false-정지
     */
    func changedPlayStatus(isNowPlaying:Bool){
        DispatchQueue.main.async {
            if isNowPlaying {
                self.buttonPlayStatus.setTitle("정지", for: UIControlState.normal)
            }else{
                self.buttonPlayStatus.setTitle("재생", for: UIControlState.normal)
            }
        }
    }
    
    /// 프레임 슬라이더의 값 변경에 따른 비디오 재생영역 변경
    @objc func rangeSliderValueChanged(_ slider: DolfuFrameSlider) {
        if(slider.lowLayerIsSelected) {
            self.playerView.seekVideo(toPos: CGFloat(slider.lowValue))
        } else {
            self.playerView.seekVideo(toPos: CGFloat(slider.highValue))
        }
        
        setTimeRangeText(startTime: slider.lowValue, endTime: slider.highValue)
    }
    
    /// 프레임 슬라이더에 의해 시작시간, 종료시간이 변경됨에 따른 표시값 변경
    func setTimeRangeText(startTime:Double, endTime:Double){
        DispatchQueue.main.async {
            self.labelTimeRange.text = "\(NumberConvertClass.roundCGFloat(value: CGFloat(startTime), roundUnit: 2))초 ~ \(NumberConvertClass.roundCGFloat(value: CGFloat(endTime), roundUnit: 2))초"
        }
    }
    
    /// 재생상태 변경 버튼 클릭 이벤트
    @IBAction func clickChangePlayingStatus(_ sender: Any) {
        self.playerView.doChangePlayingStatus()
    }
    
    /// 컬러필터 추가 버튼 클릭 이벤트
    @IBAction func clickFilterAdd(_ sender: Any) {
        let filterPickerVC = self.storyboard!.instantiateViewController(withIdentifier: "filterPickerVC") as! FilterPickerViewController
        filterPickerVC.phAsset = originPHAsset
        filterPickerVC.receivedSelectedFilterName = playerView.getNowFilterName()
        filterPickerVC.delegate = self
        filterPickerVC.modalPresentationStyle = .popover
        filterPickerVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width, height: 110)
        filterPickerVC.popoverPresentationController?.permittedArrowDirections = .down
        filterPickerVC.popoverPresentationController?.delegate = self
        filterPickerVC.popoverPresentationController?.sourceView = buttonsBackgroundView
        filterPickerVC.popoverPresentationController?.sourceRect = buttonsBackgroundView.bounds
        self.present(filterPickerVC, animated: true, completion: nil)
    }
    
    /// FickerPickerViewDelegate - filter 적용
    func changeCIFilter(ciFilter: CIFilter?) {
        guard ciFilter != nil else {
            playerView.removeFilterFromAVPlayerItem()
            return
        }
        playerView.setNewFilter(ciFilter: ciFilter!)
    }
    
    /// FickerPickerViewDelegate - filter 제거
    func removeCIFilter() {
        playerView.removeFilterFromAVPlayerItem()
    }
    
    /**
     상단 NEXT 버튼 클릭 이벤트
     - Result: present OutputViewController
     */
    @IBAction func clickNext(_ sender: Any) {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "outputVC") as! OutputViewController
        viewController.applyFilter = playerView.getNowFilter()
        viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        viewController.avAsset = self.originAVAsset//playerView.getOriginAVAsset()
        viewController.startTime = Double((frameSliderView?.lowValue)!)
        viewController.endTime = Double((frameSliderView?.highValue)!)
        self.present(viewController, animated: true, completion: nil)
    }
    
    /**
     상단 BACK 버튼 클릭 이벤트
     - Result: self dismiss
     */
    @IBAction func clickBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}