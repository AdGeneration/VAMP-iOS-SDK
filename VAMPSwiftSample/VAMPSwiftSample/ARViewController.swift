//
//  ARViewController.swift
//  VAMPSwiftSample
//
//  Created by Supership Inc. on 2021/05/14.
//  Copyright © 2021 Supership Inc. All rights reserved.
//
import AVFoundation
import UIKit

// VAMP SDKのインポート
import VAMP

class ARViewController: UIViewController {
    // 広告枠IDを設定してください
    //   59755 : iOSテスト用ID (このIDのままリリースしないでください)
    let placementId = "59755"

    @IBOutlet var placementLabel: UILabel!
    @IBOutlet var logTextView: UITextView!

    var soundOffButton: UIBarButtonItem!
    var soundOnButton: UIBarButtonItem!
    var soundPlayer: AVAudioPlayer!
    var isPlayingPrev = false
    // VAMPARAdオブジェクト
    var arAd: VAMPARAd!

    class func instantiate() -> ARViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard
            .instantiateViewController(withIdentifier: "AR")
        return viewController as! ARViewController
    }

    override func loadView() {
        super.loadView()

        let soundOnImage = UIImage(named: "soundon")?
            .withRenderingMode(.alwaysOriginal)
        soundOffButton = UIBarButtonItem(image: soundOnImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(soundOff))

        let soundOffImage = UIImage(named: "soundoff")?
            .withRenderingMode(.alwaysOriginal)
        soundOnButton = UIBarButtonItem(image: soundOffImage,
                                        style: .plain,
                                        target: self,
                                        action: #selector(soundOn))

        navigationItem.rightBarButtonItem = soundOnButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "AR"

        placementLabel.text = "Placement ID: \(placementId)"

        if let path = Bundle.main
            .path(forResource: "invisible", ofType: "mp3")
        {
            let url = URL(fileURLWithPath: path)

            soundPlayer = try! AVAudioPlayer(contentsOf: url)
            soundPlayer.prepareToPlay()
        }

        addLogText("TestMode:\(VAMP.isTestMode()) DebugMode:\(VAMP.isDebugMode())")
        print("[VAMP]isTestMode:\(VAMP.isTestMode())")
        print("[VAMP]isDebugMode:\(VAMP.isDebugMode())")

        // VAMPARAdインスタンスを生成し初期化
        arAd = VAMPARAd(placementID: placementId)
        arAd.delegate = self
    }

    // MARK: - IBAction

    @IBAction func loadButtonPressed(_ sender: Any) {
        addLogText("[load]")

        let request = VAMPRequest()
        arAd.load(request)
    }

    @IBAction func showButtonPressed(_ sender: Any) {
        // 広告の準備ができているか確認してから表示
        if arAd.isReady {
            addLogText("[show]")
            pauseSound()

            // 広告の表示
            arAd.show(from: self)
        } else {
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

        let attributedNow = NSAttributedString(string: "\(timestamp) ",
                                               attributes: [.foregroundColor: UIColor
                                                   .gray])
        let attributedMessage = NSAttributedString(string: "\(message)\n",
                                                   attributes: [.foregroundColor: color])

        DispatchQueue.main.async {
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

        if soundPlayer.isPlaying {
            soundPlayer.pause()
        }
    }

    func resumeSound() {
        if isPlayingPrev {
            soundPlayer.play()
        }
    }
}

extension ARViewController: VAMPARAdDelegate {
    // 広告の読み込み完了
    func arAd(_ arAd: VAMPARAd, didLoadWithError error: VAMPError?) {
        if let err = error {
            addLogText("didLoadWithError:(success:NG, \(err.description))",
                       color: .red)
        } else {
            addLogText("didLoadWithError(success: OK)", color: .black)
        }
    }

    // 広告表示失敗
    func arAd(_ arAd: VAMPARAd, didFailToShowWithError error: VAMPError) {
        addLogText("didFailToShowWithError(\(error.description))", color: .red)
        resumeSound()
    }

    // 広告の表示終了
    func arAd(_ arAd: VAMPARAd, didCloseWithClickedFlag clickedFlag: Bool) {
        addLogText("didCloseWithClickedFlag(Click:\(clickedFlag))",
                   color: .black)
        resumeSound()
    }

    // ユーザによってカメラアクセスが拒否された時に通知されます。
    func arAdCameraAccessNotAuthorized(_ arAd: VAMPARAd) {
        addLogText("arAdCameraAccessNotAuthorized")
    }

    func arAdDidExpire(_ arAd: VAMPARAd) {
        addLogText("arAdDidExpire", color: .red)
    }
}
