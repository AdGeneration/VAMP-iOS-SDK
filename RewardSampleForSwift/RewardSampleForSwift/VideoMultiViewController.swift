//
//  VideoMultiViewController.swift
//  RewardSampleForSwift
//
//  Created by AdGeneration on 2017/11/30.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import Foundation
import VAMP
import AVFoundation

class VideoMultiViewController : UIViewController, VAMPDelegate {
    
    @IBOutlet var adCodeField1: UITextField!
    @IBOutlet var adCodeField2: UITextField!
    @IBOutlet var adLogView: UITextView!
    
    let placementId1 = "*****"  // 広告枠ID1を設定してください
    let placementId2 = "*****"  // 広告枠ID2を設定してください
    
    var soundOffButton: UIBarButtonItem!
    var soundOnButton: UIBarButtonItem!
    var soundPlayer: AVAudioPlayer!
    var isPlayingPrev = false
    
    var vamp1: VAMP!
    var vamp2: VAMP!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.adCodeField1.text = self.placementId1
        self.adCodeField2.text = self.placementId2
        
        self.adLogView.text = ""
        self.adLogView.isEditable = false
        
        let soundOnImage = UIImage(named: "soundOn")?.withRenderingMode(.alwaysOriginal)
        self.soundOffButton = UIBarButtonItem.init(image: soundOnImage, style: .plain, target: self,
                                                   action: #selector(self.soundOff))
        
        let soundOffImage = UIImage(named: "soundOff")?.withRenderingMode(.alwaysOriginal)
        self.soundOnButton = UIBarButtonItem.init(image: soundOffImage, style: .plain, target: self,
                                                  action: #selector(self.soundOn))
        
        self.navigationItem.rightBarButtonItem = self.soundOnButton
        
        let soundPath = Bundle.main.path(forResource: "invisible", ofType: "mp3")
        let soundUrl = URL(fileURLWithPath: soundPath!)
        
        do {
            // Fallback on earlier versions
            self.soundPlayer = try AVAudioPlayer(contentsOf: soundUrl)
            self.soundPlayer.prepareToPlay()
        } catch {
            print(error)
        }
        
        self.vamp1 = VAMP()
        self.vamp1.delegate = self
        self.vamp1.setPlacementId(self.placementId1)
        self.vamp1.setRootViewController(self)
        
        self.vamp2 = VAMP()
        self.vamp2.delegate = self
        self.vamp2.setPlacementId(self.placementId2)
        self.vamp2.setRootViewController(self)
        
        self.addLogText("isTestMode:" + String(VAMP.isTestMode()))
        self.addLogText("isDebugMode:" + String(VAMP.isDebugMode()))
    }
    
    @objc func soundOff() {
        self.navigationItem.rightBarButtonItem = self.soundOnButton
        self.soundPlayer.pause()
    }
    
    @objc func soundOn() {
        self.navigationItem.rightBarButtonItem = self.soundOffButton
        self.soundPlayer.play()
    }
    
    @IBAction func clickLoadAd1(sender: AnyObject) {
        self.addLogText("click load ad1")
        
        self.vamp1.load()
    }
    
    @IBAction func clickShowAd1(sender: AnyObject) {
        self.addLogText("click show ad1")
        
        if (self.vamp1.isReady()) {
            self.vamp1.show()
            
            self.addLogText("show ad1")
            
            self.isPlayingPrev = self.soundPlayer.isPlaying
            
            if (self.soundPlayer.isPlaying) {
                self.soundPlayer.pause()
            }
        }
    }
    
    @IBAction func clickLoadAd2(sender: AnyObject) {
        self.addLogText("click load ad2")
        
        self.vamp2.load()
    }
    
    @IBAction func clickShowAd2(sender: AnyObject) {
        self.addLogText("click show ad2")
        
        if (self.vamp2.isReady()) {
            self.vamp2.show()
            
            self.addLogText("show ad2")
            
            if (self.soundPlayer.isPlaying) {
                self.soundPlayer.pause()
            }
        }
    }
    
    func addLogText(_ message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.system
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        let log = String.init(format: "%@ %@", timestamp, message)
        
        DispatchQueue.main.async() {
            self.adLogView.text = NSString(format: "%@\n%@", log, self.adLogView.text) as String
        }
        
        print("[VAMP]\(log)");
    }
    
    func vampStateString(_ state: VAMPState) -> String {
        switch state {
        case .idle:
            return "Idle"
        case .loading:
            return "Loading"
        case .ready:
            return "Ready"
        case .loaded:
            return "Loaded"
        case .showing:
            return "Showing"
        default:
            return "Unknown"
        }
    }
    
    // MARK: - VAMPDelegate
    
    // load完了して、広告表示できる状態になったことを通知します
    func vampDidReceive(_ placementId: String?, adnwName: String?) {
        guard let _placementId = placementId else { return }
        guard let _adnwName = adnwName else { return }
        
        self.addLogText("vampDidReceive(\(_adnwName)) placementId:\(_placementId)")
    }
    
    // エラーが発生した時に通知されます
    func vampDidFail(_ placementId: String!, error: VAMPError!) {
        guard let _placementId = placementId else { return }
        guard let codeString = error.kVAMPErrorString() else { return }
        let failMessage = error.localizedDescription
        
        self.addLogText("vampDidFail placementId:\(_placementId) \(codeString) \(failMessage)")
    }
    
    // インセンティブ付与可能になったタイミングで通知されます
    func vampDidComplete(_ placementId: String?, adnwName: String?) {
        guard let _adnwName = adnwName else { return }
        guard let _placementId = placementId else { return }
        
        self.addLogText("vampDidComplete(\(_adnwName)) placementId:\(_placementId)")
    }
    
    // 広告が閉じられた時に呼ばれます
    func vampDidClose(_ placementId: String!, adnwName: String?) {
        guard let _placementId = placementId else { return }
        guard let _adnwName = adnwName else { return }
        
        self.addLogText("vampDidClose(\(_adnwName)) placementId:\(_placementId)")
        
        if self.isPlayingPrev {
            self.soundPlayer.play()
        }
    }
    
    // アドネットワークごとの広告取得が開始された時に通知されます
    func vampLoadStart(_ placementId: String!, adnwName: String!) {
        guard let _placementId = placementId else { return }
        guard let _adnwName = adnwName else { return }
        
        self.addLogText("vampLoadStart(\(_adnwName)) placementId:\(_placementId)")
    }
    
    // アドネットワークごとの広告取得結果が通知されます（success,failedどちらも通知）。
    // この通知をもとにshowしないようご注意ください。showする判定は、vampDidReceiveを受け取ったタイミングで判断してください
    func vampLoadResult(_ placementId: String!, success: Bool, adnwName: String!, message: String?) {
        guard let _placementId = placementId else { return }
        guard let _adnwName = adnwName else { return }
        
        if (success) {
            self.addLogText("vampLoadResult(\(_adnwName)) success:\(success) placementId:\(_placementId)")
        } else {
            if let _message = message {
                self.addLogText("vampLoadResult(\(_adnwName)) success:\(success) message:\(_message) placementId:\(_placementId)")
            } else {
                self.addLogText("vampLoadResult(\(_adnwName)) success:\(success) placementId:\(_placementId)")
            }
        }
    }
    
    // 広告準備完了から55分経つと取得した広告の表示はできてもRTBの収益は発生しません。
    // この通知を受け取ったら、もう一度loadからやり直す必要があります
    func vampDidExpired(_ placementId: String!) {
        guard let _placementId = placementId else { return }
        
        self.addLogText("vampDidExpired placementId:\(_placementId)")
    }
    
    // VAMPの状態が変化したときの通知されます
    func vampDidChange(_ oldState: VAMPState, into newState: VAMPState, withPlacementId placementId: String!) {
        guard let placementId = placementId else { return }
        
        let oldStateStr = self.vampStateString(oldState)
        let newStateStr = self.vampStateString(newState)
        
        self.addLogText("vampDidChangeState \(oldStateStr) -> \(newStateStr), placementId:\(placementId)")
    }
}

