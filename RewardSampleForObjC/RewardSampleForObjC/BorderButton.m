//
//  BorderButton.m
//  RewardSampleForObjC
//
//  Created by zaizen on 2017/02/21.
//  Copyright © 2017年 jp.bitm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BorderButton.h"


@interface BorderButton()

@property (nonatomic, copy) IBInspectable UIColor *textColor;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, copy) IBInspectable UIColor  *borderColor;
@property (nonatomic, copy) IBInspectable UIColor *highlightedBackgroundColor;
@property (nonatomic, copy) IBInspectable UIColor *nonHighlightedBackgroundColor;

@end

@implementation BorderButton


- (void) setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
}

- (void) setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (void) setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = (__bridge CGColorRef _Nullable)(borderColor);
}

-(BOOL) isHighlighted {
    
    if ([super isHighlighted]) {
        self.backgroundColor = _highlightedBackgroundColor;
        self.layer.borderColor = [UIColor colorWithRed:21.0/255 green:126.0/255 blue:251.0/255 alpha:1.0].CGColor;
        
     
    } else {
        self.backgroundColor = _nonHighlightedBackgroundColor;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
    }
    
    return [super isHighlighted];
}

@end


