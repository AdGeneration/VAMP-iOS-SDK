//
//  BorderButton.swift
//  RewardSampleForSwift
//
//  Created by AdGeneration on 2017/02/21.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//
// Button_Custom と同様の内容ですが、そのまま使用しているとStoryBoardが暴走したので名称を変更

import Foundation
class BorderButton: UIButton {
    
    @IBInspectable var textColor: UIColor?
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var highlightedBackgroundColor :UIColor?
    @IBInspectable var nonHighlightedBackgroundColor :UIColor?
    override var isHighlighted :Bool {
        didSet {
            if isHighlighted {
                self.backgroundColor = highlightedBackgroundColor
                self.layer.borderColor = UIColor(red: 21/255, green: 126/255, blue: 251/255, alpha: 1.0).cgColor
            }
            else {
                self.backgroundColor = nonHighlightedBackgroundColor
                self.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
    }
}
