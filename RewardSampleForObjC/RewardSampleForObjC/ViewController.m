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
    // 連携アドネットワーク（AdMob、AppLovin、FAN、maio、nend、UnityAds）
    // リリースする際は必ずコメントアウトしてください。収益が発生しない広告が配信されます
//    [VAMP setTestMode:YES];
    
    // デバッグモード
    // 連携アドネットワーク（AppLovin、UnityAds、FAN、nend、Vungle、Tapjoy）
//    [VAMP setDebugMode:YES];
    
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
    
    /* アドネットワークSDK　初期化メディエーション */
    // initializeAdnwSDKを使う場合は、初期化が終わる前にAD画面へ遷移してloadしないようご注意ください。
    // ├ ステータス設定。デフォルトAUTO
    //    kVAMPInitializeStateAUTO      接続環境によって、WEIGHTとALL設定を自動的に切り替える（Wi-Fi:ALL、キャリア回線:WEIGHT）
    //    kVAMPInitializeStateWEIGHT    配信比率が高いものをひとつ初期化する
    //    kVAMPInitializeStateALL       全アドネットワークを初期化する
    //    kVAMPInitializeStateWIFIONLY  Wi-Fi接続時のみ全アドネットワークを初期化する
    // └ アドネットワークのSDKを初期化する間隔（秒数）
    //   duration:秒単位で指定する。最小4秒、最大60秒。デフォルトは10秒。（対象:AppLovin、maio、UnityAds、Vungle）
//    [[VAMP new] initializeAdnwSDK:@"*****" initializeState:kVAMPInitializeStateAUTO duration:5];    // 広告枠IDを設定してください
//    NSLog(@"[VAMP]initilizedAdnwSDK");
    
    NSString *appV = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    // VAMPのSDKバージョン
    NSString *sdkV = [VAMP SDKVersion];
    
    self.sdkVersion.text = [NSString stringWithFormat:@"APP %@(Objective-C)\nSDK %@", appV, sdkV];
    
    // 国コードの取得サンプル
    __weak typeof(self) weakSelf = self;
    [VAMP getCountryCode:^(NSString *countryCode) {
        weakSelf.sdkVersion.text = [NSString stringWithFormat:@"%@ / %@", weakSelf.sdkVersion.text, countryCode];
    }];
}

@end

