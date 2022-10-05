//
//  Ad1ViewController.swift
//  VAMPSwiftSample
//
//  Created by Supership Inc. on 2019/04/15.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

import AVFoundation
import UIKit

// VAMP SDKのインポート

import VAMP

class Ad1ViewController: UIViewController {

    // 広告枠IDを設定してください
    //   59755 : iOSテスト用ID (このIDのままリリースしないでください)
    let placementId = "59755"

    @IBOutlet weak var placementLabel: UILabel!
    @IBOutlet weak var logTextView:    UITextView!
    var soundOffButton: UIBarButtonItem!
    var soundOnButton:  UIBarButtonItem!
    var soundPlayer:    AVAudioPlayer!
    var isPlayingPrev = false
    // VAMPRewardedAdオブジェクト
    var rewardedAd:           VAMPRewardedAd!

    class func instantiate() -> Ad1ViewController {
        let storyboard     = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Ad1")
        return viewController as! Ad1ViewController
    }

    override func loadView() {
        super.loadView()

        let soundOnImage = UIImage(named: "soundon")?.withRenderingMode(.alwaysOriginal)
        soundOffButton = UIBarButtonItem(image: soundOnImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(soundOff))

        let soundOffImage = UIImage(named: "soundoff")?.withRenderingMode(.alwaysOriginal)
        soundOnButton = UIBarButtonItem(image: soundOffImage,
                                        style: .plain,
                                        target: self,
                                        action: #selector(soundOn))

        navigationItem.rightBarButtonItem = soundOnButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Ad1"

        placementLabel.text = "Placement ID: \(placementId)"

        if let path = Bundle.main.path(forResource: "invisible", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)

            soundPlayer = try! AVAudioPlayer(contentsOf: url)
            soundPlayer.prepareToPlay()
        }

        addLogText("TestMode:\(VAMP.isTestMode()) DebugMode:\(VAMP.isDebugMode())")
        print("[VAMP]isTestMode:\(VAMP.isTestMode())")
        print("[VAMP]isDebugMode:\(VAMP.isDebugMode())")

        // VAMPRewardedAdインスタンスを生成し初期化
        rewardedAd = VAMPRewardedAd(placementID: placementId)
        rewardedAd.delegate = self
    }

    // MARK: - IBAction

    @IBAction func loadButtonPressed(sender: Any) {
        addLogText("[load]")

        // 広告の読み込みを開始
        let request = VAMPRequest()
        rewardedAd.load(request)
    }

    @IBAction func showButtonPressed(sender: Any) {
        // 広告の準備ができているか確認してから表示
        if (rewardedAd.isReady) {
            addLogText("[show]")
            pauseSound()

            // 広告の表示
            rewardedAd.show(from: self)
        }
        else {
            print("[VAMP]not ready")
        }
    }

    @objc func soundOff() {
        navigationItem.rightBarButtonItem = soundOnButton
        soundPlayer.pause()
    }

    @objc func soundOn() {
        navigationItem.rightBarButtonItem = soundOffButton
        soundPlayer.play()
    }

    // MARK: - private method

    func addLogText(_ message: String, color: UIColor) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.system
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())

        let attributedNow     = NSAttributedString(string: "\(timestamp) ", attributes: [.foregroundColor: UIColor.gray])
        let attributedMessage = NSAttributedString(string: "\(message)\n", attributes: [.foregroundColor: color])

        DispatchQueue.main.async() {
            let mutableAttributedString = NSMutableAttributedString()
            mutableAttributedString.append(attributedNow)
            mutableAttributedString.append(attributedMessage)
            mutableAttributedString.append(self.logTextView.attributedText)
            self.logTextView.attributedText = mutableAttributedString
        }

        print("[VAMP]\(timestamp) \(message)")
    }

    func addLogText(_ message: String) {
        addLogText(message, color: .gray)
    }

    func pauseSound() {
        isPlayingPrev = soundPlayer.isPlaying

        if (soundPlayer.isPlaying) {
            soundPlayer.pause()
        }
    }

    func resumeSound() {
        if isPlayingPrev {
            soundPlayer.play()
        }
    }
}

extension Ad1ViewController: VAMPRewardedAdDelegate {

    // 広告取得完了
    //
    // 広告表示が可能になると通知されます
    func rewardedAdDidReceive(_ rewardedAd: VAMPRewardedAd) {
        addLogText("rewardedAdDidReceive()")
    }

    // 広告取得失敗
    //
    // 広告が取得できなかったときに通知されます。例）在庫が無い、タイムアウトなど
    func rewardedAd(_ rewardedAd: VAMPRewardedAd, didFailToLoadWithError error: VAMPError) {
        addLogText("vampDidFailToLoad(\(error.localizedDescription))", color: .red)

        let code = VAMPErrorCode(rawValue: UInt(error.code))

        if code == .noAdStock {
            // 在庫が無いので、再度loadをしてもらう必要があります。
            // 連続で発生する場合、時間を置いてからloadをする必要があります。
            print("[VAMP]didFailToLoadWithError(noAdStock, \(error.localizedDescription))")
        }
        else if code == .noAdnetwork {
            // アドジェネ管理画面でアドネットワークの配信がONになっていない、
            // またはEU圏からのアクセスの場合(GDPR)に発生します。
            print("[VAMP]didFailToLoadWithError(noAdnetwork, \(error.localizedDescription))")
        }
        else if code == .needConnection {
            // ネットワークに接続できない状況です。
            // 電波状況をご確認ください。
            print("[VAMP]didFailToLoadWithError(needConnection, \(error.localizedDescription))")
        }
        else if code == .mediationTimeout {
            // アドネットワークSDKから返答が得られず、タイムアウトしました。
            print("[VAMP]didFailToLoadWithError(mediationTimeout, \(error.localizedDescription))")
        }
    }

    // 広告表示失敗
    //
    // showを実行したが、何らかの理由で広告表示が失敗したときに通知されます。
    // 例）ユーザーが広告再生を途中でキャンセルなど
    func rewardedAd(_ rewardedAd: VAMPRewardedAd, didFailToShowWithError error: VAMPError) {
        addLogText("didFailToShowWithError(\(error.localizedDescription))", color: .red)

        let code = VAMPErrorCode(rawValue: UInt(error.code))

        if (code == .userCancel) {
            // ユーザが広告再生を途中でキャンセルしました。
            // AdMobは動画再生の途中でユーザーによるキャンセルが可能
            print("[VAMP]didFailToShowWithError(userCancel, \(error.localizedDescription))");
        }
        else if (code == .notLoadedAd) {
            print("[VAMP]didFailToShowWithError(notLoadedAd, \(error.localizedDescription))");
        }

        resumeSound()
    }

    // インセンティブ付与OK
    //
    // インセンティブ付与が可能になったタイミングで通知されます。
    // アドネットワークによって通知タイミングは異なります（動画再生完了時、またはエンドカードを閉じたタイミング）
    func rewardedAdDidComplete(_ rewardedAd: VAMPRewardedAd) {
        addLogText("rewardedAdDidComplete()", color: .blue)
    }

    // 広告表示終了
    //
    // エンドカードが閉じられたとき、または途中で広告再生がキャンセルされたときに通知されます
    func rewardedAd(_ rewardedAd: VAMPRewardedAd, didCloseWithClickedFlag clickedFlag: Bool) {
        addLogText("didCloseWithClickedFlag(Click:\(clickedFlag))", color: .black)
        resumeSound()
    }

    // 広告の有効期限切れ
    //
    // 広告取得完了から55分経つと取得した広告の表示はできてもRTBの収益は発生しません。
    // この通知を受け取ったら、もう一度loadからやり直してください
    func rewardedAdDidExpire(_ rewardedAd: VAMPRewardedAd) {
        addLogText("rewardedAdDidExpire()", color: .red)
    }

    // ロード処理のプログレス通知
    //
    // アドネットワークの広告取得が開始されたときに通知されます
    func rewardedAd(_ rewardedAd: VAMPRewardedAd, didStartLoadingAd adNetworkName: String) {
        addLogText("didStartLoadingAd(\(adNetworkName))")
    }

    // ロード処理のプログレス通知
    //
    // アドネットワークの広告取得結果が通知されます。成功時はerror==nilとなりロード処理は終了します。
    // error!=nilのときは次位のアドネットワークがある場合はロード処理が継続されます
    func rewardedAd(_ rewardedAd: VAMPRewardedAd, didLoadAd adNetworkName: String, withError error: VAMPError?) {
        if let err = error {
            addLogText("didLoadAd(\(adNetworkName), success:NG, \(err.description))", color: .red)
        }
        else {
            addLogText("didLoadAd(\(adNetworkName), success:OK)", color: .black)
        }
    }
}
