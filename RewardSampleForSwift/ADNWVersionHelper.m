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
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z-]*([0-9.]*)"
                                                                            options:0
                                                                              error:&error];
    if (!error && ver) {
        NSTextCheckingResult *match = [regexp firstMatchInString:ver options:0 range:NSMakeRange(0, ver.length)];
        ver = [ver substringWithRange:[match rangeAtIndex:1]];
    }
    
    if (!ver) {
        return @"unknown";
    }
    
    return ver;
}

+ (NSString *)nendVersion {
    NSString *nendFrameworkBundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"NendAdResource.bundle"];
    NSBundle *nendFrameworkBundle = [NSBundle bundleWithPath:nendFrameworkBundlePath];
    NSString *ver = [nendFrameworkBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    if (!ver) {
        return @"unknown";
    }
    
    return ver;
}

@end
