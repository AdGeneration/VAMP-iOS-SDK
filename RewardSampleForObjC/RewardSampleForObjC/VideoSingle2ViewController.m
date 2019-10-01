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
#import "UIColor+Extension.h"

@interface VideoSingleViewController ()

- (void)addLogText:(NSString *)message;
- (void)addLogText:(NSString *)message color:(nonnull UIColor *)color;
- (void)pauseSound;
- (void)resumeSound;

@end

@interface VideoSingle2ViewController () <VAMPDelegate>

@property (nonatomic, weak) IBOutlet UITextField *adcodeField;
@property (nonatomic, weak) IBOutlet UITextView *adLogView;

@property (nonatomic) VAMP *vamp;

@end

@implementation VideoSingle2ViewController

static NSString * const kPlacementId = @"59755";    // 広告枠IDを設定してください

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // VAMPインスタンスを生成し初期化
    self.vamp = [VAMP new];
    self.vamp.delegate = self;
    [self.vamp setPlacementId:self.placementId];
    [self.vamp setRootViewController:self];
    
    // 画面表示時に広告をプリロード
    [self.vamp preload];
}

- (NSString *)placementId {
    return kPlacementId;
}

- (IBAction)showAd:(id)sender {
    // 広告取得済みか判定
    if (self.vamp.isReady) {
        [self addLogText:@"[show]"];
        [self pauseSound];
        
        // 広告表示
        [self.vamp show];
    }
    else {
        [self addLogText:@"[load]"];
        
        // 広告取得
        [self.vamp load];
    }
}

#pragma mark - VAMPDelegate

// 広告表示が可能になると通知
- (void)vampDidReceive:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidReceive(%@, %@)", adnwName, placementId]];
    [self addLogText:@"[show]"];
    [self pauseSound];
    
    [self.vamp show];
}

// 全アドネットワークにおいて広告が取得できなかったときに通知
- (void)vamp:(VAMP *)vamp didFailToLoadWithError:(VAMPError *)error withPlacementId:(NSString *)placementId {
    [self addLogText:[NSString stringWithFormat:@"vampDidFailToLoad(%@, %@)", error.localizedDescription, placementId]
               color:UIColor.systemRedColor];
    
    // 必要に応じて広告の再ロード
//    if (/* 任意のリトライ条件 */) {
//        [vamp load];
//    }
    VAMPErrorCode code = error.code;
    if(code == VAMPErrorCodeNoAdStock) {
        // 在庫が無いので、再度loadをしてもらう必要があります。
        // 連続で発生する場合、時間を置いてからloadをする必要があります。
        NSLog(@"[VAMP]vampDidFailToLoad(VAMPErrorCodeNoAdStock, %@)", error.localizedDescription);
    } else if(code == VAMPErrorCodeNoAdnetwork) {
        // アドジェネ管理画面でアドネットワークの配信がONになっていない、
        // またはEU圏からのアクセスの場合(GDPR)に発生します。
        NSLog(@"[VAMP]vampDidFailToLoad(VAMPErrorCodeNoAdnetwork, %@)", error.localizedDescription);
    } else if(code == VAMPErrorCodeNeedConnection) {
        // ネットワークに接続できない状況です。
        // 電波状況をご確認ください。
        NSLog(@"[VAMP]vampDidFailToLoad(VAMPErrorCodeNeedConnection, %@)", error.localizedDescription);
    } else if(code == VAMPErrorCodeMediationTimeout) {
        // アドネットワークSDKから返答が得られず、タイムアウトしました。
        NSLog(@"[VAMP]vampDidFailToLoad(VAMPErrorCodeMediationTimeout, %@)", error.localizedDescription);
    }
}

// 広告の表示に失敗したときに通知
- (void)vamp:(VAMP *)vamp didFailToShowWithError:(VAMPError *)error withPlacementId:(NSString *)placementId {
    [self addLogText:[NSString stringWithFormat:@"vampDidFailToShow(%@, %@)",
                      error.localizedDescription, placementId]
               color:UIColor.systemRedColor];
    if (error.code == VAMPErrorCodeUserCancel) {
        // ユーザが広告再生を途中でキャンセルしました。
        // AdMobは動画再生の途中でユーザーによるキャンセルが可能
        NSLog(@"[VAMP]vampDidFailToShow(VAMPErrorCodeUserCancel, %@)", error.localizedDescription);
    }
    
    [self resumeSound];
}

// インセンティブ付与が可能になったタイミングで通知
// アドネットワークによって通知タイミングが異なる（動画再生完了時、またはエンドカードを閉じたタイミング）
- (void)vampDidComplete:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidComplete(%@, %@)", adnwName, placementId]
               color:UIColor.systemBlueColor];
}

// 広告が閉じられた時に通知
- (void)vampDidClose:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidClose(%@, %@)", adnwName, placementId]
               color:UIColor.defaultLabelColor];
    [self resumeSound];
    
    // 必要に応じて次に表示する広告をプリロード
//    [self.vamp preload];
}

@end
