//
//  SwitchCell.h
//  VAMPObjCSample
//
//  Created by Supership Inc. on 2023/01/30.
//  Copyright © 2023 Supership Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SwitchCellDelegate;

@interface SwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISwitch *uiSwitch;
@property (weak, nonatomic, nullable) id <SwitchCellDelegate> delegate;

@end

@protocol SwitchCellDelegate <NSObject>

- (void) switchCell:(SwitchCell *)switchCell didValueChange:(BOOL)value;

@end
NS_ASSUME_NONNULL_END
