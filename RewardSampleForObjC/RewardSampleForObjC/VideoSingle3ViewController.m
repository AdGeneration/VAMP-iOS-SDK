//
//  VideoSingleViewController.m
//  RewardSampleForObjC
//
//  Created by AdGeneration on 2018/07/05.
//  Copyright © 2018年 Supership Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <VAMP/VAMP.h>

#import "VideoSingle3ViewController.h"

@interface VideoSingle3ViewController () <VAMPDelegate>

@property (nonatomic, weak) IBOutlet UITextField *adcodeField;
@property (nonatomic, weak) IBOutlet UITextView *adLogView;

@property (nonatomic) UIBarButtonItem *soundOffButton;
@property (nonatomic) UIBarButtonItem *soundOnButton;
@property (nonatomic) AVAudioPlayer *soundPlayer;
@property (nonatomic) BOOL isPlayingPrev;
@property (nonatomic, readonly) NSString *placementId;

@property (nonatomic) VAMP *vamp;

@end

@implementation VideoSingle3ViewController

/**
 広告枠IDを設定してください
 59755 : iOSテスト用ID (このIDのままリリースしないでください)
 */
static NSString * const kPlacementId = @"59755";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // テストモード確認
    NSLog(@"[VAMP]isTestMode:%@", [VAMP isTestMode] ? @"YES" : @"NO");
    
    // デバッグモード確認
    NSLog(@"[VAMP]isDebugMode:%@", [VAMP isDebugMode] ? @"YES" : @"NO");
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.adcodeField.text = self.placementId;
    
    self.adLogView.text = @"";
    self.adLogView.editable = NO;
    
    UIImage *soundOnImage = [[UIImage imageNamed:@"soundOn"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.soundOffButton = [[UIBarButtonItem alloc] initWithImage:soundOnImage
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(soundOff)];
    
    UIImage *soundOffImage = [[UIImage imageNamed:@"soundOff"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.soundOnButton = [[UIBarButtonItem alloc] initWithImage:soundOffImage
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(soundOn)];
    
    self.navigationItem.rightBarButtonItem = self.soundOnButton;
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"invisible" ofType:@"mp3"];
    NSURL *soundUrl = [NSURL fileURLWithPath:soundPath];
    
    NSError *error = nil;
    self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    [self.soundPlayer prepareToPlay];
    
    if (error) {
        NSLog(@"sound player error:%@", error);
    }
    
    // VAMPインスタンスを生成し初期化
    self.vamp = [VAMP new];
    self.vamp.delegate = self;
    [self.vamp setPlacementId:self.placementId];
    [self.vamp setRootViewController:self];
    
    // フリークエンシーキャップの設定
    [VAMP setFrequencyCap:kPlacementId impressions:3 minutes:60];
}

- (NSString *)placementId {
    return kPlacementId;
}

- (void)soundOff {
    self.navigationItem.rightBarButtonItem = self.soundOnButton;
    [self.soundPlayer pause];
}

- (void)soundOn {
    self.navigationItem.rightBarButtonItem = self.soundOffButton;
    [self.soundPlayer play];
}

- (IBAction)loadAd:(id)sender {
    [self addLogText:@"[load]"];
    
    // 広告取得
    [self.vamp load];
}

- (IBAction)showAd:(id)sender {
    // 広告の準備ができているか確認してから表示
    if (self.vamp.isReady) {
        [self addLogText:@"[show]"];
        [self pauseSound];
        
        // 広告表示
        [self.vamp show];
    } else {
        NSLog(@"[VAMP]not ready");
    }
}

- (IBAction)setFrequencyCap:(id)sender {
    // フリークエンシーキャップの設定
    [VAMP setFrequencyCap:kPlacementId impressions:1 minutes:1];
    [self addLogText:@"click setFrequencyCap button."];
}

- (IBAction)getFrequencyCappedStatus:(id)sender {
    VAMPFrequencyCappedStatus *status = [VAMP getFrequencyCappedStatus:kPlacementId];
    [self addLogText:[NSString stringWithFormat:@"capped:%d, impressions:%lu, remaingTime:%lu, impressionLimit:%lu, timeLimit:%lu", status.isCapped, (unsigned long)status.impressions, (unsigned long)status.remainingTime, (unsigned long)status.impressionLimit, (unsigned long)status.timeLimit]];
}

- (IBAction)clearFrequencyCap:(id)sender {
    [VAMP clearFrequencyCap:kPlacementId];
    [self addLogText:@"click clearFrequencyCap button."];
}

- (IBAction)resetFrequencyCap:(id)sender {
    [VAMP resetFrequencyCap:kPlacementId];
    [self addLogText:@"click resetFrequencyCap button."];
}

- (void)addLogText:(NSString *)message color:(nonnull UIColor *)color {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale systemLocale];
    dateFormatter.dateFormat = @"MM-dd HH:mm:ss ";
    
    NSAttributedString *attributedNow = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", [dateFormatter stringFromDate:now]] attributes:@{NSForegroundColorAttributeName : UIColor.grayColor}];
    
    NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", message] attributes:@{NSForegroundColorAttributeName : color}];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
        [mutableAttributedString appendAttributedString:attributedNow];
        [mutableAttributedString appendAttributedString:attributedMessage];
        
        [mutableAttributedString appendAttributedString:self.adLogView.attributedText];
        self.adLogView.attributedText = mutableAttributedString;
    });
    
    NSLog(@"[VAMP]%@", message);
}

- (void)addLogText:(NSString *)message {
    [self addLogText:message color:UIColor.grayColor];
}

- (NSString *)vampStateString:(VAMPState)state {
    switch (state) {
        case kVAMPStateIdle:
            return @"Idle";
        case kVAMPStateLoading:
            return @"Loading";
        case kVAMPStateLoaded:
            return @"Loaded";
        case kVAMPStateShowing:
            return @"Showing";
        default:
            return @"Unknown";
    }
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

#pragma mark - VAMPDelegate

// 広告取得完了
// Deprecated 廃止予定
// 広告表示が可能になると通知されます
- (void)vampDidReceive:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidReceive(%@, %@)", adnwName, placementId]];
}

// 広告取得失敗
// 広告が取得できなかったときに通知されます。
// 例）在庫が無い、タイムアウトなど
// @see https://github.com/AdGeneration/VAMP-iOS-SDK/wiki/VAMP-iOS-API-Errors
- (void)vamp:(VAMP *)vamp didFailToLoadWithError:(VAMPError *)error withPlacementId:(NSString *)placementId {
    [self addLogText:[NSString stringWithFormat:@"vampDidFailToLoad(%@, %@)", error.localizedDescription, placementId]
               color:UIColor.redColor];
    
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

// 広告表示失敗
- (void)vamp:(VAMP *)vamp didFailToShowWithError:(VAMPError *)error withPlacementId:(NSString *)placementId {
    [self addLogText:[NSString stringWithFormat:@"vampDidFailToShow(%@, %@)",
                      error.localizedDescription, placementId]
               color:UIColor.redColor];
    if (error.code == VAMPErrorCodeUserCancel) {
        // ユーザが広告再生を途中でキャンセルしました。
        // AdMobは動画再生の途中でユーザーによるキャンセルが可能
        NSLog(@"[VAMP]vampDidFailToShow(VAMPErrorCodeUserCancel, %@)", error.localizedDescription);
    }
    
    [self resumeSound];
}

// インセンティブ付与OK
// インセンティブ付与が可能になったタイミングで通知
// アドネットワークによって通知タイミングが異なる（動画再生完了時、またはエンドカードを閉じたタイミング）
- (void)vampDidComplete:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidComplete(%@, %@)", adnwName, placementId]
               color:UIColor.blueColor];
}

// 広告閉じる
// エンドカード閉じる、途中で広告再生キャンセル
- (void)vampDidClose:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidClose(%@, %@)", adnwName, placementId]
               color:UIColor.blackColor];
    [self resumeSound];
}

// 広告準備完了から55分経つと取得した広告の表示はできてもRTBの収益は発生しない
// この通知を受け取ったら、もう一度loadからやり直す必要あり
- (void)vampDidExpired:(NSString *)placementId {
    [self addLogText:[NSString stringWithFormat:@"vampDidExpired(%@)", placementId]
               color:UIColor.redColor];
}

// アドネットワークの広告取得が開始されたときに通知
- (void)vampLoadStart:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampLoadStart(%@, %@)", adnwName, placementId]];
}

// アドネットワークの広告取得結果が通知されます。成功時はsuccess=YESとなりロード処理は終了
// success=NOのとき、次位のアドネットワークがある場合はロード処理は継続
- (void)vampLoadResult:(NSString *)placementId success:(BOOL)success adnwName:(NSString *)adnwName message:(NSString *)message {
    if (success) {
        [self addLogText:[NSString stringWithFormat:@"vampLoadResult(%@, %@, success:OK)", adnwName, placementId]
                   color:UIColor.blackColor];
    }
    else {
        [self addLogText:[NSString stringWithFormat:@"vampLoadResult(%@, %@, success:NG, %@)", adnwName, placementId, message]
                   color:UIColor.redColor];
    }
}

// VAMPの状態が変化したときの通知されます
- (void)vampDidChangeState:(VAMPState)oldState intoState:(VAMPState)newState
           withPlacementId:(NSString *)placementId {
    
    //    NSString *oldStateStr = [self vampStateString:oldState];
    //    NSString *newStateStr = [self vampStateString:newState];
    //
    //    [self addLogText:[NSString stringWithFormat:@"vampDidChangeState(%@ -> %@, %@)",
    //                      oldStateStr, newStateStr, placementId]];
}

@end
