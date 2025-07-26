//
//  ContentViewModel.swift
//  VAMPSwiftUISample
//
//  Created by Supership Inc. on 2025/07/19.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

import Combine
import VAMP

@MainActor
class ContentViewModel: ObservableObject {
    @Published var testMode = true {
        didSet {
            VAMP.setTestMode(testMode)
        }
    }

    @Published var debugMode = true {
        didSet {
            VAMP.setDebugMode(debugMode)
        }
    }

    @Published var location = ""
    @Published var placementId = "59755"

    init() {
        testMode = testMode
        debugMode = debugMode
        location = location

        VAMPDebugUtils.logSDKDetails()
        VAMP.setTestMode(testMode)
        VAMP.setDebugMode(debugMode)
    }

    func getLocation() {
        VAMP.getLocation { [weak self] (location: VAMPLocation) in
            if let weakSelf = self {
                weakSelf.location = "\(location.countryCode)-\(location.region)"
                if location.countryCode == "US" {
                    // COPPA対象ユーザである場合はYESを設定する
                    VAMPPrivacySettings.setChildDirected(VAMPChildDirected.true)
                }
            }
        }
    }
}
