//
//  InfoViewController.swift
//  RewardSampleForSwift
//
//  Created by AdGeneration on 2017/02/21.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import Foundation
import AVFoundation
import CoreTelephony
import AdSupport
import VAMP
import AppLovinSDK
import Maio
import UnityAds

class InfoViewController: UIViewController {
    
    @IBOutlet weak var adInfoView: UITextView!
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.adInfoView.text = ""
        
        // Admob SDK Version
        self.addInfoText("AdmobSDK: \(ADNWVersionHelper.admobVersion())")
        
        // AppLovin SDK Version
        self.addInfoText("AppLovinSDK: \(ALSdk.version())")
        
        // FAN SDK Version
        self.addInfoText("FAN SDK: \(FB_AD_SDK_VERSION)")
        
        // maio SDK Version
        if let maioSdkVersion = Maio.sdkVersion() {
            self.addInfoText("maioSDK: \(maioSdkVersion)")
        }
        
        // nend SDK Version
        self.addInfoText("nendSDK: \(ADNWVersionHelper.nendVersion())")
        
        // Tapjoy SDK Version
        if let tjVersion = Tapjoy.getVersion() {
            self.addInfoText("TapjoySDK: \(tjVersion)")
        }
        
        // UnityAds SDK Version
        self.addInfoText("UnityAdsSDK: \(UnityAds.getVersion())")
        
        // Vungle SDK Version
        self.addInfoText("VungleSDK: \(VungleSDKVersion)")
        
        // Mintegral SDK Version
        self.addInfoText("MintegralSDK: \(MVSDKVersion)")
        
        self.addInfoText("\n")
        
        // デバイス名
        self.addInfoText("device name: \(UIDevice.current.name)")
        
        // OS名
        self.addInfoText("system name: \(UIDevice.current.systemName)")
        
        // OSバージョン
        self.addInfoText("system version: \(UIDevice.current.systemVersion)")
        
        // OSモデル
        self.addInfoText("OS model: \(UIDevice.current.model)")
        
        // キャリア情報
        if let carrierName = CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName {
            self.addInfoText("carrier name: \(carrierName)")
        }
        
        // 国コード
        if let isoCountryCode = CTTelephonyNetworkInfo().subscriberCellularProvider?.isoCountryCode {
            self.addInfoText("ISO Country code: \(isoCountryCode)")
        }
       
        // IDFA
        if let idfa = ASIdentifierManager.shared().advertisingIdentifier?.uuidString {
            self.addInfoText("IDFA: \(idfa)")
        }
        
        // IDFV
        if let idfv = UIDevice.current.identifierForVendor?.uuidString {
            self.addInfoText("IDFV : \(idfv)")
        }
        
        // BundleID
        if let bundleId = Bundle.main.bundleIdentifier {
            self.addInfoText("BundleID: \(bundleId)")
        }
        
        // 画面サイズ（ポイント）
        let screen = UIScreen.main.bounds.size
        // 横
        self.addInfoText("横幅（ポイント）: \(String(format:"%.01f", screen.width))")
        // 縦
        self.addInfoText("縦幅（ポイント）: \(String(format:"%.01f", screen.height))")
        
        // 画面サイズ（ピクセル）
        // iOS 8.0以降で動く
        if #available(iOS 8.0, *) {
            let screen = UIScreen.main.nativeBounds.size
            self.addInfoText("横幅（ピクセル）: \(String(describing: screen.width))")
            self.addInfoText("縦幅（ピクセル）: \(String(describing: screen.height))")
        }
        
        // 言語
        if let langCode = Locale.current.languageCode {
            self.addInfoText("language: \(langCode)")
        }
        
        // 地域
        if let regionCode = Locale.current.regionCode {
            self.addInfoText("region: \(regionCode)")
        }
        
        // サポートOSバージョン
        self.addInfoText("サポートOSバージョン: \(String(format:"%.01f", VAMP.supportedOSVersion()))以上")
        self.addInfoText("サポート対象OS: \(String(VAMP.isSupportedOSVersion()))")
    }
    
    func addInfoText(_ text: String) {
        self.adInfoView.text.append("\n\(text)")
    }
}

