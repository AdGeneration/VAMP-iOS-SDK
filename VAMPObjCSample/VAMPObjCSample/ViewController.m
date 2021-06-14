//
//  ViewController.m
//  VAMPObjCSample
//
//  Created by Supership Inc. on 2019/04/15.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

// VAMP SDKのインポート
#import <VAMP/VAMP.h>

#import "ViewController.h"

#import "Ad1ViewController.h"
#import "Ad2ViewController.h"
#import "ARViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *sdkVersionLabel;
@property (nonatomic, copy) NSArray<NSString *> *samples;

@end

@implementation ViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.samples = @[
        @"Ad1",
        @"Ad2",
        @"AR"
    ];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"VAMP ObjC Sample";

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    // VAMP SDKバージョン
    self.sdkVersionLabel.text = [NSString stringWithFormat:@"VAMP SDK %@", VAMPSDKVersion];

    // テストモード
    // 連携アドネットワーク（AdMob、AppLovin、FAN、maio、nend、UnityAds）
    // リリースする際は必ずコメントアウトしてください。収益が発生しない広告が配信されます
    [VAMP setTestMode:YES];

    // デバッグモード
    // 連携アドネットワーク（AppLovin、UnityAds、FAN、nend、Tapjoy）
    [VAMP setDebugMode:YES];

    // ユーザ属性の設定
    // 誕生日
    NSDateComponents *components = [NSDateComponents new];
    components.year = 1980;
    components.month = 2;
    components.day = 20;
    NSDate *birthday = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]
                                     dateFromComponents:components];
    [VAMPUserFeature setBirthday:birthday];
    // 性別
    [VAMPUserFeature setGender:kVAMPGenderMale];

    // 国コードの取得サンプル
    __weak typeof(self) weakSelf = self;
    [VAMP getLocationWithCompletionHandler:^(VAMPLocation * _Nonnull location) {
        weakSelf.sdkVersionLabel.text = [NSString stringWithFormat:@"%@ / %@-%@",
                                                                   weakSelf.sdkVersionLabel.text,
                                                                   location.countryCode,
                                                                   location.region];

        if ([location.countryCode isEqualToString:@"US"]) {
            // COPPA対象ユーザである場合はYESを設定する
            [VAMPPrivacySettings setChildDirected:kVAMPChildDirectedTrue];
        }
    }];

    // EU圏内ならばユーザに同意を求めるサンプル
//    [VAMP isEUAccessWithCompletionHandler:^(BOOL access) {
//        if (!access) {
//            // Nothing to do
//            return;
//        }
//
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Personalized Ads"
//                                                                       message:@"Accept?"
//                                                                preferredStyle:UIAlertControllerStyleAlert];
//
//        [alert addAction:[UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [VAMPPrivacySettings setConsentStatus:kVAMPConsentStatusAccepted];
//        }]];
//
//        [alert addAction:[UIAlertAction actionWithTitle:@"Deny" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
//            [VAMPPrivacySettings setConsentStatus:kVAMPConsentStatusDenied];
//        }]];
//
//        [self presentViewController:alert animated:YES completion:nil];
//    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.samples.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.samples[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    switch (indexPath.row) {
        case 0: {
            UIViewController *viewController = [Ad1ViewController instantiateViewController];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 1: {
            UIViewController *viewController = [Ad2ViewController instantiateViewController];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 2: {
            UIViewController *viewController = [ARViewController instantiateViewController];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        default:
            break;
    }
}

@end
