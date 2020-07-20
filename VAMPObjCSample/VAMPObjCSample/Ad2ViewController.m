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

@interface Ad2ViewController () <VAMPDelegate>

@property (weak, nonatomic) IBOutlet UILabel *placementLabel;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (nonatomic) UIBarButtonItem *soundOffButton;
@property (nonatomic) UIBarButtonItem *soundOnButton;
@property (nonatomic) AVAudioPlayer *soundPlayer;
@property (nonatomic) BOOL isPlayingPrev;
// VAMPオブジェクト
@property (nonatomic) VAMP *vamp;

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

    // VAMPインスタンスを生成し初期化
    self.vamp = [VAMP new];
    self.vamp.delegate = self;
    [self.vamp setPlacementId:kPlacementId2];

    // 画面表示時に広告をプリロード
    [self.vamp preload];
}

#pragma mark - IBAction

- (IBAction)loadAndShowButtonPressed:(id)sender {
    // 広告取得済みか判定
    if (self.vamp.isReady) {
        [self addLogText:@"[show]"];
        [self pauseSound];

        // 広告の表示
        [self.vamp showFromViewController:self];
    }
    else {
        [self addLogText:@"[load]"];

        // 広告の読み込みを開始
        [self.vamp load];
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

#pragma mark - VAMPDelegate

// 広告取得完了
//
// 広告表示が可能になると通知されます
- (void)vampDidReceive:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidReceive(%@, %@)", adnwName, placementId]];
    [self addLogText:@"[show]"];
    [self pauseSound];
}

// 広告取得失敗
//
// 広告が取得できなかったときに通知されます。例）在庫が無い、タイムアウトなど
// @see https://github.com/AdGeneration/VAMP-iOS-SDK/wiki/VAMP-iOS-API-Errors
- (void)vamp:(VAMP *)vamp didFailToLoadWithError:(VAMPError *)error withAd:(VAMPAd *)ad {
    [self addLogText:[NSString stringWithFormat:@"vampDidFailToLoad(%@, %@)", error.localizedDescription, ad.placementId]
               color:UIColor.redColor];

    // 必要に応じて広告の再ロード
//    if (/* 任意のリトライ条件 */) {
//        [vamp load];
//    }

    VAMPErrorCode code = error.code;

    if (code == VAMPErrorCodeNoAdStock) {
        // 在庫が無いので、再度loadをしてもらう必要があります。
        // 連続で発生する場合、時間を置いてからloadをする必要があります。
        NSLog(@"[VAMP]vampDidFailToLoad(VAMPErrorCodeNoAdStock, %@)", error.localizedDescription);
    }
    else if (code == VAMPErrorCodeNoAdnetwork) {
        // アドジェネ管理画面でアドネットワークの配信がONになっていない、
        // またはEU圏からのアクセスの場合(GDPR)に発生します。
        NSLog(@"[VAMP]vampDidFailToLoad(VAMPErrorCodeNoAdnetwork, %@)", error.localizedDescription);
    }
    else if (code == VAMPErrorCodeNeedConnection) {
        // ネットワークに接続できない状況です。
        // 電波状況をご確認ください。
        NSLog(@"[VAMP]vampDidFailToLoad(VAMPErrorCodeNeedConnection, %@)", error.localizedDescription);
    }
    else if (code == VAMPErrorCodeMediationTimeout) {
        // アドネットワークSDKから返答が得られず、タイムアウトしました。
        NSLog(@"[VAMP]vampDidFailToLoad(VAMPErrorCodeMediationTimeout, %@)", error.localizedDescription);
    }
}

// 広告表示失敗
//
// showを実行したが、何らかの理由で広告表示が失敗したときに通知されます。
// 例）ユーザーが広告再生を途中でキャンセルなど
- (void)vamp:(VAMP *)vamp didFailToShowWithError:(VAMPError *)error withAd:(VAMPAd *)ad {
    [self addLogText:[NSString stringWithFormat:@"vampDidFailToShow(%@, %@)",
                                                error.localizedDescription, ad.placementId]
               color:UIColor.redColor];

    if (error.code == VAMPErrorCodeUserCancel) {
        // ユーザが広告再生を途中でキャンセルしました。
        // AdMobは動画再生の途中でユーザーによるキャンセルが可能
        NSLog(@"[VAMP]vampDidFailToShow(VAMPErrorCodeUserCancel, %@)", error.localizedDescription);
    }

    [self resumeSound];
}

// インセンティブ付与OK
//
// インセンティブ付与が可能になったタイミングで通知されます。
// アドネットワークによって通知タイミングは異なります（動画再生完了時、またはエンドカードを閉じたタイミング）
- (void)vamp:(VAMP *)vamp didCompleteAd:(VAMPAd *)ad {
    [self addLogText:[NSString stringWithFormat:@"vampDidComplete(%@, %@)", ad.adnwName, ad.placementId]
               color:UIColor.blueColor];
}

// 広告表示終了
//
// エンドカードが閉じられたとき、または途中で広告再生がキャンセルされたときに通知されます
- (void)vamp:(VAMP *)vamp didCloseAd:(VAMPAd *)ad adClicked:(BOOL)adClicked {
    [self addLogText:[NSString stringWithFormat:@"vampDidClose(%@, %@)", ad.adnwName, ad.placementId]
               color:UIColor.blackColor];
    [self resumeSound];

    // 必要に応じて次に表示する広告をプリロード
//    [self.vamp preload];
}

// 広告の有効期限切れ
//
// 広告取得完了から55分経つと取得した広告の表示はできてもRTBの収益は発生しません。
// この通知を受け取ったら、もう一度loadからやり直してください
- (void)vamp:(VAMP *)vamp didExpireWithPlacementId:(NSString *)placementId {
    [self addLogText:[NSString stringWithFormat:@"vampDidExpired(%@)", placementId]
               color:UIColor.redColor];
}

// ロード処理のプログレス通知
//
// アドネットワークの広告取得が開始されたときに通知されます
- (void)vamp:(VAMP *)vamp loadStartAd:(VAMPAd *)ad {
    [self addLogText:[NSString stringWithFormat:@"vampLoadStart(%@, %@)", ad.adnwName, ad.placementId]];
}

// ロード処理のプログレス通知
//
// アドネットワークの広告取得結果が通知されます。成功時はsuccess=YESとなりロード処理は終了します。
// success=NOのときは次位のアドネットワークがある場合はロード処理が継続されます
- (void)vamp:(VAMP *)vamp loadResultAd:(VAMPAd *)ad success:(BOOL)success message:(NSString *)message {
    if (success) {
        [self addLogText:[NSString stringWithFormat:@"vampLoadResult(%@, %@, success:OK)", ad.adnwName, ad.placementId]
                   color:UIColor.blackColor];
        [self.vamp showFromViewController:self];
    }
    else {
        [self addLogText:[NSString stringWithFormat:@"vampLoadResult(%@, %@, success:NG, %@)",
                                                    ad.adnwName,
                                                    ad.placementId,
                                                    message]
                   color:UIColor.redColor];
    }
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
