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
    
    let adId1: String! = "*****"    // 広告枠ID1を設定してください
    let adId2: String! = "*****"    // 広告枠ID2を設定してください
    
    var soundOffButton: UIBarButtonItem!
    var soundOnButton: UIBarButtonItem!
    var soundPlayer: AVAudioPlayer!
    
    var vamp1: VAMP!
    var vamp2: VAMP!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.adCodeField1.text = self.adId1
        self.adCodeField2.text = self.adId2
        
        self.adLogView.text = ""
        self.adLogView.isEditable = false
        
        let soundOnImage = UIImage(named: "soundOn")?.withRenderingMode(.alwaysOriginal)
        self.soundOffButton = UIBarButtonItem.init(image: soundOnImage, style: .plain, target: self,
                                                   action: #selector(self.soundOff))
        
        let soundOffImage = UIImage(named: "soundOff")?.withRenderingMode(.alwaysOriginal)
        self.soundOnButton = UIBarButtonItem.init(image: soundOffImage, style: .plain, target: self,
                                                  action: #selector(self.soundOn))
        
        self.navigationItem.rightBarButtonItem = self.soundOnButton
        
        let soundFileUrl: NSURL? = NSURL(fileURLWithPath: Bundle.main.path(forResource: "invisible", ofType: "mp3")!)
        
        do {
            // Fallback on earlier versions
            self.soundPlayer = try AVAudioPlayer(contentsOf: soundFileUrl! as URL)
            self.soundPlayer.prepareToPlay()
        } catch {
            print(error)
        }
        
        self.vamp1 = VAMP()
        self.vamp1.setPlacementId(self.adId1)
        self.vamp1.delegate = self
        self.vamp1.setRootViewController(self)
        
        self.vamp2 = VAMP()
        self.vamp2.setPlacementId(self.adId2)
        self.vamp2.delegate = self
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
    
    func addLogText(_ message: String!) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.system
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        let log = String.init(format: "%@ %@", timestamp, message)
        
        DispatchQueue.main.async() {
            self.adLogView.text = String.init(format: "%@\n%@", log, self.adLogView.text)
        }
        
        print("[VAMP]\(log)")
    }
    
    // MARK: - VAMPDelegate
    
    // load完了して、広告表示できる状態になったことを通知します
    func vampDidReceive(_ placementId: String?, adnwName: String?) {
        guard let placementId = placementId else { return }
        guard let adnwName = adnwName else { return }
        
        self.addLogText("[\(placementId)] vampDidReceive(\(adnwName))")
    }
    
    // インセンティブ付与可能になったタイミングで通知されます
    func vampDidComplete(_ placementId: String?, adnwName: String?) {
        guard let adnwName = adnwName else { return }
        guard let placementId = placementId else { return }
        
        self.addLogText("[\(placementId)] vampDidComplete(\(adnwName))")
    }
    
    // 広告が閉じられた時に呼ばれます
    func vampDidClose(_ placementId: String!, adnwName: String?) {
        guard let placementId = placementId else { return }
        guard let adnwName = adnwName else { return }
        
        self.addLogText("[\(placementId)] vampDidClose(\(adnwName))")
    }
    
    // アドネットワークごとの広告取得が開始されたときに通知されます
    func vampLoadStart(_ placementId: String!, adnwName: String!) {
        guard let placementId = placementId else { return }
        guard let adnwName = adnwName else { return }
        
        self.addLogText("[\(placementId)] vampLoadStart(\(adnwName))")
    }
    
    // アドネットワークごとの広告取得結果を通知する。（success,failedどちらも通知）
    // この通知をもとにshowしないようご注意ください。showする判定は、onReceiveを受け取ったタイミングで判断ください。
    func vampLoadResult(_ placementId: String!, success: Bool, adnwName: String!, message: String?) {
        guard let placementId = placementId else { return }
        guard let adnwName = adnwName else { return }
        
        if let message = message {
            if (success) {
                // 成功の場合はメッセージ不要
                self.addLogText("[\(placementId)] vampLoadResult(\(adnwName) success:\(success))")
            } else {
                self.addLogText("[\(placementId)] vampLoadResult(\(adnwName) success:\(success) \(message))")
            }
        } else {
            self.addLogText("[\(placementId)] vampLoadResult(\(adnwName) success:\(success))")
        }
    }
    
    // エラー
    func vampDidFail(_ placementId: String!, error: VAMPError!) {
        guard let placementId = placementId else { return }
        guard let codeString = error.kVAMPErrorString() else { return }
        
        let failMessage = error.localizedDescription
        
        self.addLogText("[\(placementId)] vampDidFail \(codeString) \(failMessage)")
    }
    
    // 広告準備完了から55分経つと取得した広告が表示はできてもRTBの収益は発生しません。
    // この通知を受け取ったら、もう一度loadからやり直す必要があります。
    func vampDidExpired(_ placementId: String!) {
        guard let placementId = placementId else { return }
        
        self.addLogText("[\(placementId)] vampDidExpired")
    }
}

