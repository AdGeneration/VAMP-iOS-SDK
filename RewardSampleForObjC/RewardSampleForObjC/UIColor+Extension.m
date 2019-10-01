//
//  UIColor+Extension.m
//  RewardSampleForObjC
//
//  Created by AdGeneration on 2019/09/10.
//  Copyright © 2019 Supership Inc. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)
+ (UIColor *)defaultLabelColor {
    if (@available(iOS 13.0, *)) {
        return UIColor.labelColor;
    } else {
        return UIColor.blackColor;
    }
}
@end
