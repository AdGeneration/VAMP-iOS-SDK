//
//  SwitchCell.m
//  VAMPObjCSample
//
//  Created by Supership Inc. on 2023/01/30.
//  Copyright © 2023 Supership Inc. All rights reserved.
//

#import "SwitchCell.h"

@implementation SwitchCell

- (IBAction) valueChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(switchCell:didValueChange:)]) {
        [self.delegate switchCell:self didValueChange:self.uiSwitch.isOn];
    }
}

@end
