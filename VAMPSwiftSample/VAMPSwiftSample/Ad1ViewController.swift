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
    // VAMPオブジェクト
    var vamp:           VAMP!

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

        // VAMPインスタンスを生成し初期化
        vamp = VAMP()
        vamp.delegate = self
        vamp.setPlacementId(placementId)
    }

    // MARK: - IBAction

    @IBAction func loadButtonPressed(sender: Any) {
        addLogText("[load]")

        // 広告の読み込みを開始
        vamp.load()
    }

    @IBAction func showButtonPressed(sender: Any) {
        // 広告の準備ができているか確認してから表示
        if (vamp.isReady()) {
            addLogText("[show]")
            pauseSound()

            // 広告の表示
            vamp.show(from: self)
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

extension Ad1ViewController: VAMPDelegate {

    // 広告取得完了
    //
    // 広告表示が可能になると通知されます
    func vamp(_ vamp: VAMP, didReceive ad: VAMPAd) {
        addLogText("vampDidReceive(\(ad.adnwName), \(ad.placementId))")
    }

    // 広告取得失敗
    //
    // 広告が取得できなかったときに通知されます。例）在庫が無い、タイムアウトなど
    // @see https://github.com/AdGeneration/VAMP-iOS-SDK/wiki/VAMP-iOS-API-Errorse
    func vamp(_ vamp: VAMP, didFailToLoadWithError error: VAMPError, with ad: VAMPAd) {
        addLogText("vampDidFailToLoad(\(error.localizedDescription), \(ad.placementId))", color: .red)

        let code = VAMPErrorCode(rawValue: UInt(error.code))

        if code == .noAdStock {
            // 在庫が無いので、再度loadをしてもらう必要があります。
            // 連続で発生する場合、時間を置いてからloadをする必要があります。
            print("[VAMP]vampDidFailToLoad(noAdStock, \(error.localizedDescription))")
        }
        else if code == .noAdnetwork {
            // アドジェネ管理画面でアドネットワークの配信がONになっていない、
            // またはEU圏からのアクセスの場合(GDPR)に発生します。
            print("[VAMP]vampDidFailToLoad(noAdnetwork, \(error.localizedDescription))")
        }
        else if code == .needConnection {
            // ネットワークに接続できない状況です。
            // 電波状況をご確認ください。
            print("[VAMP]vampDidFailToLoad(needConnection, \(error.localizedDescription))")
        }
        else if code == .mediationTimeout {
            // アドネットワークSDKから返答が得られず、タイムアウトしました。
            print("[VAMP]vampDidFailToLoad(mediationTimeout, \(error.localizedDescription))")
        }
    }

    // 広告表示失敗
    //
    // showを実行したが、何らかの理由で広告表示が失敗したときに通知されます。
    // 例）ユーザーが広告再生を途中でキャンセルなど
    func vamp(_ vamp: VAMP, didFailToShowWithError error: VAMPError, with ad: VAMPAd) {
        addLogText("vampDidFailToShow(\(error.localizedDescription), \(ad.placementId))", color: .red)

        let code = VAMPErrorCode(rawValue: UInt(error.code))

        if (code == .userCancel) {
            // ユーザが広告再生を途中でキャンセルしました。
            // AdMobは動画再生の途中でユーザーによるキャンセルが可能
            print("[VAMP]vampDidFailToShow(userCancel, \(error.localizedDescription))");
        }
        else if (code == .notLoadedAd) {
            print("[VAMP]vampDidFailToShow(notLoadedAd, \(error.localizedDescription))");
        }

        resumeSound()
    }

    // インセンティブ付与OK
    //
    // インセンティブ付与が可能になったタイミングで通知されます。
    // アドネットワークによって通知タイミングは異なります（動画再生完了時、またはエンドカードを閉じたタイミング）
    func vamp(_ vamp: VAMP, didComplete ad: VAMPAd) {
        addLogText("vampDidComplete(\(ad.adnwName), \(ad.placementId))", color: .blue)
    }

    // 広告表示終了
    //
    // エンドカードが閉じられたとき、または途中で広告再生がキャンセルされたときに通知されます
    func vamp(_ vamp: VAMP, didClose ad: VAMPAd, adClicked: Bool) {
        addLogText("vampDidClose(\(ad.adnwName), \(ad.placementId))", color: .black)
        resumeSound()
    }

    // 広告の有効期限切れ
    //
    // 広告取得完了から55分経つと取得した広告の表示はできてもRTBの収益は発生しません。
    // この通知を受け取ったら、もう一度loadからやり直してください
    func vamp(_ vamp: VAMP, didExpireWithPlacementId placementId: String) {
        addLogText("vampDidExpired(\(placementId))", color: .red)
    }

    // ロード処理のプログレス通知
    //
    // アドネットワークの広告取得が開始されたときに通知されます
    func vamp(_ vamp: VAMP, loadStart ad: VAMPAd) {
        addLogText("vampLoadStart(\(ad.adnwName), \(ad.placementId))")
    }

    // ロード処理のプログレス通知
    //
    // アドネットワークの広告取得結果が通知されます。成功時はsuccess=trueとなりロード処理は終了します。
    // success=falseのときは次位のアドネットワークがある場合はロード処理が継続されます
    func vamp(_ vamp: VAMP, loadResultAd ad: VAMPAd, success: Bool, message: String?) {
        if success {
            addLogText("vampLoadResult(\(ad.adnwName), \(ad.placementId), success:OK)", color: .black)
        }
        else {
            let msg = message != nil ? message! : ""
            addLogText("vampLoadResult(\(ad.adnwName), \(ad.placementId), success:NG, \(msg))", color: .red)
        }
    }
}
