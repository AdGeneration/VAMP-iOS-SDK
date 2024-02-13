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
    @IBOutlet var placementLabel: UILabel!
    @IBOutlet var logTextView: UITextView!
    var soundOffButton: UIBarButtonItem!
    var soundOnButton: UIBarButtonItem!
    var soundPlayer: AVAudioPlayer!
    var isPlayingPrev = false
    var placementId: String = ""

    class func instantiate(with placementId: String) -> Ad1ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard
            .instantiateViewController(withIdentifier: "Ad1") as! Ad1ViewController
        viewController.placementId = placementId
        return viewController
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

        title = "Ad1"

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
    }

    // MARK: - IBAction

    @IBAction func loadButtonPressed(sender: Any) {
        addLogText("[load]")

        // 広告の読み込みを開始
        let request = VAMPRequest()
        VAMPRewardedAd.load(withPlacementID: placementId, request: request, delegate: self)
    }

    @IBAction func showButtonPressed(sender: Any) {
        // 広告の準備ができているか確認してから表示
        if let rewardedAd = VAMPRewardedAd.of(placementID: placementId) {
            addLogText("[show]")
            pauseSound()

            // 広告の表示
            rewardedAd.show(from: self, delegate: self)
        } else {
            addLogText("Not loaded")
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
}

private extension Ad1ViewController {
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

extension Ad1ViewController: VAMPRewardedAdLoadAdvancedDelegate {
    /// 広告表示が可能になると通知されます。
    ///
    /// - Parameter placementID: 広告枠ID
    func rewardedAdDidReceive(withPlacementID placementID: String) {
        addLogText("didReceive(\(placementID))")
    }

    /// 広告の取得に失敗すると通知されます。
    ///
    /// 例) 広告取得時のタイムアウトや、全てのアドネットワークの在庫がない場合など。
    ///
    /// EU圏からのアクセスの場合( `VAMPErrorCodeNoAdnetwork` )が発生します。2018-05-23現在 ※本仕様は変更する可能性があります。
    ///
    /// - Parameters:
    ///   - placementID: 広告枠ID
    ///   - error: `VAMPError` オブジェクト
    func rewardedAdDidFailToLoad(withPlacementID placementID: String, error: VAMPError) {
        addLogText("didFailToLoad(\(placementID), \(error.localizedDescription))", color: .red)

        let code = VAMPErrorCode(rawValue: UInt(error.code))

        if code == .noAdStock {
            // 在庫が無いので、再度loadをしてもらう必要があります。
            // 連続で発生する場合、時間を置いてからloadをする必要があります。
        } else if code == .noAdnetwork {
            // アドジェネ管理画面でアドネットワークの配信がONになっていない、
            // またはEU圏からのアクセスの場合(GDPR)に発生します。
        } else if code == .needConnection {
            // ネットワークに接続できない状況です。
            // 電波状況をご確認ください。
        } else if code == .mediationTimeout {
            // アドネットワークSDKから返答が得られず、タイムアウトしました。
        }
    }

    /// RTBはロードが完了してから1時間経過すると、広告表示ができても無効扱いとなり、収益が発生しません。
    ///
    /// この通知を受け取ったらロードからやり直してください。
    ///
    /// - Parameter placementID: 広告枠ID
    func rewardedAdDidExpire(withPlacementID placementID: String) {
        addLogText("didExpire(\(placementID))", color: .red)
    }

    /// アドネットワークごとの広告取得が開始されたときに通知されます。
    ///
    /// - Parameters:
    ///   - adNetworkName: アドネットワーク名
    ///   - placementID: 広告枠ID
    func rewardedAdDidStartLoading(_ adNetworkName: String, withPlacementID placementID: String) {
        addLogText("didStartLoading(\(placementID), \(adNetworkName))")
    }

    /// アドネットワークごとの広告取得結果が通知されます。
    /// このイベントは、ロードの成功時、失敗時どちらの場合も通知されます。
    /// 広告のロードに成功した時は `error==nil` となりロード処理は成功終了します。
    /// `error!=nil` の時は次の配信可能なアドネットワークがある場合、ロード処理は継続されます。ない場合は失敗終了します。
    ///
    /// - Parameters:
    ///   - adNetworkName: アドネットワーク名
    ///   - placementID: 広告枠ID
    ///   - error: `VAMPError` オブジェクト
    func rewardedAdDidLoad(_ adNetworkName: String, withPlacementID placementID: String,
                           error: VAMPError?)
    {
        if let error {
            addLogText("didLoad(\(placementID), \(adNetworkName), \(error.localizedDescription))",
                       color: .red)
        } else {
            addLogText("didLoad(\(placementID), \(adNetworkName))", color: .black)
        }
    }
}

extension Ad1ViewController: VAMPRewardedAdShowDelegate {
    /// 広告の表示に失敗すると通知されます。
    ///
    /// 例) 視聴完了する前にユーザがキャンセルするなど。
    ///
    /// - Parameters:
    ///   - rewardedAd: `VAMPRewardedAd` オブジェクト
    ///   - error: `VAMPError` オブジェクト
    func rewardedAd(_ rewardedAd: VAMPRewardedAd, didFailToShowWithError error: VAMPError) {
        addLogText("didFailToShow(\(error.localizedDescription))", color: .red)

        let code = VAMPErrorCode(rawValue: UInt(error.code))

        if code == .userCancel {
            // ユーザが広告再生を途中でキャンセルしました。
            // AdMobは動画再生の途中でユーザーによるキャンセルが可能
        } else if code == .notLoadedAd {}

        resumeSound()
    }

    /// インセンティブ付与が可能になると通知されます。
    ///
    /// ※ユーザが途中で再生をスキップしたり、動画視聴をキャンセルすると発生しません。
    /// ※アドネットワークによって発生タイミングが異なります。
    ///
    /// - Parameter rewardedAd: `VAMPRewardedAd` オブジェクト
    func rewardedAdDidComplete(_ rewardedAd: VAMPRewardedAd) {
        addLogText("didComplete()", color: .systemGreen)
    }

    /// 広告の表示が開始されると通知されます。
    ///
    /// - Parameter rewardedAd: `VAMPRewardedAd` オブジェクト
    func rewardedAdDidOpen(_ rewardedAd: VAMPRewardedAd) {
        addLogText("didOpen()")
    }

    /// 広告が閉じられると通知されます。
    /// ユーザキャンセルなどの場合も通知されるため、インセンティブ付与は `VAMPRewardedAdShowDelegate#rewardedAdDidComplete:`
    /// で判定してください。
    ///
    /// - Parameters:
    ///   - rewardedAd: `VAMPRewardedAd` オブジェクト
    ///   - adClicked: 広告がクリックされたかどうか
    func rewardedAd(_ rewardedAd: VAMPRewardedAd, didCloseWithClickedFlag adClicked: Bool) {
        addLogText("didClose(adClicked:\(adClicked))", color: .systemBlue)
        resumeSound()
    }
}
