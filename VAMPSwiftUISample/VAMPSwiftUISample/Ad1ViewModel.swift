//
//  Ad1ViewModel.swift
//  VAMPSwiftUISample
//
//  Created by Supership Inc. on 2025/07/19.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

import Combine
import SwiftUI
import VAMP

@MainActor
class Ad1ViewModel: NSObject, ObservableObject {
    enum AdState {
        case idle
        case loading
        case loaded
        case willShow
        case showing
    }

    let placementId: String
    @Published var state = AdState.idle
    @Published var logs: [LogEntry] = []

    var isLoaded: Bool {
        state == .loaded
    }

    var isShowing: Bool {
        state == .showing
    }

    var willShow: Bool {
        state == .willShow
    }

    init(placementId: String) {
        self.placementId = placementId
    }

    func loadAd() {
        if state != .idle && state != .loaded {
            print("state is not idle.")
            return
        }

        state = .loading
        addLogText("[load]")

        // 広告の読み込みを開始
        let request = VAMPRequest()
        VAMPRewardedAd.load(withPlacementID: placementId, request: request, delegate: self)
    }

    func willShowAd() {
        if state == .loaded {
            state = .willShow
        }
    }

    func showAd(viewController: UIViewController) {
        if state != .willShow {
            print("state is not willShow.")
            return
        }

        // 広告の準備ができているか確認してから表示
        if let rewardedAd = VAMPRewardedAd.of(placementID: placementId) {
            state = .showing
            addLogText("[show]")
            // 広告の表示
            rewardedAd.show(from: viewController, delegate: self)
        } else {
            state = .idle
            print("Not loaded")
        }
    }

    func addLogText(_ message: String, color: Color) {
        logs.append(LogEntry(message: "\(message)", messageColor: color))
    }

    func addLogText(_ message: String) {
        addLogText(message, color: Color.gray)
    }
}

extension Ad1ViewModel: VAMPRewardedAdLoadAdvancedDelegate {
    /// 広告表示が可能になると通知されます。
    ///
    /// - Parameter placementID: 広告枠ID
    nonisolated func rewardedAdDidReceive(withPlacementID placementID: String) {
        Task { @MainActor in
            state = .loaded
            addLogText("didReceive(\(placementID))")
        }
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
    nonisolated func rewardedAdDidFailToLoad(withPlacementID placementID: String,
                                             error: VAMPError)
    {
        Task { @MainActor in
            state = .idle
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
    }

    /// RTBはロードが完了してから1時間経過すると、広告表示ができても無効扱いとなり、収益が発生しません。
    ///
    /// この通知を受け取ったらロードからやり直してください。
    ///
    /// - Parameter placementID: 広告枠ID
    nonisolated func rewardedAdDidExpire(withPlacementID placementID: String) {
        Task { @MainActor in
            state = .idle
            addLogText("didExpire(\(placementID))", color: .red)
        }
    }

    /// アドネットワークごとの広告取得が開始されたときに通知されます。
    ///
    /// - Parameters:
    ///   - adNetworkName: アドネットワーク名
    ///   - placementID: 広告枠ID
    nonisolated func rewardedAdDidStartLoading(_ adNetworkName: String,
                                               withPlacementID placementID: String)
    {
        Task { @MainActor in
            addLogText("didStartLoading(\(placementID), \(adNetworkName))")
        }
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
    nonisolated func rewardedAdDidLoad(_ adNetworkName: String, withPlacementID placementID: String,
                                       error: VAMPError?)
    {
        Task { @MainActor in
            if let error {
                addLogText("didLoad(\(placementID), \(adNetworkName), \(error.localizedDescription))",
                           color: .red)
            } else {
                addLogText("didLoad(\(placementID), \(adNetworkName))", color: .primary)
            }
        }
    }
}

extension Ad1ViewModel: VAMPRewardedAdShowDelegate {
    /// 広告の表示に失敗すると通知されます。
    ///
    /// 例) 視聴完了する前にユーザがキャンセルするなど。
    ///
    /// - Parameters:
    ///   - rewardedAd: `VAMPRewardedAd` オブジェクト
    ///   - error: `VAMPError` オブジェクト
    nonisolated func rewardedAd(_ rewardedAd: VAMPRewardedAd,
                                didFailToShowWithError error: VAMPError)
    {
        Task { @MainActor in
            state = .idle
            addLogText("didFailToShow(\(error.localizedDescription))", color: .red)

            let code = VAMPErrorCode(rawValue: UInt(error.code))

            if code == .userCancel {
                // ユーザが広告再生を途中でキャンセルしました。
                // AdMobは動画再生の途中でユーザーによるキャンセルが可能
            } else if code == .notLoadedAd {}
        }
    }

    /// インセンティブ付与が可能になると通知されます。
    ///
    /// ※ユーザが途中で再生をスキップしたり、動画視聴をキャンセルすると発生しません。
    /// ※アドネットワークによって発生タイミングが異なります。
    ///
    /// - Parameter rewardedAd: `VAMPRewardedAd` オブジェクト
    nonisolated func rewardedAdDidComplete(_ rewardedAd: VAMPRewardedAd) {
        Task { @MainActor in
            addLogText("didComplete()", color: .green)
        }
    }

    /// 広告の表示が開始されると通知されます。
    ///
    /// - Parameter rewardedAd: `VAMPRewardedAd` オブジェクト
    nonisolated func rewardedAdDidOpen(_ rewardedAd: VAMPRewardedAd) {
        Task { @MainActor in
            addLogText("didOpen()")
        }
    }

    /// 広告が閉じられると通知されます。
    /// ユーザキャンセルなどの場合も通知されるため、インセンティブ付与は `VAMPRewardedAdShowDelegate#rewardedAdDidComplete:`
    /// で判定してください。
    ///
    /// - Parameters:
    ///   - rewardedAd: `VAMPRewardedAd` オブジェクト
    ///   - adClicked: 広告がクリックされたかどうか
    nonisolated func rewardedAd(_ rewardedAd: VAMPRewardedAd,
                                didCloseWithClickedFlag adClicked: Bool)
    {
        Task { @MainActor in
            state = .idle
            addLogText("didClose(adClicked:\(adClicked))", color: .blue)
        }
    }
}
