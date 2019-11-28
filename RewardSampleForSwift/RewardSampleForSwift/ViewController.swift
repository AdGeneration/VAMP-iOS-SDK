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
        // 連携アドネットワーク（AdMob、FAN、maio、nend、UnityAds、Mintegral、MoPub）
        // リリースする際は必ずコメントアウトしてください。収益が発生しない広告が配信されます
        VAMP.setTestMode(true)
        
        // デバッグモード
        // 連携アドネットワーク（AppLovin、UnityAds、FAN、nend、Vungle、Tapjoy、MoPub、TikTok）
        VAMP.setDebugMode(true)
        
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
        
        let vampConfiguration = VAMPConfiguration.default()
        vampConfiguration.isPlayerCancelable = true
        vampConfiguration.playerAlertTitleText = "動画を終了しますか？"
        vampConfiguration.playerAlertBodyText = "報酬がもらえません"
        vampConfiguration.playerAlertCloseButtonText = "動画を終了"
        vampConfiguration.playerAlertContinueButtonText = "動画を再開"
        
        let appV = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        guard let appVersion = appV else { return }
        
        // VAMPのSDKバージョン
        let sdkVersion = VAMP.sdkVersion()
        
        self.sdkVersion.text = "APP \(appVersion)(Swift)\nSDK \(sdkVersion)"
        
        // 国コードの取得サンプル
        VAMP.getLocation { [weak self] (location: VAMPLocation) in
            if let weakSelf = self {
                weakSelf.sdkVersion.text = "\(weakSelf.sdkVersion.text!) / \(location.countryCode) - \(location.region)"
                
                // アメリカ
                if location.countryCode == "US" {
                    // COPPA対象ユーザである場合はYESを設定する
                    // VAMP.setChildDirected(true);
                    
                    if location.region == "CA" {
                        // カリフォルニア州 (California)
                        // CCPA (https://www.caprivacy.org/)
                    } else if location.region == "NV" {
                        // ネバダ州 (Nevada)
                    }
                }
                
                // 日本
                if location.countryCode == "JP" {
                    if location.region == "13" {
                        // 東京都
                    } else if location.region == "27" {
                        // 大阪府
                    }
                }
            }
        }

        // EU圏内ならばユーザに同意を求めるサンプル
        VAMP.isEUAccess { access in
            if !access {
                // Nothing to do
                return
            }

            let alert = UIAlertController(title: "Personalized Ads", message: "Accept?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Accept", style: .default) { action in
                VAMP.setUserConsent(VAMPConsentStatus.accepted)
            })

            alert.addAction(UIAlertAction(title: "Deny", style: .destructive) { action in
                VAMP.setUserConsent(VAMPConsentStatus.denied)
            })

            self.present(alert, animated: true, completion: nil)
        }
    }
}

