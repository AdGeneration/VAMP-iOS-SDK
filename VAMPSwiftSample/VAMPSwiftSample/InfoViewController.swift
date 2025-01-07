//
//  InfoViewController.swift
//  VAMPSwiftSample
//
//  Created by Supership Inc. on 2023/01/28.
//  Copyright © 2023 Supership Inc. All rights reserved.
//

import CoreTelephony
import Foundation
import UIKit

import VAMP

class InfoViewController: UIViewController {
    var adInfoView: UITextView

    class func instantiate() -> InfoViewController {
        InfoViewController()
    }

    init() {
        adInfoView = UITextView()
        adInfoView.textContainerInset = UIEdgeInsets(top: 0, left: 16,
                                                     bottom: 0, right: 16)
        adInfoView.isEditable = false
        adInfoView.isSelectable = false
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Info"

        view.addSubview(adInfoView)
        adInfoView.text = ""

        // VAMP SDK Version
        addInfoText(text: String(format: "VAMPSDK: %@", VAMPSDKVersion))

        // アドネットワークバージョン
        addInfoText(text: String(format: "AdMobSDK: %@",
                                 adNetworkVersion(adapterClass: "VAMPAdMobSDKAdapter")))
        addInfoText(text: String(format: "maioSDK: %@",
                                 adNetworkVersion(adapterClass: "VAMPMaioSDKAdapter")))
        addInfoText(text: String(format: "UnityAdsSDK: %@",
                                 adNetworkVersion(adapterClass: "VAMPUnityAdsSDKAdapter")))
        addInfoText(text: String(format: "PangleSDK: %@",
                                 adNetworkVersion(adapterClass: "VAMPPangleSDKAdapter")))
        addInfoText(text: String(format: "LINEAdsSDK: %@",
                                 adNetworkVersion(adapterClass: "VAMPLINEAdsSDKAdapter")))
        addInfoText(text: String(format: "IronSourceSDK: %@",
                                 adNetworkVersion(adapterClass: "VAMPIronSourceSDKAdapter")))
        addInfoText(text: String(format: "AppLovinSDK: %@",
                                 adNetworkVersion(adapterClass: "VAMPAppLovinSDKAdapter")))

        addInfoText(text: "\n")

        // アダプタバージョン
        addInfoText(text: String(format: "AdMob Adapter: %@",
                                 adapterVersion(adapterClass: "VAMPAdMobSDKAdapter")))
        addInfoText(text: String(format: "maio Adapter: %@",
                                 adapterVersion(adapterClass: "VAMPMaioSDKAdapter")))
        addInfoText(text: String(format: "UnityAds Adapter: %@",
                                 adapterVersion(adapterClass: "VAMPUnityAdsSDKAdapter")))
        addInfoText(text: String(format: "Pangle Adapter: %@",
                                 adapterVersion(adapterClass: "VAMPPangleSDKAdapter")))
        addInfoText(text: String(format: "LINEAds Adapter: %@",
                                 adapterVersion(adapterClass: "VAMPLINEAdsSDKAdapter")))
        addInfoText(text: String(format: "IronSource Adapter: %@",
                                 adapterVersion(adapterClass: "VAMPIronSourceSDKAdapter")))
        addInfoText(text: String(format: "AppLovin Adapter: %@",
                                 adapterVersion(adapterClass: "VAMPAppLovinSDKAdapter")))

        addInfoText(text: "\n")

        addInfoText(text: String(format: "useHyperID: %@",
                                 VAMP.useHyperID().description))

        addInfoText(text: "\n")

        // デバイス名
        addInfoText(text: String(format: "device name: %@",
                                 UIDevice.current.name))

        // OS名
        addInfoText(text: String(format: "system name: %@",
                                 UIDevice.current.systemName))

        // OSバージョン
        addInfoText(text: String(format: "system version: %@",
                                 UIDevice.current.systemVersion))

        // OSモデル
        addInfoText(text: String(format: "OS model: %@",
                                 UIDevice.current.model))

        // キャリア情報
        let networkInfo = CTTelephonyNetworkInfo()
        let provider = networkInfo.subscriberCellularProvider
        addInfoText(text: String(format: "carrier name: %@",
                                 provider?.carrierName ?? "-"))

        // 国コードISO
        addInfoText(text: String(format: "ISO Country code: %@",
                                 provider?.isoCountryCode ?? "-"))

        // 国コードPreferredLanguage
        addInfoText(text: String(format: "PreferredLanguage: %@",
                                 NSLocale.preferredLanguages.first ?? "-"))

        // 言語コード
        addInfoText(text: String(format: "code: %@",
                                 Locale.current.languageCode ?? "-"))

        // BundleID
        addInfoText(text: String(format: "BundleID: %@",
                                 Bundle.main.bundleIdentifier ?? "-"))

        // サポートOSバージョン
        addInfoText(text: String(format: "サポート対象OS: %@",
                                 VAMP.isSupported().description))
        addInfoText(text: String(format: "ChildDirected: %@",
                                 VAMPPrivacySettings.childDirected().toString))
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        adInfoView.frame = view.frame
    }

    func addInfoText(text: String) {
        adInfoView.text = adInfoView.text.appendingFormat("\n%@", text)
    }

    func adNetworkVersion(adapterClass: String) -> String {
        let cls = NSClassFromString(adapterClass) as? NSObject.Type
        if cls == nil {
            return "-"
        }

        let obj = cls?.init() as? VAMPAdapter
        return obj?.adNetworkVersion() ?? "-"
    }

    func adapterVersion(adapterClass: String) -> String {
        let cls = NSClassFromString(adapterClass) as? NSObject.Type
        if cls == nil {
            return "-"
        }

        let obj = cls?.init() as? VAMPAdapter
        let version = obj?.adapterVersion() ?? "-"

        // アダプタバージョンは以下の形式のため、
        // @(#)PROGRAM:VAMPAdMobAdapter  PROJECT:VAMPAdMobAdapter-9.3.0.0\n
        // 最後のバージョン番号だけを抽出する
        let comps = version.components(separatedBy: "-")
        return comps.last?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? "-"
    }
}

extension VAMPChildDirected {
    var toString: String {
        switch self {
            case .true:
                return "true"
            case .false:
                return "false"
            case .unknown:
                return "unknown"
        }
    }
}
