//
//  VideoMultiViewController.m
//  RewardSampleForObjC
//
//  Created by AdGeneration on 2017/11/30.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <VAMP/VAMP.h>

#import "VideoMultiViewController.h"

@interface VideoMultiViewController () <VAMPDelegate>

@property (weak, nonatomic) IBOutlet UITextView *adLogView;
@property (weak, nonatomic) IBOutlet UITextField *adCodeField1;
@property (weak, nonatomic) IBOutlet UITextField *adCodeField2;

@property (nonatomic) UIBarButtonItem *soundOffButton;
@property (nonatomic) UIBarButtonItem *soundOnButton;
@property (nonatomic) AVAudioPlayer *soundPlayer;
@property (nonatomic) BOOL isPlayingPrev;

@property (nonatomic) VAMP *vamp1;
@property (nonatomic) VAMP *vamp2;

@end

@implementation VideoMultiViewController

static NSString * const kPlacementId1 = @"59755";   // 広告枠ID1を設定してください
static NSString * const kPlacementId2 = @"*****";   // 広告枠ID2を設定してください

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.adCodeField1.text = kPlacementId1;
    self.adCodeField2.text = kPlacementId2;
    
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
    
    NSURL *soundFileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"invisible" ofType:@"mp3"]];
    NSError *error = nil;
    self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileUrl error:&error];
    [self.soundPlayer prepareToPlay];
    
    if (error) {
        NSLog(@"sound player error:%@", error);
    }
    
    // 広告枠ID1用のVAMPインスタンスを生成
    self.vamp1 = [VAMP new];
    self.vamp1.delegate = self;
    [self.vamp1 setPlacementId:kPlacementId1];
    [self.vamp1 setRootViewController:self];
    
    // 広告枠ID2用のVAMPインスタンスを生成
    self.vamp2 = [VAMP new];
    self.vamp2.delegate = self;
    [self.vamp2 setPlacementId:kPlacementId2];
    [self.vamp2 setRootViewController:self];
    
    [self addLogText:[NSString stringWithFormat:@"isTestMode:%@", [VAMP isTestMode] ? @"YES" : @"NO"]];
    [self addLogText:[NSString stringWithFormat:@"isDebugMode:%@", [VAMP isDebugMode] ? @"YES" : @"NO"]];
}

- (void)soundOff {
    self.navigationItem.rightBarButtonItem = self.soundOnButton;
    [self.soundPlayer pause];
}

- (void)soundOn {
    self.navigationItem.rightBarButtonItem = self.soundOffButton;
    [self.soundPlayer play];
}

- (IBAction)clickLoadAd1:(id)sender {
    [self addLogText:@"click load ad1"];
    
    // 広告1の読み込みを開始
    [self.vamp1 load];
}

- (IBAction)clickShowAd1:(id)sender {
    [self addLogText:@"click show ad1"];
    
    // 広告の準備ができているか確認してから表示
    if (self.vamp1.isReady) {
        [self addLogText:@"show ad1"];
        [self pauseSound];
        
        // 広告1を表示
        [self.vamp1 show];
    }
}

- (IBAction)clickLoadAd2:(id)sender {
    [self addLogText:@"click load ad2"];
    
    // 広告2の読み込みを開始
    [self.vamp2 load];
}

- (IBAction)clickShowAd2:(id)sender {
    [self addLogText:@"click show ad2"];
    
    // 広告の準備ができているか確認してから表示
    if (self.vamp2.isReady) {
        [self addLogText:@"show ad2"];
        [self pauseSound];
        
        // 広告2を再生します
        [self.vamp2 show];
    }
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

// 広告表示が可能になると通知
- (void)vampDidReceive:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidReceive(%@, %@)", adnwName, placementId]];
}

// 全アドネットワークにおいて広告が取得できなかったときに通知
- (void)vamp:(VAMP *)vamp didFailToLoadWithError:(VAMPError *)error withPlacementId:(NSString *)placementId {
    [self addLogText:[NSString stringWithFormat:@"vampDidFailToLoad(%@, %@)", error.localizedDescription, placementId]];
}

// 広告の表示に失敗したときに通知
- (void)vamp:(VAMP *)vamp didFailToShowWithError:(VAMPError *)error withPlacementId:(NSString *)placementId {
    [self addLogText:[NSString stringWithFormat:@"vampDidFailToShow(%@, %@)",
                      error.localizedDescription, placementId]];
    [self resumeSound];
}

// インセンティブ付与可能になったタイミングで通知
- (void)vampDidComplete:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidComplete(%@, %@)", adnwName, placementId]];
}

// 広告が閉じられた時に通知
- (void)vampDidClose:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampDidClose(%@, %@)", adnwName, placementId]];
    [self resumeSound];
}

// 広告準備完了から55分経つと取得した広告の表示はできてもRTBの収益は発生しない
// この通知を受け取ったら、もう一度loadからやり直す必要あり
- (void)vampDidExpired:(NSString *)placementId {
    [self addLogText:[NSString stringWithFormat:@"vampDidExpired(%@)", placementId]];
}

// アドネットワークの広告取得が開始されたときに通知
- (void)vampLoadStart:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"vampLoadStart(%@, %@)", adnwName, placementId]];
}

// アドネットワークの広告取得結果が通知されます。成功時はsuccess=YESとなりロード処理は終了
// success=NOのとき、次位のアドネットワークがある場合はロード処理は継続
- (void)vampLoadResult:(NSString *)placementId success:(BOOL)success adnwName:(NSString *)adnwName message:(NSString *)message {
    if (success) {
        [self addLogText:[NSString stringWithFormat:@"vampLoadResult(%@, %@, success:OK)", adnwName, placementId]];
    }
    else {
        [self addLogText:[NSString stringWithFormat:@"vampLoadResult(%@, %@, success:NG, %@)", adnwName, placementId, message]];
    }
}

// VAMPの状態が変化したときの通知
- (void)vampDidChangeState:(VAMPState)oldState intoState:(VAMPState)newState
           withPlacementId:(NSString *)placementId {
    
//    NSString *oldStateStr = [self vampStateString:oldState];
//    NSString *newStateStr = [self vampStateString:newState];
//
//    [self addLogText:[NSString stringWithFormat:@"vampDidChangeState(%@ -> %@, %@)",
//                      oldStateStr, newStateStr, placementId]];
}

@end
