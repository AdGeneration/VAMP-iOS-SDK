//
//  VideoSingle2ViewController.swift
//  RewardSampleForSwift
//
//  Created by AdGeneration on 2017/02/21.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import Foundation
import VAMP
import AVFoundation

class VideoSingle2ViewController:UIViewController, VAMPDelegate {
    
    @IBOutlet var adcodeField:UITextField!
    @IBOutlet var adLogView:UITextView!
    @IBOutlet var adShowButton:UIButton!
    
    let pubId:String! = "*****" // 広告枠IDを設定してください
    
    var adReward:VAMP!
    var soundOffButton:UIButton!
    var soundOnButton:UIButton!
    var soundPlayer:AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テストモード確認
        print("isTestMode:" + String(VAMP.isTestMode()))
        
        // デバッグモード確認
        print("isDebugMode:" + String(VAMP.isDebugMode()))
        
        // TextViewを上寄せで表示
        self.automaticallyAdjustsScrollViewInsets = false
        
        // PUBIDをラベルに表示
        if (self.pubId.characters.count > 0) {
            self.adcodeField.text = self.pubId
        } else {
            self.adcodeField.text = "pubID無し"
        }
        
        // ログのViewをクリア
        self.adLogView.text = ""
        self.adLogView.isEditable = false
        
        // ナビゲーションのボタンを設定
        self.soundOffButton = UIButton()
        self.soundOffButton.setBackgroundImage(UIImage(named:"soundOn"), for: UIControlState.normal)
        self.soundOffButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.soundOffButton.addTarget(self, action:#selector(self.soundOff), for: UIControlEvents.touchUpInside)
        
        self.soundOnButton = UIButton()
        self.soundOnButton.setBackgroundImage(UIImage(named:"soundOff"), for: UIControlState.normal)
        self.soundOnButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.soundOnButton.addTarget(self, action:#selector(self.soundOn), for: UIControlEvents.touchUpInside)
        
        let barButton = UIBarButtonItem(customView:self.soundOnButton)
        self.navigationItem.rightBarButtonItem = barButton
        
        // 再生する音声を追加
        let soundPath = Bundle.main.path(forResource: "invisible", ofType: "mp3")
        let soundUrl:NSURL? = NSURL(fileURLWithPath: soundPath!)
        do {
            // Fallback on earlier versions
            self.soundPlayer = try AVAudioPlayer(contentsOf: soundUrl! as URL)
            self.soundPlayer.prepareToPlay()
        } catch {
            // 音声読み込み失敗
            print(error)
        }
        
        self.adReward = VAMP()
        
        self.adReward.setPlacementId(self.pubId)
        self.adReward.delegate = self
        self.adReward.setRootViewController(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func soundOff()
    {
        self.navigationItem.rightBarButtonItem?.customView = self.soundOnButton
        self.soundPlayer.pause()
    }
    
    @objc func soundOn()
    {
        self.navigationItem.rightBarButtonItem?.customView = self.soundOffButton
        self.soundPlayer.play()
    }
    
    @IBAction func loadAd(sender:AnyObject) {
        // 広告の呼び出し
        if ((self.adReward) != nil) {
            self.adReward.load()
            self.addLogText(message: "[load]\n")
            print("[VAMP]load")
        }
    }
    
    @IBAction func showAd(sender:AnyObject) {
        // 広告の表示
        if (adReward.isReady()) {
            let isShow: Bool = self.adReward.show()
            self.addLogText(message: "[show]\n")
            print("[VAMP]show")
            if (self.soundPlayer.isPlaying && isShow) {
                self.soundPlayer.pause()
            }
        }
    }
    
    func addLogText(message:String!) {
        // 現在日付を設定
        let now = NSDate()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.system
        dateFormatter.dateFormat = "MM-dd HH:mm:ss "
        
        let logmessage = dateFormatter.string(from: now as Date).appending(message)
        
        // MainThread でないとエラー
        DispatchQueue.main.async() {
            self.adLogView.text = NSString(format:"%@%@", logmessage, self.adLogView.text) as String
        };
    }
    
    // load完了して、広告表示できる状態になったことを通知します
    func vampDidReceive(_ placementId: String?,adnwName: String?) {
        guard let _placementId = placementId else { return }
        guard let _adnwName = adnwName else { return }
        
        self.addLogText(message:"vampDidReceive(\(_adnwName))\n")
        print("[VAMP]vampDidReceive(\(_adnwName)) placementId:\(_placementId)")
    }
    
    // インセンティブ付与可能になったタイミングで通知されます
    func vampDidComplete(_ placementId: String?, adnwName: String?) {
        guard let _adnwName = adnwName else { return }
        guard let _placementId = placementId else { return }
        
        self.addLogText(message:"vampDidComplete(\(_adnwName))\n")
        print("[VAMP]vampDidComplete(\(_adnwName)) placementId:\(_placementId)")
    }
    
    // 広告が閉じられた時に呼ばれます
    func vampDidClose(_ placementId: String!, adnwName: String?) {
        guard let _placementId = placementId else { return }
        guard let _adnwName = adnwName else { return }
        self.addLogText(message:"vampDidClose(\(_adnwName))\n")
        print("[VAMP]vampDidClose(\(_adnwName)) placementId:\(_placementId)")
    }
    
    // アドネットワークごとの広告取得が開始されたときに通知されます
    func vampLoadStart(_ placementId: String!, adnwName: String!) {
        guard let _placementId = placementId else { return }
        guard let _adnwName = adnwName else { return }
        self.addLogText(message:"vampLoadStart(\(_adnwName))\n")
        print("[VAMP]vampLoadStart(\(_adnwName)) placementId:\(_placementId)")
    }
    
    // アドネットワークごとの広告取得結果を通知する。（success,failedどちらも通知）
    // この通知をもとにshowしないようご注意ください。showする判定は、onReceiveを受け取ったタイミングで判断ください。
    func vampLoadResult(_ placementId: String!, success: Bool, adnwName: String!, message: String?) {
        guard let _placementId = placementId else { return }
        guard let _adnwName = adnwName else { return }
        if let _message = message {
            if (success) {
                // 成功の場合はメッセージ不要
                self.addLogText(message:"vampLoadResult(\(_adnwName) success:\(success))\n")
            } else {
                self.addLogText(message:"vampLoadResult(\(_adnwName) success:\(success) \(_message))\n")
            }
            print("[VAMP]vampLoadResult(\(_adnwName)) success:\(success) placementId:\(_placementId) message:\(_message)")
        } else {
            self.addLogText(message:"vampLoadResult(\(_adnwName) success:\(success))\n")
            print("[VAMP]vampLoadResult(\(_adnwName)) success:\(success) placementId:\(_placementId)")
        }
    }
    
    // エラー
    func vampDidFail(_ placementId: String!, error: VAMPError!) {
        guard let _placementId = placementId else { return }
        guard let codeString = error.kVAMPErrorString() else { return }
        let _failMessage = error.localizedDescription
        
        self.addLogText(message:"vampDidFail(\(_placementId))\(codeString) \(_failMessage)\n")
        print("[VAMP]vampDidFail:\(_placementId) \(codeString) \(_failMessage)")
    }
    
    // 広告準備完了から55分経つと取得した広告が表示はできてもRTBの収益は発生しません。
    // この通知を受け取ったら、もう一度loadからやり直す必要があります。
    func vampDidExpired(_ placementId: String!) {
        guard let _placementId = placementId else { return }
        self.addLogText(message:"vampDidExpired(\(_placementId))\n")
        print("[VAMP]vampDidExpired placementId:\(_placementId)")
    }
}
