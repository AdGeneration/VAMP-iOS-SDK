//
//  VideoSingle2ViewController.m
//  RewardSampleForObjC
//
//  Created by AdGeneration on 2017/02/21.
//  Copyright © 2017年 Supership Inc. All rights reserved.
//

#import <VAMP/VAMP.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoSingle2ViewController.h"

@interface VideoSingle2ViewController () <VAMPDelegate>

@property (nonatomic, weak) IBOutlet UITextField* adcodeField;
@property (nonatomic, weak) IBOutlet UITextView* adLogView;
@property (nonatomic, weak) IBOutlet UIButton* adShowButton;
@property (nonatomic, strong) VAMP* adReward;
@property (nonatomic, strong) UIButton *soundOffButton;
@property (nonatomic, strong) UIButton *soundOnButton;
@property (nonatomic, strong) AVAudioPlayer* soundPlayer;

@end

@implementation VideoSingle2ViewController

static NSString * const kPubId = @"*****"; // 広告枠IDを設定してください

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // テストモード
    NSLog(@"isTestMode:%@", [VAMP isTestMode]?@"YES":@"NO");
    
    // デバッグモード
    NSLog(@"isDebugMode:%@", [VAMP isDebugMode]?@"YES":@"NO");
    
    // TextViewを上寄せで表示
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // PUBIDをラベルに表示
    if ([kPubId length] > 0) {
        self.adcodeField.text = kPubId;
    } else {
        self.adcodeField.text = @"pubID無し";
    }
    
    // ログのViewをクリア
    self.adLogView.text = @"";
    self.adLogView.editable = NO;
    
    // ナビゲーションのボタンを設定
    self.soundOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.soundOffButton setBackgroundImage:[UIImage imageNamed:@"soundOn"] forState:UIControlStateNormal];
    self.soundOffButton.frame = CGRectMake(0, 0, 40, 40);
    [self.soundOffButton addTarget:self action:@selector(soundOff) forControlEvents:UIControlEventTouchUpInside];
    
    self.soundOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.soundOnButton setBackgroundImage:[UIImage imageNamed:@"soundOff"] forState:UIControlStateNormal];
    self.soundOnButton.frame = CGRectMake(0, 0, 40, 40);
    [self.soundOnButton addTarget:self action:@selector(soundOn) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:self.soundOnButton];
    self.navigationItem.rightBarButtonItem = barButton;
    
    // 再生する音声を追加
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"invisible" ofType:@"mp3"];
    NSURL *soundUrl = [NSURL fileURLWithPath:soundPath];
    
    NSError *error = nil;
    self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    [self.soundPlayer prepareToPlay];
    
    if (error) {
        NSLog(@"sound player error:%@", error);
    }
    
    self.adReward = [[VAMP alloc] init];
    [self.adReward setPlacementId:kPubId];
    self.adReward.delegate = self;
    [self.adReward setRootViewController:self];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) soundOff
{
    self.navigationItem.rightBarButtonItem.customView = self.soundOnButton;
    [self.soundPlayer pause];
}

-(void) soundOn
{
    self.navigationItem.rightBarButtonItem.customView = self.soundOffButton;
    [self.soundPlayer play];
}

-(IBAction)loadAd:(id)sender
{
    // 広告の呼び出し
    if ((self.adReward) != nil) {
        [self.adReward load];
        [self addLogText: @"[load]\n"];
        NSLog(@"[VAMP]load");
    }
}

-(IBAction)showAd:(id)sender
{
    NSLog(@"[VAMP]showAd isReady:%@",[self.adReward isReady]?@"YES":@"NO");
    
    // 広告の表示
    if ([self.adReward isReady]) {
        BOOL isShow = [self.adReward show];
        [self addLogText: @"[show]\n"];
        NSLog(@"[VAMP]show");
        if (self.soundPlayer.isPlaying && isShow) {
            [self.soundPlayer pause];
        }
    }
}

-(void) addLogText:(NSString *)message {
    // 現在日付を設定
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale systemLocale]; //ここ注意。Locale 設定しないと１２時間表示している場合に、HH指定で午後・午前とでる。
    dateFormatter.dateFormat = @"MM-dd HH:mm:ss ";
    
    NSString *logmessage = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:now], message];
    // MainThread でないとエラーになるので注意
    dispatch_async(dispatch_get_main_queue(), ^{
        self.adLogView.text = [NSString stringWithFormat:@"%@%@", logmessage, self.adLogView.text];
    });
}

// load完了して、広告表示できる状態になったことを通知します
-(void) vampDidReceive:(NSString *)placementId adnwName:(NSString *)adnwName
{
    [self addLogText:[NSString stringWithFormat:@"vampDidReceive(%@)\n", adnwName]];
    NSLog(@"[VAMP]vampDidReceive(%@) placementId:(%@)", adnwName, placementId);
}

// エラー
-(void) vampDidFail:(NSString *)placementId error:(VAMPError *)error
{
    NSString *codeString = [error kVAMPErrorString];
    NSString *failMessage = error.localizedDescription;
    
    [self addLogText:[NSString stringWithFormat:@"vampDidFail(%@)%@ %@\n",placementId ,codeString ,failMessage]];
    NSLog(@"[VAMP]vampDidFail:%@ %@ %@",placementId ,codeString ,failMessage);
}

// インセンティブ付与可能になったタイミングで通知されます
-(void) vampDidComplete:(NSString *)placementId adnwName:(NSString *)adnwName
{
    [self addLogText:[NSString stringWithFormat:@"vampDidComplete(%@)\n", adnwName]];
    NSLog(@"[VAMP]vampDidComplete:(%@) placementId:(%@)", adnwName, placementId);
}

// 広告が閉じられた時に呼ばれます
-(void)vampDidClose:(NSString *)placementId adnwName:(NSString *)adnwName
{
    [self addLogText:[NSString stringWithFormat:@"vampDidClose(%@)\n", adnwName]];
    NSLog(@"[VAMP]vampDidClose:(%@) placementId:(%@)", adnwName, placementId);
}

// アドネットワークごとの広告取得が開始されたときに通知されます
-(void)vampLoadStart:(NSString *)placementId adnwName:(NSString *)adnwName
{
    [self addLogText:[NSString stringWithFormat:@"vampLoadStart(%@)\n", adnwName]];
    NSLog(@"[VAMP]vampLoadStart(%@) placementId:%@", adnwName, placementId);
}

// アドネットワークごとの広告取得結果を通知する。（success,failedどちらも通知）
// この通知をもとにshowしないようご注意ください。showする判定は、onReceiveを受け取ったタイミングで判断ください。
-(void)vampLoadResult:(NSString *)placementId success:(BOOL)success adnwName:(NSString *)adnwName message:(NSString *)message
{
    if ([message length] > 0) {
        if (success) {
            [self addLogText:[NSString stringWithFormat:@"vampLoadResult(%@ success:%@)\n", adnwName, success?@"YES":@"NO"]];
        } else {
            [self addLogText:[NSString stringWithFormat:@"vampLoadResult(%@ success:%@ %@)\n", adnwName, success?@"YES":@"NO", message]];
        }
        NSLog(@"[VAMP]vampLoadResult(%@) placementId:%@ success:%@ %@", adnwName, placementId, success?@"YES":@"NO" ,message);
    } else {
        [self addLogText:[NSString stringWithFormat:@"vampLoadResult(%@ success:%@)\n", adnwName, success?@"YES":@"NO"]];
        NSLog(@"[VAMP]vampLoadResult(%@) placementId:%@ success:%@", adnwName, placementId, success?@"YES":@"NO");
    }
}

// 広告準備完了から55分経つと取得した広告が表示はできてもRTBの収益は発生しません
// この通知を受け取ったら、もう一度loadからやり直す必要があります。
-(void)vampDidExpired:(NSString *)placementId
{
    [self addLogText:[NSString stringWithFormat:@"vampDidExpired(%@)\n", placementId]];
    NSLog(@"[VAMP]vampDidExpired placementId:(%@)", placementId);
}

@end
