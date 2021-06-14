//
//  ARViewController.m
//  VAMPObjCSample
//
//  Created by Supership Inc. on 2021/05/14.
//  Copyright © 2021年 Supership Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

// VAMP SDKのインポート
#import <VAMP/VAMP.h>

#import "ARViewController.h"

@interface ARViewController () <VAMPARAdDelegate>

@property (weak, nonatomic) IBOutlet UILabel *placementLabel;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (nonatomic) UIBarButtonItem *soundOffButton;
@property (nonatomic) UIBarButtonItem *soundOnButton;
@property (nonatomic) AVAudioPlayer *soundPlayer;
@property (nonatomic) BOOL isPlayingPrev;
// VAMPARAdオブジェクト
@property (nonatomic) VAMPARAd *arAd;
@end

@implementation ARViewController

// 広告枠IDを設定してください
//   59755 : iOSテスト用ID (このIDのままリリースしないでください)
static NSString *const kPlacementId1 = @"59755";

+ (instancetype)instantiateViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ARViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AR"];
    return viewController;;
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
    
    self.title = @"AR";
    
    self.placementLabel.text = [NSString stringWithFormat:@"Placement ID: %@", kPlacementId1];

    NSURL *soundUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"invisible" ofType:@"mp3"]];
    self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [self.soundPlayer prepareToPlay];

    [self addLogText:[NSString stringWithFormat:@"TestMode:%@ DebugMode:%@",
                                                VAMP.isTestMode ? @"YES" : @"NO",
                                                VAMP.isDebugMode ? @"YES" : @"NO"]];
    NSLog(@"[VAMP]isTestMode:%@", VAMP.isTestMode ? @"YES" : @"NO");
    NSLog(@"[VAMP]isDebugMode:%@", VAMP.isDebugMode ? @"YES" : @"NO");

    // VAMPARAdインスタンスを生成し初期化
    self.arAd = [[VAMPARAd alloc] initWithPlacementID:kPlacementId1];
    self.arAd.delegate = self;
}

#pragma mark - IBAction

- (IBAction)loadButtonPressed:(id)sender {
    [self addLogText:@"[load]"];
    
    // 広告の読み込みを開始
    VAMPRequest *request = VAMPRequest.request;
    [self.arAd loadRequest:request];
}

- (IBAction)showButtonPressed:(id)sender {
    // 広告の準備ができているか確認してから表示
    if (self.arAd.isReady) {
        [self addLogText:@"[show]"];
        [self pauseSound];
        
        // 広告の表示
        [self.arAd showFromViewController:self];
    }
    else {
        NSLog(@"[VAMP]not ready");
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

#pragma mark - VAMPARAdDelegate
// 広告の読み込み完了
- (void)arAd:(VAMPARAd *)arAd didLoadWithError:(VAMPError *)error {
    [self addLogText:[NSString stringWithFormat:@"arAd:didLoadWithError(%@)", error.description]
               color:error ? UIColor.redColor : UIColor.blackColor];
}

// 広告表示失敗
- (void)arAd:(VAMPARAd *)arAd didFailToShowWithError:(VAMPError *)error {
    [self addLogText:[NSString stringWithFormat:@"arAd:didFailToShowWithError(%@)", error.description]
               color:UIColor.redColor];
    [self resumeSound];
}

// 広告の表示終了
- (void)arAd:(VAMPARAd *)arAd didCloseWithClickedFlag:(BOOL)clickedFlag {
    [self addLogText:[NSString stringWithFormat:@"arAd:didCloseWithClickedFlag(Click:%@)", clickedFlag ? @"YES" : @"NO"]
               color:UIColor.blackColor];
    [self resumeSound];
}

// ユーザによってカメラアクセスが拒否された時に通知されます。
- (void)arAdCameraAccessNotAuthorized:(VAMPARAd *)arAd {
    [self addLogText:@"arAdCameraAccessNotAuthorized"];
}

// 広告の有効期限切れ
- (void)arAdDidExpire:(VAMPARAd *)arAd {
    [self addLogText:@"arAdDidExpire()"
               color:UIColor.redColor];
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
