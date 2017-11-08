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

class InfoViewController:UIViewController {
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var adInfoView: UITextView!
    
    override func viewDidLoad() {
        // TextViewを上詰めで表示
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        // 通知は消す。
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewDidLayoutSubviews() {
        // TextViewを上詰めで表示
        self.automaticallyAdjustsScrollViewInsets = false
        
        // AppLovin SDK Version
        adInfoView.text = "AppLovinSDK：\(ALSdk.version())"
        
        // maio SDK Version
        let maioSdk:String? = Maio.sdkVersion()
        if let maioSdkVersion = maioSdk {
            adInfoView.text.append("\nmaioSDK：\(maioSdkVersion)")
        }
        
        // UnityAds SDK Version
        adInfoView.text.append("\nUnityAdsSDK：\(UnityAds.getVersion())")
        
        // Vungle SDK Version
        adInfoView.text.append("\nVungleSDK：\(VungleSDKVersion)")
        
        // nend SDK Version
        adInfoView.text.append("\nnendSDK：\(ADNWVersionHelper.nendVersion())")
        
        // FAN SDK Version
        adInfoView.text.append("\nFAN SDK：\(FB_AD_SDK_VERSION)")
        
        // Tapjoy SDK Version
        adInfoView.text.append("\nTapjoySDK：\(Tapjoy.getVersion()!)")
        
        // Admob SDK Version
        adInfoView.text.append("\nAdmobSDK：\(ADNWVersionHelper.admobVersion())\n")
        
        // デバイス名
        let deviceName:String? = UIDevice.current.name
        if let myDeviceName = deviceName {
            adInfoView.text.append("\ndevice name：" + myDeviceName)
        }
        
        // OS名
        let osName:String? = UIDevice.current.systemName
        guard let myOsName = osName else { return }
        adInfoView.text.append("\nsystem name：" + myOsName)
        
        // OSバージョン
        let osVersion:String? = UIDevice.current.systemVersion
        if let myOsVersion = osVersion {
            adInfoView.text.append("\nsystem version：" + myOsVersion)
        }
        
        // OSモデル
        let osModel:String? = UIDevice.current.model
        if let myOsModel = osModel {
            adInfoView.text.append("\nOS model：" + myOsModel)
        }
        
        // キャリア情報
        let carrier:String? = CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName
        if let carrierName = carrier {
            adInfoView.text.append("\ncarrier name：" + carrierName)
        }
        
        // 国コード
        let isoCountry:String? = CTTelephonyNetworkInfo().subscriberCellularProvider?.isoCountryCode
        if let isoCountryCode = isoCountry {
            adInfoView.text.append("\nISO Country code：" + isoCountryCode + "\n")
        }
       
        // IDFA
        let idfa:String? = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        if let IDFA = idfa {
            adInfoView.text.append("\nIDFA：" + IDFA)
        }
        
        // IDFV
        let idfv:String? = UIDevice.current.identifierForVendor?.uuidString
        if let IDFV = idfv {
            adInfoView.text.append("\nIDFV：" + IDFV)
        }
        
        // BundleID
        let bundleId:String? = Bundle.main.bundleIdentifier
        if let BundleID = bundleId {
            adInfoView.text.append("\nBundleID：" + BundleID)
        }
        
        // 画面サイズ（ポイント）
        let screenB:CGSize? = UIScreen.main.bounds.size
        if let screenBounds = screenB {
            // 横
            let screenW:CGFloat? = screenBounds.width
            guard let screenWidth = screenW else { return }
            adInfoView.text.append("\n横幅（ポイント）：" + String(format:"%.01f", Float(screenWidth)))
            
            // 縦
            let screenH:CGFloat? = screenBounds.height
            guard let screenHeight = screenH else { return }
            adInfoView.text.append("\n縦幅（ポイント）：" + String(format:"%.01f", Float(screenHeight)))
            
            // 画面サイズ（ピクセル）
            // iOS 8.0以降で動く
            if #available(iOS 8.0, *) {
                let myNativeBoundSize:CGSize? = UIScreen.main.nativeBounds.size
                guard let myNativeBoundSizeResult = myNativeBoundSize else { return }
                adInfoView.text.append("\n横幅（ピクセル）：" + String(describing: myNativeBoundSizeResult.width))
                adInfoView.text.append("\n縦幅（ピクセル）：" + String(describing: myNativeBoundSizeResult.height))
            }
        }
        
        // 言語と地域
        let languageCode:String? = Locale.current.languageCode
        if let myLanguageCode = languageCode {
            adInfoView.text.append("\nlanguage：" + myLanguageCode)
        }
        
        let regionCode:String? = Locale.current.regionCode
        if let myRegionCode = regionCode {
            adInfoView.text.append("\nregion：" + myRegionCode)
        }
        
        // サポートOSバージョン
        let supportOSV:Float? = VAMP.supportedOSVersion()
        if let mySupportOSV = supportOSV {
            adInfoView.text.append("\nサポートOSバージョン：" + String(format:"%.01f", mySupportOSV) + "以上")
        }
        adInfoView.text.append("\nサポート対象OS：" + (VAMP.isSupportedOSVersion() ? "true" : "false"))
    }
}
