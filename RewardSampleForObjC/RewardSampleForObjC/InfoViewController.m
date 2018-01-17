//
//  InfoViewController.m
//  RewardSampleForObjC
//
//  Created by AdGeneration on 2017/02/21.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AdSupport/AdSupport.h>

#import <VAMP/VAMP.h>
#import <AppLovinSDK/AppLovinSDK.h>
#import <Maio/Maio.h>
#import <UnityAds/UnityAds.h>
#import <VungleSDK/VungleSDK.h>
#import <NendAd/NendAd.h>
#import <Tapjoy/Tapjoy.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>

#import "InfoViewController.h"

@interface InfoViewController ()

@property (nonatomic, weak) IBOutlet UITextView *adInfoView;

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.adInfoView.text = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Admob SDK Version
    NSString *admobVersion = [NSString stringWithCString:(const char *) GoogleMobileAdsVersionString
                                                encoding:NSUTF8StringEncoding];
    [self addInfoText:[NSString stringWithFormat:@"AdmobSDK: %@", admobVersion]];
    
    // AppLovin SDK Version
    [self addInfoText:[NSString stringWithFormat:@"AppLovinSDK: %@", [ALSdk version]]];
    
    // FAN SDK Version
#ifdef FB_AD_SDK_VERSION
    [self addInfoText:[NSString stringWithFormat:@"FAN SDK: %@", FB_AD_SDK_VERSION]];
#endif
    
    // maio SDK Version
    [self addInfoText:[NSString stringWithFormat:@"maioSDK: %@", [Maio sdkVersion]]];
    
    // nend SDK Version
    [self addInfoText:[NSString stringWithFormat:@"nendSDK: %s", NendAdVersionString]];
    
    // Tapjoy SDK Version
    [self addInfoText:[NSString stringWithFormat:@"TapjoySDK: %@", [Tapjoy getVersion]]];
    
    // UnityAds SDK Version
    [self addInfoText:[NSString stringWithFormat:@"UnityAdsSDK: %@", [UnityAds getVersion]]];
    
    // Vungle SDK Version
    [self addInfoText:[NSString stringWithFormat:@"VungleSDK: %@", VungleSDKVersion]];
    
    [self addInfoText:@"\n"];
    
    // デバイス名
    [self addInfoText:[NSString stringWithFormat:@"device name: %@", [UIDevice currentDevice].name]];
    
    // OS名
    [self addInfoText:[NSString stringWithFormat:@"system name: %@", [UIDevice currentDevice].systemVersion]];
    
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
    NSString * countryCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    if (countryCode.length > 0) {
        [self addInfoText:[NSString stringWithFormat:@"PreferredLanguage: %@", countryCode]];
    }
    
    // 言語コード
    NSString * localeCode = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
    if (localeCode.length > 0) {
        [self addInfoText:[NSString stringWithFormat:@"code: %@", localeCode]];
    }
    
    // IDFA
    NSString *idfa = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
    [self addInfoText:[NSString stringWithFormat:@"IDFA: %@", idfa]];
    
    // IDFV
    NSString *idfv = [UIDevice currentDevice].identifierForVendor.UUIDString;
    [self addInfoText:[NSString stringWithFormat:@"IDFV: %@", idfv]];
    
    // BundleID
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    [self addInfoText:[NSString stringWithFormat:@"BundleID: %@", bundleId]];
    
    // 画面サイズ（ポイント）
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [self addInfoText:[NSString stringWithFormat:@"横幅（ポイント）: %.01f", screenSize.width]];
    [self addInfoText:[NSString stringWithFormat:@"縦幅（ポイント）: %.01f", screenSize.height]];
    
    // 画面サイズ（ピクセル）
    // iOS 8.0以降で動く
    if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0) {
        CGSize screenSize = [UIScreen mainScreen].nativeBounds.size;
        [self addInfoText:[NSString stringWithFormat:@"縦幅（ピクセル）: %.01f", screenSize.width]];
        [self addInfoText:[NSString stringWithFormat:@"縦幅（ピクセル）: %.01f", screenSize.height]];
    }
    
    // サポートOSバージョン
    [self addInfoText:[NSString stringWithFormat:@"サポートOSバージョン: %.01f以上", [VAMP SupportedOSVersion]]];
    [self addInfoText:[NSString stringWithFormat:@"サポート対象OS: %@", [VAMP isSupportedOSVersion] ? @"true" : @"false"]];
}

- (void)addInfoText:(NSString *)text {
    self.adInfoView.text = [self.adInfoView.text stringByAppendingFormat:@"\n%@", text];
}

@end

