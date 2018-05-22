//
//  ViewController.swift
//  RewardSampleForSwift
//
//  Created by AdGeneration on 2017/02/21.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import UIKit
import VAMP

class ViewController: UIViewController {
    
    @IBOutlet weak var sdkVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // VAMPが対応するiOSの最低バージョン
        print("[VAMP]supportedOSVersion:\(VAMP.supportedOSVersion())")

        // テストモード
        // 連携アドネットワーク（AdMob、AppLovin、FAN、maio、nend、UnityAds）
        // リリースする際は必ずコメントアウトしてください。収益が発生しない広告が配信されます
//        VAMP.setTestMode(true)

        // デバッグモード
        // 連携アドネットワーク（AppLovin、UnityAds、FAN、nend、Vungle、Tapjoy）
//        VAMP.setDebugMode(true)
        
        // ユーザ属性の設定
//        // 誕生日
//        var components = DateComponents()
//        components.year = 1980
//        components.month = 2
//        components.day = 20
//        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
//        let birthday = calendar.date(from: components)
//        VAMP.setBirthday(birthday)
//        // 性別
//        VAMP.setGender(.male)
        
        /* アドネットワークSDK　初期化メディエーション */
        // initializeAdnwSDKを使う場合は、初期化が終わる前にAD画面へ遷移してloadしないようご注意ください。
        // ├ ステータス設定。デフォルトAUTO
        //    VAMPInitializeState.AUTO      接続環境によって、WEIGHTとALL設定を自動的に切り替える（Wi-Fi:ALL、キャリア回線:WEIGHT）
        //    VAMPInitializeState.WEIGHT    配信比率が高いものをひとつ初期化する
        //    VAMPInitializeState.ALL       全アドネットワークを初期化する
        //    VAMPInitializeState.WIFIONLY  Wi-Fi接続時のみ全アドネットワークを初期化する
        // └ アドネットワークのSDKを初期化する間隔（秒数）
        //   duration:秒単位で指定する。最小4秒、最大60秒。デフォルトは10秒。（対象:AppLovin、maio、UnityAds、Vungle）
//        VAMP().initializeAdnwSDK("*****", initializeState: .AUTO, duration: 5)  // 広告枠IDを設定してください
//        print("[VAMP]initilizedAdnwSDK")
        
        let appV = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        guard let appVersion = appV else { return }
        
        // VAMPのSDKバージョン
        let sdkVersion = VAMP.sdkVersion()
        
        self.sdkVersion.text = "APP \(appVersion)(Swift)\nSDK \(sdkVersion)"
        
        // 国コードの取得サンプル
        VAMP.getCountryCode { [weak self] (countryCode: String?) in
            if let weakSelf = self {
                weakSelf.sdkVersion.text = "\(weakSelf.sdkVersion.text!) / \(countryCode!)"
            }
        }

        // EU圏内ならばユーザに同意を求めるサンプル
//        VAMP.isEUAccess { access in
//            if !access {
//                // Nothing to do
//                return
//            }
//
//            let alert = UIAlertController(title: "Personalized Ads", message: "Accept?", preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Accept", style: .default) { action in
//                VAMP.setUserConsent(VAMPConsentStatus.accepted)
//            })
//
//            alert.addAction(UIAlertAction(title: "Deny", style: .destructive) { action in
//                VAMP.setUserConsent(VAMPConsentStatus.denied)
//            })
//
//            self.present(alert, animated: true, completion: nil)
//        }
    }
}

