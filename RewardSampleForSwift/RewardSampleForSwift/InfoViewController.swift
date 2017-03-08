//
//  InfoViewController.swift
//  RewardSampleForSwift
//
//  Copyright © 2016年 example. All rights reserved.
//

import Foundation
import AVFoundation
import CoreTelephony
import AdSupport
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
        let alSdk:String? = ALSdk.version()
        guard let alSdkVersion = alSdk else { return }
        adInfoView.text = "AppLovinSDK：" + alSdkVersion
        
        // maio SDK Version
        let maioSdk:String? = Maio.sdkVersion()
        guard let maioSdkVersion = maioSdk else { return }
        adInfoView.text.append("\nmaioSDK：" + maioSdkVersion)
        
        // UnityAds SDK Version
        let unitySdk:String? = UnityAds.getVersion()
        guard let unitySdkVersion = unitySdk else { return }
        adInfoView.text.append("\nUnityAdsSDK：" + unitySdkVersion + "\n")
        
        // デバイス名
        let deviceName:String? = UIDevice.current.name
        guard let myDeviceName = deviceName else { return }
        adInfoView.text.append("\ndevice name：" + myDeviceName)
        
        // OS名
        let osName:String? = UIDevice.current.systemName
        guard let myOsName = osName else { return }
        adInfoView.text.append("\nsystem name：" + myOsName)
        
        // OSバージョン
        let osVersion:String? = UIDevice.current.systemVersion
        guard let myOsVersion = osVersion else { return }
        adInfoView.text.append("\nsystem version：" + myOsVersion)
        
        // OSモデル
        let osModel:String? = UIDevice.current.model
        guard let myOsModel = osModel else { return }
        adInfoView.text.append("\nOS model：" + myOsModel)
        
        // キャリア情報
        let carrier:String? = CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName
        guard let carrierName = carrier else { return }
        adInfoView.text.append("\ncarrier name：" + carrierName)
        
        // 国コード
        let isoCountry:String? = CTTelephonyNetworkInfo().subscriberCellularProvider?.isoCountryCode
        guard let isoCountryCode = isoCountry else { return }
        if (!isoCountryCode.isEmpty) {
            adInfoView.text.append("\nISO Country code：" + isoCountryCode + "\n")
        }
        
        // IDFA
        let idfa:String? = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        guard let IDFA = idfa else { return }
        adInfoView.text.append("\nIDFA：" + IDFA)
        
        // BundleID
        let bundleId:String? = Bundle.main.bundleIdentifier
        guard let BundleID = bundleId else { return }
        adInfoView.text.append("\nBundleID：" + BundleID)
        
        // 画面サイズ（ポイント）
        let screenB:CGSize? = UIScreen.main.bounds.size
        guard let screenBounds = screenB else { return }
        
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
        
        // 言語と地域
        let languageCode:String? = Locale.current.languageCode
        guard let myLanguageCode = languageCode else { return }
        adInfoView.text.append("\nlanguage：" + myLanguageCode)
        
        let regionCode:String? = Locale.current.regionCode
        guard let myRegionCode = regionCode else { return }
        adInfoView.text.append("\nregion：" + myRegionCode)
    }
}
