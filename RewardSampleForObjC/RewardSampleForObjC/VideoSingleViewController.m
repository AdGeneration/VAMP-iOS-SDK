//
//  VideoSingleViewController.m
//  RewardSampleForObjC
//
//  Created by AdGeneration on 2017/02/21.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <VAMP/VAMP.h>

#import "VideoSingleViewController.h"

@interface VideoSingleViewController () <VAMPDelegate>

@property (nonatomic, weak) IBOutlet UITextField *adcodeField;
@property (nonatomic, weak) IBOutlet UITextView *adLogView;

@property (nonatomic) UIBarButtonItem *soundOffButton;
@property (nonatomic) UIBarButtonItem *soundOnButton;
@property (nonatomic) AVAudioPlayer *soundPlayer;
@property (nonatomic) BOOL isPlayingPrev;

@property (nonatomic, readonly) NSString *placementId;
@property (nonatomic) VAMP *vamp;

@end

@implementation VideoSingleViewController

/**
 広告枠IDを設定してください
   59755 : iOSテスト用ID (このIDのままリリースしないでください)
 */
static NSString * const kPlacementId = @"59755";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // テストモードか確認します
    NSLog(@"[VAMP]isTestMode:%@", [VAMP isTestMode] ? @"YES" : @"NO");
    
    // デバッグモードか確認します
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
    
    // VAMPインスタンスを生成し初期化します
    self.vamp = [VAMP new];
    self.vamp.delegate = self;
    [self.vamp setPlacementId:self.placementId];
    [self.vamp setRootViewController:self];
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
    // 広告の読み込みを開始します
    [self.vamp load];
    
    [self addLogText:@"[load]"];
}

- (IBAction)showAd:(id)sender {
    // 広告の準備ができているか確認してから表示してください
    if (self.vamp.isReady) {
        // 広告を再生します
        BOOL success = [self.vamp show];
        
        [self addLogText:@"[show]"];
        
        self.isPlayingPrev = self.soundPlayer.isPlaying;
        
        if (self.soundPlayer.isPlaying && success) {
            [self.soundPlayer pause];
        }
    } else {
        NSLog(@"[VAMP]not ready");
    }
}

- (IBAction)clearLoadedAd:(id)sender {
    // ロード済みの広告を破棄します。このメソッドを実行した後はloadからやり直してください
    [self.vamp clearLoaded];
    
    [self addLogText:@"[clear]"];
}

- (void)addLogText:(NSString *)message {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale systemLocale];
    dateFormatter.dateFormat = @"MM-dd HH:mm:ss ";
    
    NSString *log = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:now], message];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.adLogView.text = [NSString stringWithFormat:@"%@\n%@", log, self.adLogView.text];
    });
    
    NSLog(@"[VAMP]%@", message);
}

- (NSString *)vampStateString:(VAMPState)state {
    switch (state) {
        case kVAMPStateIdle:
            return @"Idle";
        case kVAMPStateLoading:
            return @"Loading";
        case kVAMPStateReady:
            return @"Ready";
        case kVAMPStateLoaded:
            return @"Loaded";
        case kVAMPStateShowing:
            return @"Showing";
        default:
            return @"Unknown";
    }
}

#pragma mark - VAMPDelegate

// load完了して、広告表示できる状態になったことを通知します
- (void)vampDidReceive:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidReceive(%@) placementId:%@",
                      adnwName, placementId]];
}

// エラーが発生した時に通知されます
- (void)vampDidFail:(NSString *)placementId error:(VAMPError *)error {
    NSString *codeString = [error kVAMPErrorString];
    NSString *failMessage = error.localizedDescription;
    
    [self addLogText:[NSString stringWithFormat:@"vampDidFail placementId:%@ %@ %@",
                      placementId, codeString, failMessage]];
}

// インセンティブ付与可能になったタイミングで通知されます
- (void)vampDidComplete:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidComplete(%@) placementId:%@",
                      adnwName, placementId]];
}

// 広告が閉じられた時に呼ばれます
- (void)vampDidClose:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidClose(%@) placementId:%@",
                      adnwName, placementId]];
    
    if (self.isPlayingPrev) {
        [self.soundPlayer play];
    }
}

// アドネットワークごとの広告取得が開始された時に通知されます
- (void)vampLoadStart:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampLoadStart(%@) placementId:%@",
                      adnwName, placementId]];
}

// アドネットワークごとの広告取得結果が通知されます（success,failedどちらも通知）。
// この通知をもとにshowしないようご注意ください。showする判定は、vampDidReceiveを受け取ったタイミングで判断してください
- (void)vampLoadResult:(NSString *)placementId success:(BOOL)success adnwName:(NSString *)adnwName
               message:(NSString *)message {
    
    if (success) {
        [self addLogText:[NSString stringWithFormat:@"vampLoadResult(%@) success:%@ placementId:%@",
                          adnwName, success ? @"YES" : @"NO", placementId]];
    } else {
        [self addLogText:[NSString stringWithFormat:@"vampLoadResult(%@) success:%@ message:%@ placementId:%@",
                          adnwName, success ? @"YES" : @"NO", message, placementId]];
    }
}

// 広告準備完了から55分経つと取得した広告の表示はできてもRTBの収益は発生しません。
// この通知を受け取ったら、もう一度loadからやり直す必要があります
- (void)vampDidExpired:(NSString *)placementId {
    [self addLogText:[NSString stringWithFormat:@"vampDidExpired placementId:%@", placementId]];
}

// VAMPの状態が変化したときの通知されます
- (void)vampDidChangeState:(VAMPState)oldState intoState:(VAMPState)newState
          withPlacementId:(NSString *)placementId {
    
    NSString *oldStateStr = [self vampStateString:oldState];
    NSString *newStateStr = [self vampStateString:newState];
    
    [self addLogText:[NSString stringWithFormat:@"vampDidChangeState %@ -> %@, placementId:%@",
                      oldStateStr, newStateStr, placementId]];
}

@end

