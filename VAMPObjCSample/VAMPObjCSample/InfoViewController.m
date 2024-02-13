//
//  InfoViewController.m
//  VAMPObjCSample
//
//  Created by Supership Inc. on 2023/01/28.
//  Copyright © 2023 Supership Inc. All rights reserved.
//

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <Foundation/Foundation.h>

#import <VAMP/VAMP.h>

#import "InfoViewController.h"

#define b2s(flag) (flag ? @"true" : @"false")

typedef NSString *(*AdNetworkVersionMethod)(id, SEL);
typedef NSString *(*AdapterVersionMethod)(id, SEL);

@interface InfoViewController ()

@property (nonatomic) UITextView *adInfoView;

@end

@implementation InfoViewController

+ (instancetype) instantiateViewController {
    return [InfoViewController new];
}

- (instancetype) init {
    if (self = [super init]) {
        _adInfoView = [UITextView new];
        _adInfoView.textContainerInset = UIEdgeInsetsMake(0, 16.f, 0, 16.f);
        _adInfoView.editable = NO;
        _adInfoView.selectable = NO;
    }

    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    self.title = @"Info";

    [self.view addSubview:self.adInfoView];

    self.adInfoView.text = @"";

    // VAMP SDK Version
    [self addInfoText:[NSString stringWithFormat:@"VAMPSDK: %@",
                       VAMPSDKVersion]];

    // アドネットワークバージョン
    [self addInfoText:[NSString stringWithFormat:@"AdMobSDK: %@",
                       [self adNetworkVersion:@"VAMPAdMobSDKAdapter"]]];
    [self addInfoText:[NSString stringWithFormat:@"maioSDK: %@",
                       [self adNetworkVersion:@"VAMPMaioSDKAdapter"]]];
    [self addInfoText:[NSString stringWithFormat:@"UnityAdsSDK: %@",
                       [self adNetworkVersion:@"VAMPUnityAdsSDKAdapter"]]];
    [self addInfoText:[NSString stringWithFormat:@"PangleSDK: %@",
                       [self adNetworkVersion:@"VAMPPangleSDKAdapter"]]];
    [self addInfoText:[NSString stringWithFormat:@"LINEAdsSDK: %@",
                       [self adNetworkVersion:@"VAMPLINEAdsSDKAdapter"]]];
    [self addInfoText:[NSString stringWithFormat:@"IronSourceSDK: %@",
                       [self adNetworkVersion:@"VAMPIronSourceSDKAdapter"]]];

    [self addInfoText:@"\n"];

    // アダプタバージョン
    [self addInfoText:[NSString stringWithFormat:@"AdMob Adapter: %@",
                       [self adapterVersion:@"VAMPAdMobSDKAdapter"]]];
    [self addInfoText:[NSString stringWithFormat:@"maio Adapter: %@",
                       [self adapterVersion:@"VAMPMaioSDKAdapter"]]];
    [self addInfoText:[NSString stringWithFormat:@"UnityAds Adapter: %@",
                       [self adapterVersion:@"VAMPUnityAdsSDKAdapter"]]];
    [self addInfoText:[NSString stringWithFormat:@"Pangle Adapter: %@",
                       [self adapterVersion:@"VAMPPangleSDKAdapter"]]];
    [self addInfoText:[NSString stringWithFormat:@"LINEAds Adapter: %@",
                       [self adapterVersion:@"VAMPLINEAdsSDKAdapter"]]];
    [self addInfoText:[NSString stringWithFormat:@"IronSource Adapter: %@",
                       [self adapterVersion:@"VAMPIronSourceSDKAdapter"]]];

    [self addInfoText:@"\n"];

    [self addInfoText:[NSString stringWithFormat:@"useHyperID: %@",
                       b2s(VAMP.useHyperID)]];

    [self addInfoText:@"\n"];

    // デバイス名
    [self addInfoText:[NSString stringWithFormat:@"device name: %@", [UIDevice currentDevice].name]];

    // OS名
    [self addInfoText:[NSString stringWithFormat:@"system name: %@", [UIDevice currentDevice].systemName]];

    // OSバージョン
    [self addInfoText:[NSString stringWithFormat:@"system version: %@", [UIDevice currentDevice].systemVersion]];

    // OSモデル
    [self addInfoText:[NSString stringWithFormat:@"OS model: %@", [UIDevice currentDevice].model]];

    // キャリア情報
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *provider = [networkInfo subscriberCellularProvider];
    [self addInfoText:[NSString stringWithFormat:@"carrier name: %@", provider.carrierName]];

    // 国コードISO
    NSString *isoCountry = provider.isoCountryCode;
    if (isoCountry.length > 0) {
        [self addInfoText:[NSString stringWithFormat:@"ISO Country code: %@", isoCountry]];
    }

    // 国コードPreferredLanguage
    NSString *countryCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    if (countryCode.length > 0) {
        [self addInfoText:[NSString stringWithFormat:@"PreferredLanguage: %@", countryCode]];
    }

    // 言語コード
    NSString *localeCode = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
    if (localeCode.length > 0) {
        [self addInfoText:[NSString stringWithFormat:@"code: %@", localeCode]];
    }

    // BundleID
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    [self addInfoText:[NSString stringWithFormat:@"BundleID: %@", bundleId]];

    // サポートOSバージョン
    [self addInfoText:[NSString stringWithFormat:@"サポート対象OS: %@",
                       b2s(VAMP.isSupported)]];
    [self addInfoText:[NSString stringWithFormat:@"ChildDirected: %@",
                       [self childDirectedString]]];

}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.adInfoView.frame = self.view.frame;
}

- (void) addInfoText:(NSString *)text {
    self.adInfoView.text = [self.adInfoView.text stringByAppendingFormat:@"\n%@", text];
}

- (NSString *) adNetworkVersion:(NSString *)adapterClass {
    Class cls = NSClassFromString(adapterClass);

    if (!cls) {
        return @"-";
    }
    SEL sel = NSSelectorFromString(@"adNetworkVersion");
    IMP method = [cls instanceMethodForSelector:sel];
    AdNetworkVersionMethod func = (void *) method;
    id obj = [cls new];
    return func(obj, sel);
}

- (NSString *) adapterVersion:(NSString *)adapterClass {
    Class cls = NSClassFromString(adapterClass);

    if (!cls) {
        return @"-";
    }
    SEL sel = NSSelectorFromString(@"adapterVersion");
    IMP method = [cls instanceMethodForSelector:sel];
    AdapterVersionMethod func = (void *) method;
    id obj = [cls new];
    NSString *ver = func(obj, sel);

    // アダプタバージョンは以下の形式のため、
    // @(#)PROGRAM:VAMPAdMobAdapter  PROJECT:VAMPAdMobAdapter-9.3.0.0\n
    // 最後のバージョン番号だけを抽出する
    NSArray<NSString *> *comps = [ver componentsSeparatedByString:@"-"];
    return [comps.lastObject
            stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] ?: @"";
}

- (NSString *) childDirectedString {
    VAMPChildDirected childDirected = VAMPPrivacySettings.childDirected;

    switch (childDirected) {
        case kVAMPChildDirectedTrue:
            return @"true";
        case kVAMPChildDirectedFalse:
            return @"false";
        case kVAMPChildDirectedUnknown:
            return @"unknown";
        default:
            return [NSString stringWithFormat:@"%ld", (long) childDirected];
    }
}
@end
