//
//  Ad2ViewController.m
//  VAMPObjCSample
//
//  Created by Supership Inc. on 2019/04/15.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

// VAMP SDKのインポート
#import <VAMP/VAMP.h>

#import "Ad2ViewController.h"

@interface Ad2ViewController () <VAMPRewardedAdDelegate>

@property (weak, nonatomic) IBOutlet UILabel *placementLabel;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (nonatomic) UIBarButtonItem *soundOffButton;
@property (nonatomic) UIBarButtonItem *soundOnButton;
@property (nonatomic) AVAudioPlayer *soundPlayer;
@property (nonatomic) BOOL isPlayingPrev;
// VAMPRewardedAdオブジェクト
@property (nonatomic) VAMPRewardedAd *rewardedAd;
@property (nonatomic) VAMPVideoConfiguration *videoConfiguration;

@end

@implementation Ad2ViewController

// 広告枠IDを設定してください
//   59755 : iOSテスト用ID (このIDのままリリースしないでください)
static NSString *const kPlacementId2 = @"59755";

+ (instancetype)instantiateViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    Ad2ViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Ad2"];
    return viewController;
}

- (void)loadView {
    [super loadView];

    UIImage *soundOnImage = [[UIImage imageNamed:@"soundon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.soundOffButton = [[UIBarButtonItem alloc] initWithImage:soundOnImage
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(soundOff)];

    UIImage *soundOffImage = [[UIImage imageNamed:@"soundoff"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.soundOnButton = [[UIBarButtonItem alloc] initWithImage:soundOffImage
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(soundOn)];

    self.navigationItem.rightBarButtonItem = self.soundOnButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Ad2";

    self.placementLabel.text = [NSString stringWithFormat:@"Placement ID: %@", kPlacementId2];

    NSURL *soundUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"invisible" ofType:@"mp3"]];
    self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [self.soundPlayer prepareToPlay];

    // テストモード確認
    NSLog(@"[VAMP]isTestMode:%@", VAMP.isTestMode ? @"YES" : @"NO");

    // デバッグモード確認
    NSLog(@"[VAMP]isDebugMode:%@", VAMP.isDebugMode ? @"YES" : @"NO");

    [self addLogText:[NSString stringWithFormat:@"TestMode:%@ DebugMode:%@",
                                                VAMP.isTestMode ? @"YES" : @"NO",
                                                VAMP.isDebugMode ? @"YES" : @"NO"]];

    // VAMPVidepConfigurationインスタンスを生成し初期化
    self.videoConfiguration = VAMPVideoConfiguration.configuration;
    self.videoConfiguration.playerAlertTitleText = @"動画を終了しますか？";
    self.videoConfiguration.playerAlertBodyText = @"報酬がもらえません";
    self.videoConfiguration.playerAlertCloseButtonText = @"動画を終了";
    self.videoConfiguration.playerAlertContinueButtonText = @"動画を再開";

    // VAMPRewardedAdインスタンスを生成し初期化
    self.rewardedAd = [[VAMPRewardedAd alloc] initWithPlacementID:kPlacementId2];
    self.rewardedAd.delegate = self;

    // 画面表示時に広告をプリロード
    VAMPRequest *request = VAMPRequest.request;
    request.videoConfiguration = self.videoConfiguration;
    [self.rewardedAd preloadRequest:request];
}

#pragma mark - IBAction

- (IBAction)loadAndShowButtonPressed:(id)sender {
    // 広告取得済みか判定
    if (self.rewardedAd.isReady) {
        [self addLogText:@"[show]"];
        [self pauseSound];

        // 広告の表示
        [self.rewardedAd showFromViewController:self];
    }
    else {
        [self addLogText:@"[load]"];

        // 広告の読み込みを開始
        VAMPRequest *request = VAMPRequest.request;
        request.videoConfiguration = self.videoConfiguration;
        [self.rewardedAd loadRequest:request];
    }
}

- (void)soundOff {
    self.navigationItem.rightBarButtonItem = self.soundOnButton;
    [self.soundPlayer pause];
}

- (void)soundOn {
    self.navigationItem.rightBarButtonItem = self.soundOffButton;
    [self.soundPlayer play];
}

#pragma mark - VAMPRewardedAdDelegate

// 広告取得完了
//
// 広告表示が可能になると通知されます
- (void)rewardedAdDidReceive:(VAMPRewardedAd *)rewardedAd {
    [self addLogText:[NSString stringWithFormat:@"rewardedAdDidReceive(%@)", rewardedAd.responseInfo.adNetworkName]];
    [self addLogText:@"[show]"];
    [self pauseSound];

    [self.rewardedAd showFromViewController:self];
}

// 広告取得失敗
//
// 広告が取得できなかったときに通知されます。例）在庫が無い、タイムアウトなど
- (void)rewardedAd:(VAMPRewardedAd *)rewardedAd didFailToLoadWithError:(VAMPError *)error {
    [self addLogText:[NSString stringWithFormat:@"rewardedAd:didFailToLoadWithError(%@)", error.localizedDescription]
               color:UIColor.redColor];

    // 必要に応じて広告の再ロード
//    if (/* 任意のリトライ条件 */) {
//        VAMPRequest *request = VAMPRequest.request;
//        request.videoConfiguration = self.videoConfiguration;
//        [self.rewardedAd loadRequest:request];
//    }

    VAMPErrorCode code = error.code;

    if (code == VAMPErrorCodeNoAdStock) {
        // 在庫が無いので、再度loadをしてもらう必要があります。
        // 連続で発生する場合、時間を置いてからloadをする必要があります。
        NSLog(@"[VAMP]rewardedAd:didFailToLoadWithError(VAMPErrorCodeNoAdStock, %@)", error.localizedDescription);
    }
    else if (code == VAMPErrorCodeNoAdnetwork) {
        // アドジェネ管理画面でアドネットワークの配信がONになっていない、
        // またはEU圏からのアクセスの場合(GDPR)に発生します。
        NSLog(@"[VAMP]rewardedAd:didFailToLoadWithError(VAMPErrorCodeNoAdnetwork, %@)", error.localizedDescription);
    }
    else if (code == VAMPErrorCodeNeedConnection) {
        // ネットワークに接続できない状況です。
        // 電波状況をご確認ください。
        NSLog(@"[VAMP]rewardedAd:didFailToLoadWithError(VAMPErrorCodeNeedConnection, %@)", error.localizedDescription);
    }
    else if (code == VAMPErrorCodeMediationTimeout) {
        // アドネットワークSDKから返答が得られず、タイムアウトしました。
        NSLog(@"[VAMP]rewardedAd:didFailToLoadWithError(VAMPErrorCodeMediationTimeout, %@)", error.localizedDescription);
    }
}

// 広告表示失敗
//
// showを実行したが、何らかの理由で広告表示が失敗したときに通知されます。
// 例）ユーザーが広告再生を途中でキャンセルなど
- (void)rewardedAd:(VAMPRewardedAd *)rewardedAd didFailToShowWithError:(VAMPError *)error {
    [self addLogText:[NSString stringWithFormat:@"rewardedAd:didFailToShowWithError(%@)",
                                                error.localizedDescription]
               color:UIColor.redColor];

    if (error.code == VAMPErrorCodeUserCancel) {
        // ユーザが広告再生を途中でキャンセルしました。
        // AdMobは動画再生の途中でユーザーによるキャンセルが可能
        NSLog(@"[VAMP]rewardedAd:didFailToShowWithError(VAMPErrorCodeUserCancel, %@)", error.localizedDescription);
    }

    [self resumeSound];
}

// インセンティブ付与OK
//
// インセンティブ付与が可能になったタイミングで通知されます。
// アドネットワークによって通知タイミングは異なります（動画再生完了時、またはエンドカードを閉じたタイミング）
- (void)rewardedAdDidComplete:(VAMPRewardedAd *)rewardedAd {
    [self addLogText:@"rewardedAdDidComplete()"
               color:UIColor.blueColor];
}

// 広告表示終了
//
// エンドカードが閉じられたとき、または途中で広告再生がキャンセルされたときに通知されます
- (void)rewardedAd:(VAMPRewardedAd *)rewardedAd didCloseWithClickedFlag:(BOOL)clickedFlag {
    [self addLogText:[NSString stringWithFormat:@"rewardedAd:didCloseWithClickedFlag(Click:%@)", clickedFlag ? @"YES" : @"NO"]
               color:UIColor.blackColor];
    [self resumeSound];

    // 必要に応じて次に表示する広告をプリロード
    VAMPRequest *request = VAMPRequest.request;
    request.videoConfiguration = self.videoConfiguration;
    [self.rewardedAd preloadRequest:request];
}

// 広告の有効期限切れ
//
// 広告取得完了から55分経つと取得した広告の表示はできてもRTBの収益は発生しません。
// この通知を受け取ったら、もう一度loadからやり直してください
- (void)rewardedAdDidExpire:(VAMPRewardedAd *)rewardedAd {
    [self addLogText:@"rewardedAdDidExpired()"
               color:UIColor.redColor];
}

// ロード処理のプログレス通知
//
// アドネットワークの広告取得が開始されたときに通知されます
- (void)rewardedAd:(VAMPRewardedAd *)rewardedAd didStartLoadingAd:(NSString *)adNetworkName {
    [self addLogText:[NSString stringWithFormat:@"rewardedAd:didStartLoadingAd(%@)", adNetworkName]];
}

// ロード処理のプログレス通知
//
// アドネットワークの広告取得結果が通知されます。成功時はerror==nilとなりロード処理は終了します。
// error!=nilのときは次位のアドネットワークがある場合はロード処理が継続されます
- (void)rewardedAd:(VAMPRewardedAd *)rewardedAd didLoadAd:(NSString *)adNetworkName withError:(VAMPError *)error {
    [self addLogText:[NSString stringWithFormat:@"rewardedAd:didLoadAd:withError(%@, %@)", adNetworkName, error.description]
               color:error != nil ? UIColor.redColor : UIColor.blackColor];
}

#pragma mark - private method

- (void)addLogText:(NSString *)message color:(nonnull UIColor *)color {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale systemLocale];
    dateFormatter.dateFormat = @"MM-dd HH:mm:ss ";

    NSAttributedString *attributedNow = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",
                                                                                                              [dateFormatter stringFromDate:now]]
                                                                        attributes:@{ NSForegroundColorAttributeName: UIColor.grayColor }];

    NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",
                                                                                                                  message]
                                                                            attributes:@{ NSForegroundColorAttributeName: color }];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
        [mutableAttributedString appendAttributedString:attributedNow];
        [mutableAttributedString appendAttributedString:attributedMessage];

        [mutableAttributedString appendAttributedString:self.logTextView.attributedText];
        self.logTextView.attributedText = mutableAttributedString;
    });

    NSLog(@"[VAMP]%@", message);
}

- (void)addLogText:(NSString *)message {
    [self addLogText:message color:UIColor.grayColor];
}

- (void)pauseSound {
    self.isPlayingPrev = self.soundPlayer.isPlaying;

    if (self.soundPlayer.isPlaying) {
        [self.soundPlayer pause];
    }
}

- (void)resumeSound {
    if (self.isPlayingPrev) {
        [self.soundPlayer play];
    }
}

@end
