//
//  VideoSingle2ViewController.m
//  RewardSampleForObjC
//
//  Created by AdGeneration on 2017/02/21.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <VAMP/VAMP.h>

#import "VideoSingle2ViewController.h"

@interface VideoSingleViewController ()

- (NSString *)placementId;

@end

@interface VideoSingle2ViewController () <VAMPDelegate>

@property (nonatomic, weak) IBOutlet UITextField *adcodeField;
@property (nonatomic, weak) IBOutlet UITextView *adLogView;

@end

@implementation VideoSingle2ViewController

static NSString * const kPlacementId = @"*****";    // 広告枠IDを設定してください

- (NSString *)placementId {
    return kPlacementId;
}

@end

