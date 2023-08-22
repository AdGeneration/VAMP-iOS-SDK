//
//  SwitchCell.swift
//  VAMPSwiftSample
//
//  Created by Supership Inc. on 2023/01/30.
//  Copyright © 2023 Supership Inc. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var uiSwitch: UISwitch!
    weak var delegate: SwitchCellDelegate?

    @IBAction func valueChanged(_ sender: Any) {
        delegate?.switchCell(self, didValueChange: uiSwitch.isOn)
    }
}

protocol SwitchCellDelegate: AnyObject {
    func switchCell(_ switchCell: SwitchCell, didValueChange value: Bool)
}
