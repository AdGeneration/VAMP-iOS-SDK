//
//  ViewController.m
//  RewardSampleForObjC
//
//  Created by zaizen on 2017/02/21.
//  Copyright © 2017年 jp.bitm. All rights reserved.
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
    
    // テストモード AppLovin、maio、UnityAds
//    [VAMP setTestMode:YES];
    
    // デバッグモード AppLovin、AppVador、UnityAds
//    [VAMP setDebugMode:YES];
    
    // アドネットワークSDK　初期化メディエーション
    // initializeAdnwSDKを使う場合は、初期化が終わる前にAD画面へ遷移してloadしないようご注意ください。
    // ├ ステータス設定。デフォルトAUTO
    //    kVAMPInitializeStateAUTO	接続環境によって、WEIGHTとALL設定を自動的に切り替える（Wi-Fi:ALL、キャリア回線:WEIGHT）
    //    kVAMPInitializeStateWEIGHT 配信比率が高いものをひとつ初期化する
    //    kVAMPInitializeStateALL 全アドネットワークを初期化する
    // └ アドネットワークのSDKを初期化する間隔（秒数）
    //   duration:秒単位で指定する。最小4秒、最大60秒。デフォルトは10秒。（対象:AppLovin、maio、UnityAds）
    /*
    self.adReward = [[VAMP alloc] init];
    if ((self.adReward) != nil) {
        [self.adReward initializeAdnwSDK:@"*****" initializeState:kVAMPInitializeStateALL duration:5];
        NSLog(@"[VAMP]initilizedAdnwSDK");
    }
     */
    
    // アプリバージョン。info.plistから取得
    NSString *appV = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    // VAMPのSDKバージョン
    NSString *sdkV = [VAMP SDKVersion];
    
    // バージョン情報
    self.sdkVersion.text = [NSString stringWithFormat:@"APP %@\nSDK %@\n", appV, sdkV];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 画面遷移部
-(IBAction) Reword1
{
    [self performSegueWithIdentifier:@"pushReword1" sender:self];
}

-(IBAction) Reword2
{
    [self performSegueWithIdentifier:@"pushReword2" sender:self];
}

-(IBAction) Info
{
    [self performSegueWithIdentifier:@"pushInfo" sender:self];
}

-(IBAction) Ad2
{
    [self performSegueWithIdentifier:@"pushAd2" sender:self];
}

@end

