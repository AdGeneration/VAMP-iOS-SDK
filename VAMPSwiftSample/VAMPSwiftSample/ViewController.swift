//
//  ViewController.swift
//  VAMPSwiftSample
//
//  Created by Supership Inc. on 2019/04/15.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

import AppTrackingTransparency
import UIKit

// VAMP SDKのインポート

import VAMP

class ViewController: UIViewController {
    enum MenuType: Int {
        case ad1placemnetid = 0
        case ad2placementid
        case testmode
        case debugmode
        case ad1
        case ad2
        case info
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var sdkVersionLabel: UILabel!

    let menuItems = [MenuType.ad1placemnetid,
                     MenuType.ad2placementid,
                     MenuType.testmode,
                     MenuType.debugmode,
                     MenuType.ad1,
                     MenuType.ad2,
                     MenuType.info]

    // 広告枠IDを設定してください
    //   59755 : iOSテスト用ID (このIDのままリリースしないでください)
    let placementId = "59755"

    var ad1PlacementId: String
    var ad2PlacementId: String

    required init?(coder: NSCoder) {
        ad1PlacementId = placementId
        ad2PlacementId = placementId
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "VAMP Swift Sample"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "SwitchCell", bundle: nil),
                           forCellReuseIdentifier: "SwitchCell")
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil),
                           forCellReuseIdentifier: "TextFieldCell")
        tableView.rowHeight = 50

        // VAMP SDKバージョン
        sdkVersionLabel.text = "VAMP SDK \(VAMPSDKVersion)"

        // テストモード
        // 連携アドネットワーク（AdMob、AppLovin、FAN、maio、nend、UnityAds）
        // リリースする際は必ずコメントアウトしてください。収益が発生しない広告が配信されます
        VAMP.setTestMode(true)

        // デバッグモード
        // 連携アドネットワーク（AppLovin、UnityAds、FAN、nend、Tapjoy）
        VAMP.setDebugMode(true)

        // 国コードの取得サンプル
        VAMP.getLocation { [weak self] (location: VAMPLocation) in
            if let weakSelf = self {
                weakSelf.sdkVersionLabel
                    .text =
                    "\(weakSelf.sdkVersionLabel.text!) / \(location.countryCode)-\(location.region)"

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
//            let alert = UIAlertController(title: "Personalized Ads", message:
//            "Accept?", preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Accept", style: .default) { action in
//                VAMPPrivacySettings.setConsentStatus(.accepted)
//            })
//
//            alert.addAction(UIAlertAction(title: "Deny", style: .destructive) { action in
//                VAMPPrivacySettings.setConsentStatus(.denied)
//            })
//
//            self.present(alert, animated: true, completion: nil)
//        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                var str = "unknown"
                if status == .denied {
                    str = "ATTrackingManagerAuthorizationStatusDenied"
                } else if status == .authorized {
                    str = "ATTrackingManagerAuthorizationStatusAuthorized"
                } else if status == .restricted {
                    str = "ATTrackingManagerAuthorizationStatusRestricted"
                } else if status == .notDetermined {
                    str = "ATTrackingManagerAuthorizationStatusNotDetermined"
                }

                print("ATT status:\(str)")
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        menuItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let menu = MenuType(rawValue: indexPath.row)!
        let labelText = menu.toString

        if menu == .ad1placemnetid || menu == .ad2placementid {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "TextFieldCell",
                                     for: indexPath) as! TextFieldCell
            cell.tag = menu.rawValue
            cell.delegate = self
            cell.label.text = labelText
            cell.textField.keyboardType = .numberPad

            if menu == .ad1placemnetid {
                cell.textField.text = ad1PlacementId
            } else if menu == .ad2placementid {
                cell.textField.text = ad2PlacementId
            }
            return cell
        } else if menu == .debugmode || menu == .testmode {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "SwitchCell",
                                     for: indexPath) as! SwitchCell
            cell.tag = menu.rawValue
            cell.label.text = labelText
            cell.delegate = self

            if menu == .debugmode {
                cell.uiSwitch.isOn = VAMP.isDebugMode()
            } else if menu == .testmode {
                cell.uiSwitch.isOn = VAMP.isTestMode()
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                     for: indexPath)
            cell.textLabel?.text = labelText
            cell.tag = menu.rawValue

            return cell
        }
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)

        switch indexPath.row {
            case MenuType.ad1.rawValue:
                let viewController = Ad1ViewController
                    .instantiate(with: ad1PlacementId)
                navigationController?.pushViewController(viewController,
                                                         animated: true)
            case MenuType.ad2.rawValue:
                let viewController = Ad2ViewController
                    .instantiate(with: ad2PlacementId)
                navigationController?.pushViewController(viewController,
                                                         animated: true)
            case MenuType.info.rawValue:
                let viewController = InfoViewController.instantiate()
                navigationController?.pushViewController(viewController,
                                                         animated: true)
            default:
                break
        }
    }
}

extension ViewController.MenuType {
    var toString: String {
        switch self {
            case .ad1placemnetid:
                return "AD1"
            case .ad2placementid:
                return "AD2"
            case .testmode:
                return "TEST MODE"
            case .debugmode:
                return "DEBUG MODE"
            case .ad1:
                return "AD1"
            case .ad2:
                return "AD2"
            case .info:
                return "Info"
            default:
                return "Unknown"
        }
    }
}

extension ViewController: TextFieldCellDelegate {
    func textFieldCellDidChange(_ textFieldCell: TextFieldCell) {
        switch textFieldCell.tag {
            case MenuType.ad1placemnetid.rawValue:
                if let text = textFieldCell.textField.text {
                    ad1PlacementId = text
                }
            case MenuType.ad2placementid.rawValue:
                if let text = textFieldCell.textField.text {
                    ad2PlacementId = text
                }
            default:
                break
        }
    }
}

extension ViewController: SwitchCellDelegate {
    func switchCell(_ switchCell: SwitchCell, didValueChange value: Bool) {
        switch switchCell.tag {
            case MenuType.debugmode.rawValue:
                VAMP.setDebugMode(value)
            case MenuType.testmode.rawValue:
                VAMP.setTestMode(value)
            default:
                break
        }
    }
}
