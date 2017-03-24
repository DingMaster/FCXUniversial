//
//  GADInterstitialManager.m
//  Tally
//
//  Created by 冯 传祥 on 2017/3/18.
//  Copyright © 2017年 冯 传祥. All rights reserved.
//

#import "GADInterstitialManager.h"
#import <GoogleMobileAds/GADInterstitial.h>

@interface GADInterstitialManager () <GADInterstitialDelegate>
{
    BOOL _isClose;
}

@property (nonatomic, weak) UIViewController *controller;
@property(nonatomic, strong) GADInterstitial *interstitial;

@end

@implementation GADInterstitialManager

- (void)dealloc {
    _interstitial.delegate = nil;
    self.interstitial = nil;
}

- (instancetype)initWithController:(UIViewController *)controller interstitialID:(NSString *)interstitialID {
    if (self = [super init]) {
        self.controller = controller;
        
        self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:interstitialID];
        self.interstitial.delegate = self;
    }
    return self;
}

- (void)showInterstitial {
    GADRequest *request = [GADRequest request];
    // Requests test ads on simulators.
    request.testDevices = @[ kGADSimulatorID ];
    [self.interstitial loadRequest:request];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIViewController *controller = self.controller.presentedViewController;
        
        if (!controller || ![controller isKindOfClass:NSClassFromString(@"GADInterstitialViewController")]) {
            _interstitial.delegate = nil;
            self.interstitial = nil;
        }
    });
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    if ([self.interstitial isReady]) {
        _isClose = YES;
        [self.interstitial presentFromRootViewController:self.controller];
        
        if (_autoClose) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIViewController *controller = self.controller.presentedViewController;
                if ([controller isKindOfClass:NSClassFromString(@"GADInterstitialViewController")]) {
                    [controller dismissViewControllerAnimated:YES completion:NULL];
                }
            });
        }
    }
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    if (_interstitialEndHandle) {
        _interstitialEndHandle();
    }
}

- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad {
    if (_interstitialEndHandle) {
        _interstitialEndHandle();
    }
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
//    if (_isClose) {
//        if (_closeHandle) {
//            _closeHandle();
//        }
//    } else {
//        if (_interstitialEndHandle) {
//            _interstitialEndHandle();
//        }
//    }
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    if (_isClose) {
        if (_closeHandle) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _closeHandle();
            });
        }
    } else {
        if (_interstitialEndHandle) {
            _interstitialEndHandle();
        }
    }
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    _isClose = NO;
    [self.controller.presentedViewController dismissViewControllerAnimated:NO completion:NULL];
    if (_interstitialEndHandle) {
        _interstitialEndHandle();
    }
}

@end
