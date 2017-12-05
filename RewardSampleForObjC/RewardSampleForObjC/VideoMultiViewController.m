//
//  VideoMultiViewController.m
//  RewardSampleForObjC
//
//  Created by AdGeneration on 2017/11/30.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import <VAMP/VAMP.h>
#import <AVFoundation/AVFoundation.h>

#import "VideoMultiViewController.h"

@interface VideoMultiViewController () <VAMPDelegate>

@property (weak, nonatomic) IBOutlet UITextView *adLogView;
@property (weak, nonatomic) IBOutlet UITextField *adCodeField1;
@property (weak, nonatomic) IBOutlet UITextField *adCodeField2;

@property (nonatomic) UIBarButtonItem *soundOffButton;
@property (nonatomic) UIBarButtonItem *soundOnButton;
@property (nonatomic) AVAudioPlayer *soundPlayer;

@property (nonatomic) VAMP *vamp1;
@property (nonatomic) VAMP *vamp2;

@end

@implementation VideoMultiViewController

static NSString * const kAdId1 = @"*****";  // 広告枠ID1を設定してください
static NSString * const kAdId2 = @"*****";  // 広告枠ID2を設定してください

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.adCodeField1.text = kAdId1;
    self.adCodeField2.text = kAdId2;
    
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
    
    // 広告枠ID1用のVAMPインスタンスを生成します
    self.vamp1 = [[VAMP alloc] init];
    [self.vamp1 setPlacementId:kAdId1];
    [self.vamp1 setDelegate:self];
    [self.vamp1 setRootViewController:self];
    
    // 広告枠ID2用のVAMPインスタンスを生成します
    self.vamp2 = [[VAMP alloc] init];
    [self.vamp2 setPlacementId:kAdId2];
    [self.vamp2 setDelegate:self];
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
    
    // 広告1の読み込みを開始します
    [self.vamp1 load];
}

- (IBAction)clickShowAd1:(id)sender {
    [self addLogText:@"click show ad1"];
    
    // 広告の準備ができているか確認してから表示してください
    if (self.vamp1.isReady) {
        // 広告1を再生します
        [self.vamp1 show];
        
        [self addLogText:@"show ad1"];
        
        if (self.soundPlayer.isPlaying) {
            [self.soundPlayer pause];
        }
    }
}

- (IBAction)clickLoadAd2:(id)sender {
    [self addLogText:@"click load ad2"];
    
    // 広告2の読み込みを開始します
    [self.vamp2 load];
}

- (IBAction)clickShowAd2:(id)sender {
    [self addLogText:@"click show ad2"];
    
    // 広告の準備ができているか確認してから表示してください
    if (self.vamp2.isReady) {
        // 広告2を再生します
        [self.vamp2 show];
        
        [self addLogText:@"show ad2"];
        
        if (self.soundPlayer.isPlaying) {
            [self.soundPlayer pause];
        }
    }
}

- (void)addLogText:(NSString *)message {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale systemLocale];
    dateFormatter.dateFormat = @"MM-dd HH:mm:ss";
    NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
    NSString *log = [NSString stringWithFormat:@"%@ %@", timestamp, message];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.adLogView.text = [NSString stringWithFormat:@"%@\n%@", log, self.adLogView.text];
    });
    
    NSLog(@"[VAMP]%@", log);
}

#pragma mark - VAMPDelegate

// load完了して、広告表示できる状態になったことを通知します
- (void)vampDidReceive:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"[%@] vampDidReceive(%@)", placementId, adnwName]];
}

// エラー
- (void)vampDidFail:(NSString *)placementId error:(VAMPError *)error {
    NSString *codeString = [error kVAMPErrorString];
    NSString *failMessage = error.localizedDescription;
    
    [self addLogText:[NSString stringWithFormat:@"[%@] vampDidFail %@ %@", placementId, codeString, failMessage]];
}

// インセンティブ付与可能になったタイミングで通知されます
- (void)vampDidComplete:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"[%@] vampDidComplete(%@)", placementId, adnwName]];
}

// 広告が閉じられた時に呼ばれます
- (void)vampDidClose:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"[%@] vampDidClose(%@)", placementId, adnwName]];
}

// アドネットワークごとの広告取得が開始されたときに通知されます
- (void)vampLoadStart:(NSString *)placementId adnwName:(NSString *)adnwName {
    [self addLogText:[NSString stringWithFormat:@"[%@] vampLoadStart(%@)", placementId, adnwName]];
}

// アドネットワークごとの広告取得結果を通知する。（success,failedどちらも通知）
// この通知をもとにshowしないようご注意ください。showする判定は、onReceiveを受け取ったタイミングで判断ください。
- (void)vampLoadResult:(NSString *)placementId success:(BOOL)success adnwName:(NSString *)adnwName message:(NSString *)message {
    if ([message length] > 0) {
        if (success) {
            [self addLogText:[NSString stringWithFormat:@"[%@] vampLoadResult(%@ success:%@)",
                              placementId, adnwName, success ? @"YES" : @"NO"]];
        } else {
            [self addLogText:[NSString stringWithFormat:@"[%@] vampLoadResult(%@ success:%@ %@)",
                              placementId, adnwName, success ? @"YES" : @"NO", message]];
        }
    } else {
        [self addLogText:[NSString stringWithFormat:@"[%@] vampLoadResult(%@ success:%@)",
                          placementId, adnwName, success ? @"YES" : @"NO"]];
    }
}

// 広告準備完了から55分経つと取得した広告が表示はできてもRTBの収益は発生しません
// この通知を受け取ったら、もう一度loadからやり直す必要があります。
- (void)vampDidExpired:(NSString *)placementId {
    [self addLogText:[NSString stringWithFormat:@"[%@] vampDidExpired", placementId]];
}

@end

