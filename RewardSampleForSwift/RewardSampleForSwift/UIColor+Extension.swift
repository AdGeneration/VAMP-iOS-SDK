//
//  UIColor+Extension.swift
//  RewardSampleForSwift
//
//  Created by AdGeneration on 2019/09/10.
//  Copyright © 2019 Supership Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    public class func defaultLabelColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }
}
