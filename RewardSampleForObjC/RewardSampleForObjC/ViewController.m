//
//  ViewController.m
//  RewardSampleForObjC
//
//  Created by AdGeneration on 2017/02/21.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import <VAMP/VAMP.h>

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *sdkVersion;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // VAMPが対応するiOSの最低バージョン
    NSLog(@"[VAMP]supportedOSVersion:%.01f", [VAMP SupportedOSVersion]);

    // テストモード
    // 連携アドネットワーク（AdMob、AppLovin、FAN、maio、nend、UnityAds、Mintegral、MoPub）
    // リリースする際は必ずコメントアウトしてください。収益が発生しない広告が配信されます
    [VAMP setTestMode:YES];

    // デバッグモード
    // 連携アドネットワーク（AppLovin、UnityAds、FAN、nend、Vungle、Tapjoy、MoPub）
    [VAMP setDebugMode:YES];

    // ユーザ属性の設定
//    // 誕生日
//    NSDateComponents *components = [NSDateComponents new];
//    components.year = 1980;
//    components.month = 2;
//    components.day = 20;
//    NSDate *birthday = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]
//                        dateFromComponents:components];
//    [VAMP setBirthday:birthday];
//    // 性別
//    [VAMP setGender:kVAMPGenderMale];

    VAMPConfiguration *vampConfiguration = [VAMPConfiguration defaultConfiguration];
    vampConfiguration.playerCancelable = YES;
    vampConfiguration.playerAlertTitleText = @"動画を終了しますか？";
    vampConfiguration.playerAlertBodyText = @"報酬がもらえません";
    vampConfiguration.playerAlertCloseButtonText = @"動画を終了";
    vampConfiguration.playerAlertContinueButtonText = @"動画を再開";

    NSString *appV = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    // VAMPのSDKバージョン
    NSString *sdkV = [VAMP SDKVersion];

    self.sdkVersion.text = [NSString stringWithFormat:@"APP %@(Objective-C)\nSDK %@", appV, sdkV];

    // 国コードの取得サンプル
    __weak typeof(self) weakSelf = self;
    [VAMP getCountryCode:^(NSString *countryCode) {
        weakSelf.sdkVersion.text = [NSString stringWithFormat:@"%@ / %@", weakSelf.sdkVersion.text, countryCode];
//        if ([countryCode isEqualToString:@"US"]) {
//            // COPPA対象ユーザである場合はYESを設定する
//            [VAMP setChildDirected:YES];
//        }
    }];

    // EU圏内ならばユーザに同意を求めるサンプル
//    [VAMP isEUAccess:^(BOOL access) {
//        if (!access) {
//            // Nothing to do
//            return;
//        }
//
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Personalized Ads"
//                                                                       message:@"Accept?"
//                                                                preferredStyle:UIAlertControllerStyleAlert];
//
//        [alert addAction:[UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [VAMP setUserConsent:kVAMPConsentStatusAccepted];
//        }]];
//
//        [alert addAction:[UIAlertAction actionWithTitle:@"Deny" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
//            [VAMP setUserConsent:kVAMPConsentStatusDenied];
//        }]];
//
//        [self presentViewController:alert animated:YES completion:nil];
//    }];
}

@end

