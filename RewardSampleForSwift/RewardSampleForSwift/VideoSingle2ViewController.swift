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

    let placementId2 = "*****"  // 広告枠IDを設定してください
    
    override func getPlacementId() -> String {
        return placementId2
    }
}

