//
//  ViewController.swift
//  RewardSampleForSwift
//
//  Copyright © 2016年 example. All rights reserved.
//

import UIKit
import VAMP

class ViewController: UIViewController {
    
    @IBOutlet weak var sdkVersion: UILabel!
    var adReward:VAMP!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 対応OSバージョン
        print("supportedOSVersion:\(VAMP.supportedOSVersion())")
                
        // テストモード
        // 連携アドネットワーク（AppLovin、maio、UnityAds）
        // リリースする際は必ずコメントアウトしてください。収益が発生しない広告が配信されます。
//        VAMP.setTestMode(true)

        // デバッグモード
        // 連携アドネットワーク（AppLovin、UnityAds）
//        VAMP.setDebugMode(true)

        /* アドネットワークSDK　初期化メディエーション */
        // initializeAdnwSDKを使う場合は、初期化が終わる前にAD画面へ遷移してloadしないようご注意ください。
        // ├ ステータス設定。デフォルトAUTO
        //    VAMPInitializeState.AUTO	接続環境によって、WEIGHTとALL設定を自動的に切り替える（Wi-Fi:ALL、キャリア回線:WEIGHT）
        //    VAMPInitializeState.WEIGHT	配信比率が高いものをひとつ初期化する
        //    VAMPInitializeState.ALL	全アドネットワークを初期化する
        // └ アドネットワークのSDKを初期化する間隔（秒数）
        //   duration:秒単位で指定する。最小4秒、最大60秒。デフォルトは10秒。（対象:AppLovin、maio、UnityAds）
        /*
        self.adReward = VAMP()
        if ((self.adReward) != nil) {
            self.adReward.initializeAdnwSDK("*****", initializeState:VAMPInitializeState.AUTO, duration:10) // 広告枠IDを設定してください
            print("[VAMP]initilizedAdnwSDK")
        }
         */

        // アプリバージョン。info.plistから取得
        let appV:String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        guard let appVersion = appV else { return }
        
        // VAMPのSDKバージョン
        let sdkV:String? = VAMP.sdkVersion()
        guard let sdkVersion = sdkV else { return }
        
        // バージョン情報
        self.sdkVersion.text = "APP \(appVersion)(Swift)\nSDK \(sdkVersion)\n"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 画面遷移部
    @IBAction func Reword1(){
        performSegue(withIdentifier: "pushReword1", sender:self)
    }
    
    @IBAction func Reword2() {
        performSegue(withIdentifier: "pushReword2", sender:self)
    }
    
    // 詳細画面
    @IBAction func Info() {
        performSegue(withIdentifier: "pushInfo", sender: self)
    }
    
    @IBAction func Ad2() {
        performSegue(withIdentifier: "pushAd2", sender: self)
    }
}

