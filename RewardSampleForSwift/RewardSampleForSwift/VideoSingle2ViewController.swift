//
//  VideoSingle2ViewController.swift
//  RewardSampleForSwift
//
//  Created by AdGeneration on 2017/02/21.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

import Foundation
import AVFoundation
import VAMP

class VideoSingle2ViewController: VideoSingleViewController {

    let placementId2 = "59755"  // 広告枠IDを設定してください
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // VAMPインスタンスを生成し初期化
        self.vamp = VAMP()
        self.vamp.delegate = self
        self.vamp.setPlacementId(self.getPlacementId())
        
        // 画面表示時に広告をプリロード
        self.vamp.preload()
    }
    
    override func getPlacementId() -> String {
        return placementId2
    }
    
    override func showAd(sender: AnyObject) {
        // 広告取得済みか判定
        if (self.vamp.isReady()) {
            self.addLogText("[show]")
            self.pauseSound()
            
            // 広告表示
            self.vamp.show(from: self)
        } else {
            self.addLogText("[load]")
            
            // 広告取得を開始
            self.vamp.load()
        }
    }
    
    // MARK: - VAMPDelegate
    
    // アドネットワークの広告取得結果が通知されます。成功時はsuccess=YESとなりロード処理は終了します。
    // success=NOのとき、次位のアドネットワークがある場合はロード処理は継続されます
    override func vampLoadResult(_ placementId: String, success: Bool, adnwName: String, message: String?) {
        if success {
            self.pauseSound()
            // 広告表示
            vamp.show(from: self)
            self.addLogText("vampLoadResult(\(adnwName), \(placementId), success) show()", color: UIColor.defaultLabelColor())
        } else {
            // 失敗しても、次のアドネットワークがあれば、広告取得を試みます。
            // 最終的に全てのアドネットワークの広告在庫が無ければ
            // onFailedToLoadのNO_ADSTOCKが通知されるので、ここで処理を止めないでください。
            let msg = message != nil ? message! : ""
            self.addLogText("vampLoadResult(\(adnwName), \(placementId), success:NG, \(msg))", color: UIColor.systemRed)
        }
    }
    
    // 全アドネットワークにおいて広告が取得できなかったときに通知
    override func vamp(_ vamp: VAMP, didFailToLoadWithError error: VAMPError, withPlacementId placementId: String?) {
        if let bindPid = placementId {
            self.addLogText("vampDidFailToLoad(\(error.localizedDescription), \(bindPid))", color:UIColor.systemRed)
        
            let code = VAMPErrorCode(rawValue: UInt(error.code))
            if code == .noAdStock {
                // 在庫が無いので、再度loadをしてもらう必要があります。
                // 連続で発生する場合、時間を置いてからloadをする必要があります。
                print("[VAMP]vampDidFailToLoad(noAdStock, \(error.localizedDescription))")
            } else if code == .noAdnetwork {
                // アドジェネ管理画面でアドネットワークの配信がONになっていない、
                // またはEU圏からのアクセスの場合(GDPR)に発生します。
                print("[VAMP]vampDidFailToLoad(noAdnetwork, \(error.localizedDescription))")
            } else if code == .needConnection {
                // ネットワークに接続できない状況です。
                // 電波状況をご確認ください。
                print("[VAMP]vampDidFailToLoad(needConnection, \(error.localizedDescription))")
            } else if code == .mediationTimeout {
                // アドネットワークSDKから返答が得られず、タイムアウトしました。
                print("[VAMP]vampDidFailToLoad(mediationTimeout, \(error.localizedDescription))")
            }
        }
    
        // 必要に応じて広告の再ロードを試みます
//        if (/* 任意のリトライ条件 */) {
//            vamp.load()
//        }
    }
    
    // 広告の表示に失敗したときに通知
    override func vamp(_ vamp: VAMP, didFailToShowWithError error: VAMPError, withPlacementId placementId: String) {
        self.addLogText("vampDidFailToShow(\(error.localizedDescription), \(placementId))", color: UIColor.systemRed)
        
        let code = VAMPErrorCode(rawValue: UInt(error.code))
        if (code == .userCancel) {
            // ユーザが広告再生を途中でキャンセルしました。
            // AdMobは動画再生の途中でユーザーによるキャンセルが可能
            print("[VAMP]vampDidFailToShow(userCancel, \(error.localizedDescription))");
        } else {
            self.addLogText("vampDidFailToShow", color: UIColor.red)
        }
        self.resumeSound()
    }
    
    // 広告表示開始
    override func vampDidOpen(_ placementId: String, adnwName: String) {
        self.addLogText("vampDidOpen(\(adnwName), \(placementId))")
    }
    
    // インセンティブ付与が可能になったタイミングで通知
    // アドネットワークによって通知タイミングが異なる（動画再生完了時、またはエンドカードを閉じたタイミング）
    override func vampDidComplete(_ placementId: String, adnwName: String) {
        self.addLogText("vampDidComplete(\(adnwName), \(placementId))", color: UIColor.systemBlue)
    }
    
    // 広告が閉じられた時に通知
    override func vampDidClose(_ placementId: String, adnwName: String, adClicked: Bool) {
        self.addLogText("vampDidClose(\(adnwName), \(placementId), Click:\(adClicked))", color: UIColor.defaultLabelColor())
        self.resumeSound()
        
        // 必要に応じて、次に表示する広告をプリロード
//        self.vamp.preload()
    }

    // 広告表示が可能になると通知
//    override func vampDidReceive(_ placementId: String, adnwName: String) {
//        // v3.0〜 vmapLoadResult successで判定
//    }
}
