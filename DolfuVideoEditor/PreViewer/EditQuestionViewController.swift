//
//  EditQuestionViewController.swift
//  DolfuVideoEditor
//
//  Created by 김효빈 on 2018. 3. 24..
//  Copyright © 2018년 김효빈. All rights reserved.
//

import UIKit
import AVKit
import DolfuAVPlayer

/// ViewController의 collectionView의 Cell을 선택시 출력되는 미리보기 화면
class EditQuestionViewController: UIViewController, DolfuAVPlayerViewDelegate {
    
    /// EditQuestionViewDelegate
    public var delegate:EditQuestionViewDelegate? = nil
    
    /// 미리보기화면에 출력할 asset
    var avAsset:AVAsset? = nil

    /// 미리보기화면에서 asset을 재생시키기위한 View
    @IBOutlet weak var playerView: DolfuAVPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async {
            self.initPlayerView()
            self.playerView.doPlayingAtAVPlayer()
        }
    }
    
    /// viewDidDisappear - 현재 컨트롤러가 disappear될경우 player 멈춤
    override func viewDidDisappear(_ animated: Bool) {
        playerView.doPauseAtAVPlayer()
    }
    
    /// PlayerView initialize
    func initPlayerView(){
        let tempAsset = avAsset!
        playerView.setAVAsset(avAsset: tempAsset)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapOnVideoLayer))
        self.playerView.addGestureRecognizer(tap)
        self.tapOnVideoLayer(tap: tap)
    }
    
    /// PlayerView가 터치되었을때 - Player의 재생상태 변경
    @objc func tapOnVideoLayer(tap: UITapGestureRecognizer)
    {
        self.playerView.doChangePlayingStatus()
    }
    
    /// 편집시작버튼 클릭 이벤트
    @IBAction func clickEditStart(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.clickEditStartFromEditQuestionVC()
    }
    
    /// 취소버튼 클릭 이벤트
    @IBAction func clickCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
