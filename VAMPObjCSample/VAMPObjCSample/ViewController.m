//
//  ViewController.m
//  VAMPObjCSample
//
//  Created by Supership Inc. on 2019/04/15.
//  Copyright © 2019年 Supership Inc. All rights reserved.
//

#import <AppTrackingTransparency/AppTrackingTransparency.h>

// VAMP SDKのインポート
#import <VAMP/VAMP.h>

#import "ViewController.h"

#import "Ad1ViewController.h"
#import "Ad2ViewController.h"
#import "InfoViewController.h"

#import "SwitchCell.h"
#import "TextFieldCell.h"

typedef NS_ENUM(NSInteger, MenuType) {
    kMenuTypeAd1PlacementId = 0,
    kMenuTypeAd2PlacementId,
    kMenuTypeTestMode,
    kMenuTypeDebugMode,
    kMenuTypeAd1,
    kMenuTypeAd2,
    kMenuTypeInfo
};

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, TextFieldCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *sdkVersionLabel;
@property (nonatomic, copy) NSArray<NSString *> *menuItems;
@property (nonatomic, copy) NSString *ad1PlacementId;
@property (nonatomic, copy) NSString *ad2PlacementId;

@end

@implementation ViewController

// 広告枠IDを設定してください
// 59755 : iOSテスト用ID (このIDのままリリースしないでください)
static NSString *const kPlacementId = @"59755";

- (void) awakeFromNib {
    [super awakeFromNib];

    self.menuItems = @[
        @(kMenuTypeAd1PlacementId),
        @(kMenuTypeAd2PlacementId),
        @(kMenuTypeTestMode),
        @(kMenuTypeDebugMode),
        @(kMenuTypeAd1),
        @(kMenuTypeAd2),
        @(kMenuTypeInfo)
    ];
}

- (void) viewDidLoad {
    [super viewDidLoad];

    [VAMPDebugUtils logSDKDetails];

    self.title = @"VAMP ObjC Sample";

    self.ad1PlacementId = kPlacementId;
    self.ad2PlacementId = kPlacementId;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextFieldCell" bundle:nil] forCellReuseIdentifier:@"TextFieldCell"];
    self.tableView.rowHeight = 50;

    // VAMP SDKバージョン
    self.sdkVersionLabel.text = [NSString stringWithFormat:@"VAMP SDK %@", VAMPSDKVersion];

    // テストモード
    // 連携アドネットワーク（AdMob、AppLovin、maio、UnityAds）
    // リリースする際は必ずコメントアウトしてください。収益が発生しない広告が配信されます
    [VAMP setTestMode:YES];

    // デバッグモード
    // 連携アドネットワーク（AppLovin、UnityAds）
    [VAMP setDebugMode:YES];

    // 国コードの取得サンプル
    __weak typeof(self) weakSelf = self;
    [VAMP getLocationWithCompletionHandler:^(VAMPLocation *_Nonnull location) {
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

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {

             NSString *str = @"unknown";
             if (status == ATTrackingManagerAuthorizationStatusDenied) {
                 str = @"ATTrackingManagerAuthorizationStatusDenied";
             }
             else if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                 str = @"ATTrackingManagerAuthorizationStatusAuthorized";
             }
             else if (status == ATTrackingManagerAuthorizationStatusRestricted) {
                 str = @"ATTrackingManagerAuthorizationStatusRestricted";
             }
             else if (status == ATTrackingManagerAuthorizationStatusNotDetermined) {
                 str = @"ATTrackingManagerAuthorizationStatusNotDetermined";
             }

             NSLog(@"ATT status:%@", str);
         }];
    }
}

- (NSString *) stringFromMenuType:(NSInteger)index {
    switch (index) {
        case kMenuTypeAd1PlacementId:
            return @"AD1";
        case kMenuTypeAd2PlacementId:
            return @"AD2";
        case kMenuTypeTestMode:
            return @"TEST MODE";
        case kMenuTypeDebugMode:
            return @"DEBUG MODE";
        case kMenuTypeAd1:
            return @"AD1";
        case kMenuTypeAd2:
            return @"AD2";
        case kMenuTypeInfo:
            return @"Info";
        default:
            return @"Unknown";
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuType menu = self.menuItems[indexPath.row].integerValue;
    NSString *labelText = [self stringFromMenuType:menu];

    if (menu == kMenuTypeAd1PlacementId || menu == kMenuTypeAd2PlacementId) {
        TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell" forIndexPath:indexPath];
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        cell.tag = menu;
        cell.delegate = self;
        cell.label.text = labelText;

        if (menu == kMenuTypeAd1PlacementId) {
            cell.textField.text = self.ad1PlacementId;
        }
        else if (menu == kMenuTypeAd2PlacementId) {
            cell.textField.text = self.ad2PlacementId;
        }
        return cell;
    }
    else if (menu == kMenuTypeDebugMode || menu == kMenuTypeTestMode) {
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
        cell.label.text = labelText;
        cell.tag = menu;
        cell.delegate = self;

        if (menu == kMenuTypeDebugMode) {
            cell.uiSwitch.on = VAMP.isDebugMode;
        }
        else if (menu == kMenuTypeTestMode) {
            cell.uiSwitch.on = VAMP.isTestMode;
        }
        return cell;;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = labelText;
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    switch (indexPath.row) {
        case kMenuTypeAd1: {
            UIViewController *viewController = [Ad1ViewController instantiateViewControllerWithPlacementId:self.ad1PlacementId];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case kMenuTypeAd2: {
            UIViewController *viewController = [Ad2ViewController instantiateViewControllerWithPlacementId:self.ad2PlacementId];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case kMenuTypeInfo: {
            UIViewController *viewController = [InfoViewController instantiateViewController];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void) switchCell:(SwitchCell *)switchCell didValueChange:(BOOL)value {
    switch (switchCell.tag) {
        case kMenuTypeDebugMode:
            [VAMP setDebugMode:value];
            break;
        case kMenuTypeTestMode:
            [VAMP setTestMode:value];
            break;
        default:
            break;
    }
}

- (void) textFieldCell:(TextFieldCell *)textFieldCell didChangeText:(NSString *)text {
    switch (textFieldCell.tag) {
        case kMenuTypeAd1PlacementId:
            self.ad1PlacementId = text;
            break;
        case kMenuTypeAd2PlacementId:
            self.ad2PlacementId = text;
            break;
        default:
            break;
    }
}
@end
