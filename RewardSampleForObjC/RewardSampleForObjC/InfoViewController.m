//
//  InfoViewController.m
//  RewardSampleForObjC
//
//  Created by zaizen on 2017/02/21.
//  Copyright © 2017年 jp.bitm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AdSupport/AdSupport.h>
#import <AppLovinSDK/AppLovinSDK.h>
#import <Maio/Maio.h>
#import <UnityAds/UnityAds.h>
#import "InfoViewController.h"

@interface InfoViewController ()

@property (nonatomic, weak) IBOutlet UILabel *deviceLabel;
@property (nonatomic, weak) IBOutlet UITextView *adInfoView;

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // TextViewを上詰めで表示
    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // 通知は消す。
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidLayoutSubviews
{
    // TextViewを上詰めで表示
    self.automaticallyAdjustsScrollViewInsets = NO;

    // AppLovin SDK Version
    NSString *alSdkVersion = [ALSdk version];
    _adInfoView.text = [NSString stringWithFormat:@"AppLovinSDK:%@", alSdkVersion];
    
    // maio SDK Version
    NSString *maioSdkVersion = [Maio sdkVersion];
    _adInfoView.text = [NSString stringWithFormat:@"%@\nmaioSDK:%@", _adInfoView.text,maioSdkVersion];
    
    // UnityAds SDK Version
    NSString *unitySdkVersion = [UnityAds getVersion];
    _adInfoView.text = [NSString stringWithFormat:@"%@\nUnityAdsSDK:%@\n", _adInfoView.text,unitySdkVersion];
    
    // デバイス名
    NSString *myDeviceName = [[UIDevice currentDevice] name];
    _adInfoView.text = [NSString stringWithFormat:@"%@\ndevice name：%@", _adInfoView.text,myDeviceName];
    
    // OS名
    NSString *mySystemName = [[UIDevice currentDevice] systemName];
    _adInfoView.text = [NSString stringWithFormat:@"%@\nsystem name：%@", _adInfoView.text,mySystemName];
    
    // OSバージョン
    NSString *myOsVersion = [[UIDevice currentDevice] systemVersion];
    _adInfoView.text = [NSString stringWithFormat:@"%@\nsystem version：%@", _adInfoView.text,myOsVersion];
    
    // OSモデル
    NSString *myOsModel = [[UIDevice currentDevice] model];
    _adInfoView.text = [NSString stringWithFormat:@"%@\nOS model：%@", _adInfoView.text,myOsModel];
    
    // キャリア情報
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *provider = [networkInfo subscriberCellularProvider];
    _adInfoView.text = [NSString stringWithFormat:@"%@\ncarrier name：%@", _adInfoView.text, provider.carrierName];
    
    // 国コード
    NSString *isoCountry = provider.isoCountryCode;
    if ([isoCountry length] > 0) {
        _adInfoView.text = [NSString stringWithFormat:@"%@\nISO Country code：%@", _adInfoView.text, isoCountry];
    }
    
    // IDFA
    NSString *IDFA = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
    _adInfoView.text = [NSString stringWithFormat:@"%@\nIDFA：%@", _adInfoView.text, IDFA];
    
    // BundleID
    NSString *BundleID = [[NSBundle mainBundle] bundleIdentifier];
    _adInfoView.text = [NSString stringWithFormat:@"%@\nBundleID：%@", _adInfoView.text, BundleID];
    
    // 画面サイズ（ポイント）
    CGSize screenBounds = [UIScreen mainScreen].bounds.size;
    
    // 横
    CGFloat screenWidth = screenBounds.width;
    _adInfoView.text = [NSString stringWithFormat:@"%@\n横幅（ポイント）：%.01f", _adInfoView.text, screenWidth];
    
    // 縦
    CGFloat screenHeight = screenBounds.height;
    _adInfoView.text = [NSString stringWithFormat:@"%@\n縦幅（ポイント）：%.01f", _adInfoView.text, screenHeight];
    
    // 画面サイズ（ピクセル）
    // iOS 8.0以降で動く
    if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0)
    {
        CGSize myNativeBoundSize = [UIScreen mainScreen].nativeBounds.size;
        _adInfoView.text = [NSString stringWithFormat:@"%@\n縦幅（ピクセル）：%.01f", _adInfoView.text, myNativeBoundSize.width];
        _adInfoView.text = [NSString stringWithFormat:@"%@\n縦幅（ピクセル）：%.01f", _adInfoView.text, myNativeBoundSize.height];
    }
    
    // 言語と地域
//    NSString *myLanguageCode = [NSLocale currentLocale].languageCode;
//    _adInfoView.text = [NSString stringWithFormat:@"%@\nlanguage：%@", _adInfoView.text, myLanguageCode];
    
}

@end
