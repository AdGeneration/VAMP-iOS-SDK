//
//  ViewController.m
//  RewardSampleForObjC
//
//  Created by AdGeneration on 2017/02/21.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import "ViewController.h"
#import <VAMP/VAMP.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UILabel* sdkVersion;
@property (nonatomic, strong) VAMP* adReward;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 対応OSバージョン
    NSLog(@"supportedOSVersion:%.01f", [VAMP SupportedOSVersion]);
        
    /* テストモード */
    // AppLovin、maio、UnityAds
//    [VAMP setTestMode:YES];
    
    /* デバッグモード */
    // AppLovin、AppVador、UnityAds、Vungle
//    [VAMP setDebugMode:YES];
    
    /* アドネットワークSDK　初期化メディエーション */
    // initializeAdnwSDKを使う場合は、初期化が終わる前にAD画面へ遷移してloadしないようご注意ください。
    // ├ ステータス設定。デフォルトAUTO
    //    kVAMPInitializeStateAUTO      接続環境によって、WEIGHTとALL設定を自動的に切り替える（Wi-Fi:ALL、キャリア回線:WEIGHT）
    //    kVAMPInitializeStateWEIGHT    配信比率が高いものをひとつ初期化する
    //    kVAMPInitializeStateALL       全アドネットワークを初期化する
    //    kVAMPInitializeStateWIFIONLY  Wi-Fi接続時のみ全アドネットワークを初期化する
    // └ アドネットワークのSDKを初期化する間隔（秒数）
    //   duration:秒単位で指定する。最小4秒、最大60秒。デフォルトは10秒。（対象:AppLovin、maio、UnityAds、Vungle）
    /*
    self.adReward = [[VAMP alloc] init];
    if ((self.adReward) != nil) {
        [self.adReward initializeAdnwSDK:@"*****" initializeState:kVAMPInitializeStateAUTO duration:5];
        NSLog(@"[VAMP]initilizedAdnwSDK");
    }
    */
    
    // アプリバージョン。info.plistから取得
    NSString *appV = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    // VAMPのSDKバージョン
    NSString *sdkV = [VAMP SDKVersion];
    
    // バージョン情報
    self.sdkVersion.text = [NSString stringWithFormat:@"APP %@(Objective-C)\nSDK %@", appV, sdkV];
    
    // 国コードの取得サンプル
    __weak typeof(self) weakSelf = self;
    [VAMP getCountryCode:^(NSString *countryCode) {
        weakSelf.sdkVersion.text = [NSString stringWithFormat:@"%@ / %@", weakSelf.sdkVersion.text, countryCode];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

