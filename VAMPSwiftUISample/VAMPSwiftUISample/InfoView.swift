//
//  InfoView.swift
//  VAMPSwiftUISample
//
//  Created by Supership Inc. on 2025/07/19.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

import CoreTelephony
import SwiftUI
import VAMP

struct InfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("SDK")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 8)

                    InfoRow(label: "VAMPSDK", value: VAMPSDKVersion)
                    // AdNetwork Version
                    InfoRow(label: "AdMobSDK",
                            value: adNetworkVersion(adapterClass: "VAMPAdMobSDKAdapter"))
                    InfoRow(label: "maioSDK",
                            value: adNetworkVersion(adapterClass: "VAMPMaioSDKAdapter"))
                    InfoRow(label: "UnityAdsSDK",
                            value: adNetworkVersion(adapterClass: "VAMPUnityAdsSDKAdapter"))
                    InfoRow(label: "PangleSDK",
                            value: adNetworkVersion(adapterClass: "VAMPPangleSDKAdapter"))
                    InfoRow(label: "LINEAdsSDK",
                            value: adNetworkVersion(adapterClass: "VAMPLINEAdsSDKAdapter"))
                    InfoRow(label: "IronSourceSDK",
                            value: adNetworkVersion(adapterClass: "VAMPIronSourceSDKAdapter"))
                    InfoRow(label: "AppLovinSDK",
                            value: adNetworkVersion(adapterClass: "VAMPAppLovinSDKAdapter"))
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)

                VStack(alignment: .leading) {
                    Text("Adapter")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 8)

                    InfoRow(label: "AdMobAdapter",
                            value: adapterVersion(adapterClass: "VAMPAdMobSDKAdapter"))
                    InfoRow(label: "MaioAdapter",
                            value: adapterVersion(adapterClass: "VAMPMaioSDKAdapter"))
                    InfoRow(label: "UnityAdsAdapter",
                            value: adapterVersion(adapterClass: "VAMPUnityAdsSDKAdapter"))
                    InfoRow(label: "PangleAdapter",
                            value: adapterVersion(adapterClass: "VAMPPangleSDKAdapter"))
                    InfoRow(label: "LINEAdsAdapter",
                            value: adapterVersion(adapterClass: "VAMPLINEAdsSDKAdapter"))
                    InfoRow(label: "IronSourceAdapter",
                            value: adapterVersion(adapterClass: "VAMPIronSourceSDKAdapter"))
                    InfoRow(label: "AppLovinAdapter",
                            value: adapterVersion(adapterClass: "VAMPAppLovinSDKAdapter"))
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)

                VStack(alignment: .leading) {
                    Text("Device")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 8)
                    // デバイス名
                    InfoRow(label: "Device Name", value: UIDevice.current.name)

                    // OS名
                    InfoRow(label: "System Name", value: UIDevice.current.systemName)

                    // OSバージョン
                    InfoRow(label: "System Version", value: UIDevice.current.systemVersion)

                    // OSモデル
                    InfoRow(label: "OS Model", value: UIDevice.current.model)

                    // キャリア情報
                    let networkInfo = CTTelephonyNetworkInfo()
                    let provider = networkInfo.subscriberCellularProvider
                    InfoRow(label: "Carrier Name", value: provider?.carrierName ?? "-")

                    // 国コードISO
                    InfoRow(label: "ISO Country code", value: provider?.isoCountryCode ?? "-")

                    // 国コードPreferredLanguage
                    InfoRow(label: "Preferred Language",
                            value: NSLocale.preferredLanguages.first ?? "-")

                    // 言語コード
                    InfoRow(label: "Language Code", value: Locale.current.languageCode ?? "-")
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)

                VStack(alignment: .leading) {
                    Text("App")
                        .font(.headline)
                        .foregroundColor(.primary)
                    // BundleID
                    InfoRow(label: "BundleID", value: Bundle.main.bundleIdentifier ?? "-")
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)

                VStack(alignment: .leading) {
                    Text("Other")
                        .font(.headline)
                        .foregroundColor(.primary)
                    // サポートOSバージョン
                    InfoRow(label: "Support OS", value: VAMP.isSupported().description)
                    InfoRow(label: "ChildDirected",
                            value: VAMPPrivacySettings.childDirected().toString)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
        .navigationTitle("Info")
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
            @unknown default:
                return "unknown"
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text("\(label): ")
                .font(.system(.caption, design: .default))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(value)
                .font(.system(.body, design: .default))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

#Preview {
    InfoView()
}
