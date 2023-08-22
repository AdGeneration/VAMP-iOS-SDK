//
//  TextFieldCell.m
//  VAMPObjCSample
//
//  Created by Supership Inc. on 2023/01/30.
//  Copyright © 2023 Supership Inc. All rights reserved.
//

#import "TextFieldCell.h"

@implementation TextFieldCell

- (IBAction) editingChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(textFieldCell:didChangeText:)]) {
        [self.delegate textFieldCell:self didChangeText:self.textField.text];
    }
}

@end
