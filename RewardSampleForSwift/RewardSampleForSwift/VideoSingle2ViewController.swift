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
        self.vamp.setRootViewController(self)
        
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
            self.vamp.show()
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
            vamp.show()
            self.addLogText("vampLoadResult(\(adnwName), \(placementId), success) show()")
        } else {
            // 失敗しても、次のアドネットワークがあれば、広告取得を試みます。
            // 最終的に全てのアドネットワークの広告在庫が無ければ
            // onFailedToLoadのNO_ADSTOCKが通知されるので、ここで処理を止めないでください。
            let msg = message != nil ? message! : ""
            self.addLogText("vampLoadResult(\(adnwName), \(placementId), success:NG, \(msg))")
        }
    }
    
    // 全アドネットワークにおいて広告が取得できなかったときに通知
    override func vamp(_ vamp: VAMP, didFailToLoadWithError error: VAMPError, withPlacementId placementId: String?) {
        let errorString: String? = error.kVAMPErrorString()
        if let errorStr = errorString {
            self.addLogText("vampDidFailToLoad(\(errorStr), \(String(describing: placementId)))")
        } else {
            self.addLogText("vampDidFailToLoad")
        }
    
        // 必要に応じて広告の再ロードを試みます
//        if (/* 任意のリトライ条件 */) {
//            vamp.load()
//        }
    }
    
    // 広告の表示に失敗したときに通知
    override func vamp(_ vamp: VAMP, didFailToShowWithError error: VAMPError, withPlacementId placementId: String) {
        let errorString: String? = error.kVAMPErrorString()
        if let errorStr = errorString {
            self.addLogText("vampDidFailToShow(\(errorStr))")
        } else {
            self.addLogText("vampDidFailToShow")
        }
        self.resumeSound()
    }
    
    // インセンティブ付与可能になったタイミングで通知（エンドカード閉じる、再生キャンセル）
    override func vampDidComplete(_ placementId: String, adnwName: String) {
        self.addLogText("vampDidComplete(\(adnwName), \(placementId))")
    }
    
    // 広告が閉じられた時に通知
    override func vampDidClose(_ placementId: String, adnwName: String) {
        self.addLogText("vampDidClose(\(adnwName), \(placementId))")
        self.resumeSound()
        
        // 必要に応じて、次に表示する広告をプリロード
//        self.vamp.preload()
    }

    // 広告表示が可能になると通知
//    override func vampDidReceive(_ placementId: String, adnwName: String) {
//        // v3.0〜 vmapLoadResult successで判定
//    }
}
