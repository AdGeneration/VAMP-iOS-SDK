//
//  Ad1ViewController.m
//  VAMPObjCSample
//
//  Created by Supership Inc. on 2019/04/15.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

// VAMP SDKのインポート
#import <VAMP/VAMP.h>

#import "Ad1ViewController.h"

@interface Ad1ViewController () <VAMPRewardedAdLoadAdvancedDelegate, VAMPRewardedAdShowDelegate>

@property (weak, nonatomic) IBOutlet UILabel *placementLabel;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (nonatomic) UIBarButtonItem *soundOffButton;
@property (nonatomic) UIBarButtonItem *soundOnButton;
@property (nonatomic) AVAudioPlayer *soundPlayer;
@property (nonatomic) BOOL isPlayingPrev;
@property (nonatomic, copy) NSString *placementId;

@end

@implementation Ad1ViewController

+ (instancetype) instantiateViewControllerWithPlacementId:(NSString *)placementId {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    Ad1ViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Ad1"];

    viewController.placementId = placementId;
    return viewController;
}


- (void) loadView {
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

- (void) viewDidLoad {
    [super viewDidLoad];

    self.title = @"Ad1";

    self.placementLabel.text = [NSString stringWithFormat:@"Placement ID: %@", self.placementId];

    NSURL *soundUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"invisible" ofType:@"mp3"]];
    self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [self.soundPlayer prepareToPlay];

    [self addLogText:[NSString stringWithFormat:@"TestMode:%@ DebugMode:%@",
                      VAMP.isTestMode ? @"YES" : @"NO",
                      VAMP.isDebugMode ? @"YES" : @"NO"]];
    NSLog(@"[VAMP]isTestMode:%@", VAMP.isTestMode ? @"YES" : @"NO");
    NSLog(@"[VAMP]isDebugMode:%@", VAMP.isDebugMode ? @"YES" : @"NO");
}

#pragma mark - IBAction

- (IBAction) loadButtonPressed:(id)sender {
    [self addLogText:@"[load]"];

    // 広告の読み込みを開始
    VAMPRequest *request = VAMPRequest.request;
    [VAMPRewardedAd loadWithPlacementID:self.placementId request:request delegate:self];
}

- (IBAction) showButtonPressed:(id)sender {
    // 広告の準備ができているか確認してから表示
    VAMPRewardedAd *rewardedAd = [VAMPRewardedAd rewardedAdOfPlacementID:self.placementId];

    if (rewardedAd) {
        [self addLogText:@"[show]"];
        [self pauseSound];

        // 広告の表示
        [rewardedAd showFromViewController:self delegate:self];
    }
    else {
        NSLog(@"[VAMP]not ready");
    }
}

- (void) soundOff {
    self.navigationItem.rightBarButtonItem = self.soundOnButton;
    [self.soundPlayer pause];
}

- (void) soundOn {
    self.navigationItem.rightBarButtonItem = self.soundOffButton;
    [self.soundPlayer play];
}

#pragma mark - VAMPRewardedAdLoadAdvancedDelegate

/**
 * 広告表示が可能になると通知されます。
 *
 * @param placementID 広告枠ID
 */
- (void) rewardedAdDidReceiveWithPlacementID:(NSString *)placementID {
    [self addLogText:[NSString stringWithFormat:@"didReceive(%@)", placementID]];
}

/**
 * 広告の取得に失敗すると通知されます。
 *
 * 例) 広告取得時のタイムアウトや、全てのアドネットワークの在庫がない場合など。
 *
 * EU圏からのアクセスの場合( `VAMPErrorCodeNoAdnetwork` )が発生します。2018-05-23現在 ※本仕様は変更する可能性があります。
 *
 * @param placementID 広告枠ID
 * @param error `VAMPError` オブジェクト
 */
- (void) rewardedAdDidFailToLoadWithPlacementID:(NSString *)placementID error:(VAMPError *)error {
    [self addLogText:[NSString stringWithFormat:@"didFailToLoad(%@, %@)", placementID, error.localizedDescription]
               color:UIColor.systemRedColor];

    VAMPErrorCode code = error.code;

    if (code == VAMPErrorCodeNoAdStock) {
        // 在庫が無いので、再度loadをしてもらう必要があります。
        // 連続で発生する場合、時間を置いてからloadをする必要があります。
    }
    else if (code == VAMPErrorCodeNoAdnetwork) {
        // アドジェネ管理画面でアドネットワークの配信がONになっていない、
        // またはEU圏からのアクセスの場合(GDPR)に発生します。
    }
    else if (code == VAMPErrorCodeNeedConnection) {
        // ネットワークに接続できない状況です。
        // 電波状況をご確認ください。
    }
    else if (code == VAMPErrorCodeMediationTimeout) {
        // アドネットワークSDKから返答が得られず、タイムアウトしました。
    }
}

/**
 * RTBはロードが完了してから1時間経過すると、広告表示ができても無効扱いとなり、収益が発生しません。
 *
 * この通知を受け取ったらロードからやり直してください。
 *
 * @param placementID 広告枠ID
 */
- (void) rewardedAdDidExpireWithPlacementID:(NSString *)placementID {
    [self addLogText:[NSString stringWithFormat:@"didExpire(%@)", placementID]
               color:UIColor.systemRedColor];
}

/**
 * アドネットワークごとの広告取得が開始されたときに通知されます。
 *
 * @param adNetworkName アドネットワーク名
 * @param placementID 広告枠ID
 */
- (void) rewardedAdDidStartLoading:(NSString *)adNetworkName withPlacementID:(NSString *)placementID {
    [self addLogText:[NSString stringWithFormat:@"didStartLoading(%@, %@)", adNetworkName, placementID]];
}

/**
 * アドネットワークごとの広告取得結果が通知されます。
 * このイベントは、ロードの成功時、失敗時どちらの場合も通知されます。
 * 広告のロードに成功した時は `error==nil` となりロード処理は成功終了します。
 * `error!=nil` の時は次の配信可能なアドネットワークがある場合、ロード処理は継続されます。ない場合は失敗終了します。
 *
 * @param adNetworkName アドネットワーク名
 * @param placementID 広告枠ID
 * @param error `VAMPError` オブジェクト
 */
- (void) rewardedAdDidLoad:(NSString *)adNetworkName withPlacementID:(NSString *)placementID error:(VAMPError *)error {
    [self addLogText:[NSString stringWithFormat:@"didLoad(%@, %@, error:%@)", adNetworkName, placementID, error.localizedDescription]
               color:error ? UIColor.systemRedColor : UIColor.blackColor];
}

#pragma mark - VAMPRewardedAdShowDelegate

/**
 * 広告の表示に失敗すると通知されます。
 *
 * 例) 視聴完了する前にユーザがキャンセルするなど。
 *
 * @param rewardedAd `VAMPRewardedAd` オブジェクト
 * @param error `VAMPError` オブジェクト
 */
- (void) rewardedAd:(VAMPRewardedAd *)rewardedAd didFailToShowWithError:(VAMPError *)error {
    [self addLogText:[NSString stringWithFormat:@"didFailToShow(%@)", error.localizedDescription]
               color:UIColor.systemRedColor];

    if (error.code == VAMPErrorCodeUserCancel) {
        // ユーザが広告再生を途中でキャンセルしました。
        // AdMobは動画再生の途中でユーザーによるキャンセルが可能
    }
    else if (error.code == VAMPErrorCodeNotLoadedAd) {
    }

    [self resumeSound];
}

/**
 * インセンティブ付与が可能になると通知されます。
 *
 * ※ユーザが途中で再生をスキップしたり、動画視聴をキャンセルすると発生しません。
 * ※アドネットワークによって発生タイミングが異なります。
 *
 * @param rewardedAd `VAMPRewardedAd` オブジェクト
 */
- (void) rewardedAdDidComplete:(VAMPRewardedAd *)rewardedAd {
    [self addLogText:@"didComplete()"
               color:UIColor.systemGreenColor];
}

/**
 * 広告の表示が開始されると通知されます。
 *
 * @param rewardedAd `VAMPRewardedAd` オブジェクト
 */
- (void) rewardedAdDidOpen:(VAMPRewardedAd *)rewardedAd {
    [self addLogText:@"didOpen()"];
}

/**
 * 広告が閉じられると通知されます。
 * ユーザキャンセルなどの場合も通知されるため、インセンティブ付与は `VAMPRewardedAdShowDelegate#rewardedAdDidComplete:` で判定してください。
 *
 * @param rewardedAd `VAMPRewardedAd` オブジェクト
 * @param adClicked 広告がクリックされたかどうか
 */
- (void) rewardedAd:(VAMPRewardedAd *)rewardedAd didCloseWithClickedFlag:(BOOL)adClicked {
    [self addLogText:[NSString stringWithFormat:@"didClose(adClicked:%@)", adClicked ? @"YES" : @"NO"]
               color:UIColor.systemBlueColor];
    [self resumeSound];
}

#pragma mark - private method

- (void) addLogText:(NSString *)message color:(nonnull UIColor *)color {
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

- (void) addLogText:(NSString *)message {
    [self addLogText:message color:UIColor.grayColor];
}

- (void) pauseSound {
    self.isPlayingPrev = self.soundPlayer.isPlaying;

    if (self.soundPlayer.isPlaying) {
        [self.soundPlayer pause];
    }
}

- (void) resumeSound {
    if (self.isPlayingPrev) {
        [self.soundPlayer play];
    }
}

@end
