//
//  ADNWVersionHelper.m
//  RewardSampleForSwift
//
//  Created by AdGeneration on 2017/10/03.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import "ADNWVersionHelper.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <NendAd/NendAd.h>

@implementation ADNWVersionHelper

+ (NSString *)admobVersion {
    NSString *ver = [NSString stringWithCString:(const char *) GoogleMobileAdsVersionString
                                       encoding:NSUTF8StringEncoding];
    
    if (!ver) {
        return @"unknown";
    }
    
    return ver;
}

+ (NSString *)nendVersion {
    NSString *ver = [NSString stringWithCString:(const char *) NendAdVersionString
                                       encoding:NSUTF8StringEncoding];
    
    if (!ver) {
        return @"unknown";
    }
    
    return ver;
}

@end
