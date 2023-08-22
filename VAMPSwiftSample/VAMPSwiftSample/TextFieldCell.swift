//
//  TextFieldCell.swift
//  VAMPSwiftSample
//
//  Created by Supership Inc. on 2023/01/30.
//  Copyright © 2023 Supership Inc. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var textField: UITextField!
    weak var delegate: TextFieldCellDelegate?

    @IBAction func editingChanged(_ sender: Any) {
        delegate?.textFieldCellDidChange(self)
    }
}

protocol TextFieldCellDelegate: AnyObject {
    func textFieldCellDidChange(_ textFieldCell: TextFieldCell)
}
