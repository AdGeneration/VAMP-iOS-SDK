//
//  VideoSingleViewController.swift
//  RewardSampleForSwift
//
//  Created by AdGeneration on 2017/02/21.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import Foundation
import AVFoundation
import VAMP

class VideoSingleViewController: UIViewController, VAMPDelegate {
    
    @IBOutlet var adcodeField: UITextField!
    @IBOutlet var adLogView: UITextView!
    
    let placementId = "*****"   // 広告枠IDを設定してください
    
    var vamp: VAMP!
    var soundOffButton: UIBarButtonItem!
    var soundOnButton: UIBarButtonItem!
    var soundPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テストモードか確認します
        print("[VAMP]isTestMode:" + String(VAMP.isTestMode()))

        // デバッグモードか確認します
        print("[VAMP]isDebugMode:" + String(VAMP.isDebugMode()))
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.adcodeField.text = self.getPlacementId()
        
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
        
        // VAMPインスタンスを生成し初期化します
        self.vamp = VAMP()
        self.vamp.delegate = self
        self.vamp.setPlacementId(self.getPlacementId())
        self.vamp.setRootViewController(self)
    }
    
    @objc func soundOff() {
        self.navigationItem.rightBarButtonItem = self.soundOnButton
        self.soundPlayer.pause()
    }
    
    @objc func soundOn() {
        self.navigationItem.rightBarButtonItem = self.soundOffButton
        self.soundPlayer.play()
    }
    
    func getPlacementId() -> String {
        return placementId
    }
    
    @IBAction func loadAd(sender: AnyObject) {
        // 広告の読み込みを開始します
        self.vamp.load()
        
        self.addLogText("[load]")
    }
    
    @IBAction func showAd(sender: AnyObject) {
        // 広告の準備ができているか確認してから表示してください
        if (self.vamp.isReady()) {
            let success = self.vamp.show()
            
            self.addLogText("[show]")
            
            if (self.soundPlayer.isPlaying && success) {
                self.soundPlayer.pause()
            }
        } else {
            print("[VAMP]not ready")
        }
    }
    
    @IBAction func clearLoadedAd(_ sender: Any) {
        self.vamp.clearLoaded()
        
        self.addLogText("[clear]")
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

