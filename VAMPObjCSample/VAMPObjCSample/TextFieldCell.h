//
//  TextFieldCell.h
//  VAMPObjCSample
//
//  Created by Supership Inc. on 2023/01/30.
//  Copyright © 2023 Supership Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TextFieldCellDelegate;

@interface TextFieldCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic, nullable) id <TextFieldCellDelegate> delegate;

@end

@protocol TextFieldCellDelegate <NSObject>

- (void) textFieldCell:(TextFieldCell *)textFieldCell didChangeText:(NSString *)text;

@end
NS_ASSUME_NONNULL_END
