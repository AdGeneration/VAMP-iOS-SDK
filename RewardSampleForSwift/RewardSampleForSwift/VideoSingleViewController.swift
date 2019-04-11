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
    
    /**
     広告枠IDを設定してください
     59755 : iOSテスト用ID (このIDのままリリースしないでください)
     */
    let placementId = "59755"
    
    var vamp: VAMP!
    
    var soundOffButton: UIBarButtonItem!
    var soundOnButton: UIBarButtonItem!
    var soundPlayer: AVAudioPlayer!
    var isPlayingPrev = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テストモード確認するためログ出力
        print("[VAMP]isTestMode:" + String(VAMP.isTestMode()))

        // デバッグモード確認するためログ出力
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
        self.addLogText("[load]")
        
        // 広告の読み込みを開始します
        self.vamp.load()
    }
    
    @IBAction func showAd(sender: AnyObject) {
        // 広告の準備ができているか確認してから表示してください
        if (self.vamp.isReady()) {
            self.addLogText("[show]")
            self.pauseSound()

            // 広告を表示
            self.vamp.show()
        } else {
            print("[VAMP]not ready")
        }
    }
    
    func addLogText(_ message: String, color: UIColor) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.system
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        
        let attributedNow = NSAttributedString.init(string: String.init(format: "%@ ", timestamp), attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray])
        let attributedMessage = NSAttributedString.init(string: String.init(format: "%@\n", message), attributes: [NSAttributedStringKey.foregroundColor : color])
        
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
    
    // 広告取得完了
    // 広告表示が可能になると通知されます
    func vampDidReceive(_ placementId: String, adnwName: String) {
        self.addLogText("vampDidReceive(\(adnwName), \(placementId))")
    }
    
    // 広告取得失敗
    // 広告が取得できなかったときに通知されます。
    // 例）在庫が無い、タイムアウトなど
    // @see https://github.com/AdGeneration/VAMP-iOS-SDK/wiki/VAMP-iOS-API-Errors
    func vamp(_ vamp: VAMP, didFailToLoadWithError error: VAMPError, withPlacementId placementId: String?) {
        if let bindPid = placementId {
            self.addLogText("vampDidFailToLoad(\(error.localizedDescription), \(bindPid))", color: UIColor.red)

            let code = VAMPErrorCode(rawValue: UInt(error.code))
            if code == .noAdStock {
                // 在庫が無いので、再度loadをしてもらう必要があります。
                // 連続で発生する場合、時間を置いてからloadをする必要があります。
                print("[VAMP]vampDidFailToLoad(noAdStock, \(error.localizedDescription))")
            } else if code == .noAdnetwork {
                // アドジェネ管理画面でアドネットワークの配信がONになっていない、
                // またはEU圏からのアクセスの場合(GDPR)に発生します。
                print("[VAMP]vampDidFailToLoad(noAdnetwork, \(error.localizedDescription))")
            } else if code == .needConnection {
                // ネットワークに接続できない状況です。
                // 電波状況をご確認ください。
                print("[VAMP]vampDidFailToLoad(needConnection, \(error.localizedDescription))")
            } else if code == .mediationTimeout {
                // アドネットワークSDKから返答が得られず、タイムアウトしました。
                print("[VAMP]vampDidFailToLoad(mediationTimeout, \(error.localizedDescription))")
            }
        }
    }
    
    // 広告表示失敗
    // show実行したが、何らかの理由で広告表示が失敗したときに通知されます。
    // 例）ユーザーが広告再生を途中でキャンセルなど
    func vamp(_ vamp: VAMP, didFailToShowWithError error: VAMPError, withPlacementId placementId: String) {
        self.addLogText("vampDidFailToShow(\(error.localizedDescription), \(placementId))", color: UIColor.red)
        
        let code = VAMPErrorCode(rawValue: UInt(error.code))
        if (code == .userCancel) {
            // ユーザが広告再生を途中でキャンセルしました。
            // AdMobは動画再生の途中でユーザーによるキャンセルが可能
            print("[VAMP]vampDidFailToShow(userCancel, \(error.localizedDescription))");
        } else if (code == .notLoadedAd) {
            print("[VAMP]vampDidFailToShow(notLoadedAd, \(error.localizedDescription))");
        }
        
        self.resumeSound()
    }
    
    // インセンティブ付与OK
    // インセンティブ付与が可能になったタイミングで通知
    // アドネットワークによって通知タイミングが異なる（動画再生完了時、またはエンドカードを閉じたタイミング）
    func vampDidComplete(_ placementId: String, adnwName: String) {
        self.addLogText("vampDidComplete(\(adnwName), \(placementId))", color: UIColor.blue)
    }
    
    // 広告閉じる
    // エンドカード閉じる、途中で広告再生キャンセル
    func vampDidClose(_ placementId: String, adnwName: String) {
        self.addLogText("vampDidClose(\(adnwName), \(placementId))", color: UIColor.black)
        self.resumeSound()
    }

    // 広告準備完了から55分経つと取得した広告の表示はできてもRTBの収益は発生しません。
    // この通知を受け取ったら、もう一度loadからやり直す必要があります
    func vampDidExpired(_ placementId: String) {
        self.addLogText("vampDidExpired(\(placementId))", color: UIColor.red)
    }

    // 広告取得開始
    // アドネットワークの広告取得が開始されたときに通知されます
    func vampLoadStart(_ placementId: String, adnwName: String) {
        self.addLogText("vampLoadStart(\(adnwName), \(placementId))")
    }
    
    // アドネットワークの広告取得結果が通知されます。成功時はsuccess=YESとなりロード処理は終了します。
    // success=NOのとき、次位のアドネットワークがある場合はロード処理は継続されます
    func vampLoadResult(_ placementId: String, success: Bool, adnwName: String, message: String?) {
        if success {
            self.addLogText("vampLoadResult(\(adnwName), \(placementId), success:OK)", color: UIColor.black)
        } else {
            let msg = message != nil ? message! : ""
            self.addLogText("vampLoadResult(\(adnwName), \(placementId), success:NG, \(msg))", color: UIColor.red)
        }
    }
    
    // 状態が変化したときに通知されます
    func vampDidChange(_ oldState: VAMPState, into newState: VAMPState, withPlacementId placementId: String?) {
//        let oldStateStr = self.vampStateString(oldState)
//        let newStateStr = self.vampStateString(newState)
//
//        self.addLogText("vampDidChangeState(\(oldStateStr) -> \(newStateStr), \(placementId))")
    }
}
