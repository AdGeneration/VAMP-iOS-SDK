//
//  ViewController.swift
//  VAMPSwiftSample
//
//  Created by Supership Inc. on 2019/04/15.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

import UIKit

// VAMP SDKのインポート

import VAMP

class ViewController: UIViewController {

    @IBOutlet weak var tableView:       UITableView!
    @IBOutlet weak var sdkVersionLabel: UILabel!

    let samples = ["Ad1", "Ad2", "AR"]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "VAMP Swift Sample"

        tableView.dataSource = self
        tableView.delegate = self

        // VAMP SDKバージョン
        sdkVersionLabel.text = "VAMP SDK \(VAMPSDKVersion)"

        // テストモード
        // 連携アドネットワーク（AdMob、AppLovin、FAN、maio、nend、UnityAds）
        // リリースする際は必ずコメントアウトしてください。収益が発生しない広告が配信されます
        VAMP.setTestMode(true)

        // デバッグモード
        // 連携アドネットワーク（AppLovin、UnityAds、FAN、nend、Tapjoy）
        VAMP.setDebugMode(true)

        // ユーザ属性の設定
        // 誕生日
//        var components = DateComponents()
//        components.year = 1980
//        components.month = 2
//        components.day = 20
//        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
//        let birthday = calendar.date(from: components)
//        VAMPUserFeature.setBirthday(birthday)
//        // 性別
//        VAMPUserFeature.setGender(.male)

        // 国コードの取得サンプル
        VAMP.getLocation { [weak self] (location: VAMPLocation) in
            if let weakSelf = self {
                weakSelf.sdkVersionLabel.text = "\(weakSelf.sdkVersionLabel.text!) / \(location.countryCode)-\(location.region)"

                if location.countryCode == "US" {
                    // COPPA対象ユーザである場合はYESを設定する
                    VAMPPrivacySettings.setChildDirected(VAMPChildDirected.true)
                }
            }
        }

        // EU圏内ならばユーザに同意を求めるサンプル
//        VAMP.isEUAccess { access in
//            if !access {
//                // Nothing to do
//                return
//            }
//
//            let alert = UIAlertController(title: "Personalized Ads", message: "Accept?", preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Accept", style: .default) { action in
//                VAMP.setUserConsent(VAMPConsentStatus.accepted)
//            })
//
//            alert.addAction(UIAlertAction(title: "Deny", style: .destructive) { action in
//                VAMP.setUserConsent(VAMPConsentStatus.denied)
//            })
//
//            self.present(alert, animated: true, completion: nil)
//        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = samples[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        switch indexPath.row {
            case 0:
                let viewController = Ad1ViewController.instantiate()
                navigationController?.pushViewController(viewController, animated: true)
            case 1:
                let viewController = Ad2ViewController.instantiate()
                navigationController?.pushViewController(viewController, animated: true)
            case 2:
                let viewController = ARViewController.instantiate()
                navigationController?.pushViewController(viewController, animated: true)
            default:
                break
        }
    }
}
