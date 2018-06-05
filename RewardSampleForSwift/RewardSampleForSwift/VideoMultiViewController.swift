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
    
    let placementId1 = "59755"  // 広告枠ID1を設定
    let placementId2 = "*****"  // 広告枠ID2を設定
    
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
        
        // 広告枠ID1用のVAMPインスタンスを生成
        self.vamp1 = VAMP()
        self.vamp1.delegate = self
        self.vamp1.setPlacementId(self.placementId1)
        self.vamp1.setRootViewController(self)
        
        // 広告枠ID2用のVAMPインスタンスを生成
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
        
        // 広告1の読み込みを開始します
        self.vamp1.load()
    }
    
    @IBAction func clickShowAd1(sender: AnyObject) {
        self.addLogText("click show ad1")
        
        // 広告の準備ができているか確認してから表示
        if (self.vamp1.isReady()) {
            self.addLogText("show ad1")
            self.pauseSound()
            
            // 広告1を再生
            self.vamp1.show()
        }
    }
    
    @IBAction func clickLoadAd2(sender: AnyObject) {
        self.addLogText("click load ad2")
        
        // 広告2の読み込みを開始
        self.vamp2.load()
    }
    
    @IBAction func clickShowAd2(sender: AnyObject) {
        self.addLogText("click show ad2")
        
        // 広告の準備ができているか確認してから表示
        if (self.vamp2.isReady()) {
            self.addLogText("show ad2")
            self.pauseSound()
            
            // 広告2を再生します
            self.vamp2.show()
        }
    }
    
    func addLogText(_ message: String, color: UIColor) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.system
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        
        let attributedNow = NSAttributedString.init(string: String.init(format: "%@ ", timestamp), attributes: [NSForegroundColorAttributeName : UIColor.gray])
        let attributedMessage = NSAttributedString.init(string: String.init(format: "%@\n", message), attributes: [NSForegroundColorAttributeName : color])
        
        DispatchQueue.main.async() {
            let mutableAttributedString = NSMutableAttributedString.init()
            mutableAttributedString.append(attributedNow)
            mutableAttributedString.append(attributedMessage)
            mutableAttributedString.append(self.adLogView.attributedText)
            self.adLogView.attributedText = mutableAttributedString
        }
        
        print("[VAMP]\(timestamp) \(message)")
    }
    
    func addLogText(_ message: String) {
        self.addLogText(message, color: UIColor.gray)
    }
    
    func vampStateString(_ state: VAMPState) -> String {
        switch state {
        case .idle:
            return "Idle"
        case .loading:
            return "Loading"
        case .loaded:
            return "Loaded"
        case .showing:
            return "Showing"
        }
    }
    
    func pauseSound() {
        self.isPlayingPrev = self.soundPlayer.isPlaying
        
        if (self.soundPlayer.isPlaying) {
            self.soundPlayer.pause()
        }
    }
    
    func resumeSound() {
        if self.isPlayingPrev {
            self.soundPlayer.play()
        }
    }
    
    // MARK: - VAMPDelegate
    
    // 広告表示が可能になると通知
    func vampDidReceive(_ placementId: String, adnwName: String) {
        self.addLogText("vampDidReceive(\(adnwName), \(placementId)")
    }
    
    // 全アドネットワークにおいて広告が取得できなかったときに通知
    func vamp(_ vamp: VAMP, didFailToLoadWithError error: VAMPError, withPlacementId placementId: String?) {
        if let bindPid = placementId {
            let code = VAMPErrorCode(rawValue: UInt(error.code))
            if code == .noAdStock {
                // 在庫が無いので、再度loadをしてもらう必要があります。
                // 連続で発生する場合、時間を置いてからloadをする必要があります。
                print("[VAMP]vampDidFailToLoad(noAdStock, \(error.localizedDescription))")
            } else if code == .noAdnetwork {
                // アドジェネ管理画面でアドネットワークの配信がONになっていない、
                // またはEU圏からのアクセスの場合(GDPR)発生します。
                print("[VAMP]vampDidFailToLoad(noAdnetwork, \(error.localizedDescription))")
            } else if code == .needConnection {
                // ネットワークに接続できない状況です。
                // 電波状況をご確認ください。
                print("[VAMP]vampDidFailToLoad(needConnection, \(error.localizedDescription))")
            } else if code == .mediationTimeout {
                // アドネットワークSDKから返答が得られず、タイムアウトしました。
                print("[VAMP]vampDidFailToLoad(mediationTimeout, \(error.localizedDescription))")
            }

            self.addLogText("vampDidFailToLoad(\(error.localizedDescription), \(bindPid))", color: UIColor.red)
        }
    }
    
    // 広告の表示に失敗したときに通知
    func vamp(_ vamp: VAMP, didFailToShowWithError error: VAMPError, withPlacementId placementId: String) {
        self.addLogText("vampDidFailToShow(\(error.localizedDescription), \(placementId))", color: UIColor.red)
        
        let code = VAMPErrorCode(rawValue: UInt(error.code))
        if (code == .userCancel) {
            // ユーザが広告再生を途中でキャンセルしました。
            print("[VAMP]vampDidFailToShow(userCancel, \(error.localizedDescription))");
        }
        
        self.resumeSound()
    }
    
    // インセンティブ付与可能になったタイミングで通知
    func vampDidComplete(_ placementId: String, adnwName: String) {
        self.addLogText("vampDidComplete(\(adnwName), \(placementId))", color: UIColor.blue)
    }
    
    // 広告が閉じられた時に通知
    func vampDidClose(_ placementId: String, adnwName: String) {
        self.addLogText("vampDidClose(\(adnwName), \(placementId))", color: UIColor.black)
        self.resumeSound()
    }
    
    // 広告準備完了から55分経つと取得した広告の表示はできてもRTBの収益は発生しません。
    // この通知を受け取ったら、もう一度loadからやり直す必要があります
    func vampDidExpired(_ placementId: String) {
        self.addLogText("vampDidExpired(\(placementId))", color: UIColor.red)
    }
    
    // アドネットワークの広告取得が開始されたときに通知
    func vampLoadStart(_ placementId: String, adnwName: String) {
        self.addLogText("vampLoadStart(\(adnwName), \(placementId))")
    }
    
    // アドネットワークの広告取得結果が通知されます。成功時はsuccess=YESとなりロード処理は終了
    // success=NOのとき、次位のアドネットワークがある場合はロード処理は継続されます
    func vampLoadResult(_ placementId: String, success: Bool, adnwName: String, message: String?) {
        if success {
            self.addLogText("vampLoadResult(\(adnwName), \(placementId), success:OK)", color: UIColor.black)
        } else {
            let msg = message != nil ? message! : ""
            self.addLogText("vampLoadResult(\(adnwName), \(placementId), success:NG, \(msg))", color: UIColor.red)
        }
    }
    
    // VAMPの状態が変化したときの通知
    func vampDidChange(_ oldState: VAMPState, into newState: VAMPState, withPlacementId placementId: String?) {
//        let oldStateStr = self.vampStateString(oldState)
//        let newStateStr = self.vampStateString(newState)
//
//        self.addLogText("vampDidChangeState(\(oldStateStr) -> \(newStateStr), \(placementId))")
    }
}
