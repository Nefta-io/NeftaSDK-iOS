//
//  AdUnitController.m
//  DirectIntegration
//
//  Created by Tomaz Treven on 1. 10. 24.
//

#include "AdUnitController.h"

#import <StoreKit/StoreKit.h>

@implementation AdUnitController
-(void)Init:(Placement *)placement viewController:(UIViewController *)viewController callback:(id<IAdUnitCallback>) callback {
    _viewController = viewController;
    _callback = callback;
    
    [_idLabel setText: [NSString stringWithFormat:@"%lu", _ad.hash]];
    [_creativeIdLabel setText: @""];
    
    [_bidButton addTarget:self action:@selector(OnBidClick:) forControlEvents:UIControlEventTouchUpInside];
    [_loadButton addTarget:self action:@selector(OnLoadClick:) forControlEvents:UIControlEventTouchUpInside];
    [_showButton addTarget:self action:@selector(OnShowClick:) forControlEvents:UIControlEventTouchUpInside];
    [_destroyButton addTarget:self action:@selector(OnDestroyClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)OnBidClick:(id)sender {
    NSString *name = @"example event";
    NSInteger randomValue = arc4random_uniform(101);
    if (_ad._placement._type == TypesBanner) {
        NSArray *insightList = @[@"calculated_user_floor_price_banner", @"calculated_user_floor_price_interstitial", @"calculated_user_floor_price_rewarded"];
        [NeftaPlugin._instance GetBehaviourInsight: insightList];
        
        ProgressionStatus progressionStatus = (ProgressionStatus) arc4random_uniform(3);
        ProgressionType progressionType = (ProgressionType) arc4random_uniform(7);
        ProgressionSource progressionSource = (ProgressionSource) arc4random_uniform(7);
        [NeftaPlugin._instance.Events AddProgressionEventWithStatus: progressionStatus type:progressionType source: progressionSource name: name value: randomValue];
    } else if (_ad._placement._type == TypesInterstitial) {
        [NeftaPlugin._instance GetBehaviourInsight: @[@"calculated_user_floor_price_interstitial"] callback: ^(NSDictionary<NSString *, Insight *> * behaviourInsight) {
            NSLog(@"Interstitial insight %f", behaviourInsight[@"calculated_user_floor_price_interstitial"]._float);
        }];
        
        ResourceCategory rCategory = (ResourceCategory) arc4random_uniform(9);
        ReceiveMethod rMethod = (ReceiveMethod) arc4random_uniform(8);
        [NeftaPlugin._instance.Events AddReceiveEventWithCategory: rCategory method: rMethod name: name quantity: randomValue];
    } else {
        [NeftaPlugin._instance GetBehaviourInsight: @[@"calculated_user_floor_price_rewarded"] callback: ^(NSDictionary<NSString *, Insight *> * behaviourInsight) {
            NSLog(@"Rewarded insight %f", behaviourInsight[@"calculated_user_floor_price_rewarded"]._float);
        }];
        
        ResourceCategory rCategory = (ResourceCategory) arc4random_uniform(9);
        SpendMethod rMethod = (SpendMethod) arc4random_uniform(8);
        [NeftaPlugin._instance.Events AddSpendEventWithCategory: rCategory method: rMethod name: name quantity: randomValue];
    }
    [_ad Bid];
}

- (IBAction)OnLoadClick:(id)sender {
    if (@available(iOS 14.0, *)) {
        [SKAdNetwork updatePostbackConversionValue:30 completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Failed to update postback conversion value: %@", error.localizedDescription);
            } else {
                NSLog(@"Successfully updated postback conversion value to %ld", (long)30);
            }
        }];
    }
    
    [_ad Load];
}

- (IBAction)OnShowClick:(id)sender {
    [_ad Show: _viewController];
}

- (IBAction)OnDestroyClick:(id)sender {
    [_ad Close];
}

- (void)OnBidWithAd:(NAd * _Nonnull)ad bidResponse:(BidResponse *)bidResponse error:(NError *)error {
    if (bidResponse == nil) {
        [_statusLabel setText: [NSString stringWithFormat: @"OnBid failed %@", error._message]];
    } else {
        [_creativeIdLabel setText: bidResponse._creativeId];
        [_statusLabel setText: [NSString stringWithFormat: @"OnBid: %@: %f", bidResponse._creativeId, bidResponse._price]];
    }
}
- (void)OnLoadFailWithAd:(NAd * _Nonnull)ad error:(NError * _Nonnull)error {
    [_creativeIdLabel setText: @""];
    [_statusLabel setText: [NSString stringWithFormat: @"OnLoad failed %@", error._message]];
}
- (void)OnLoadWithAd:(NAd * _Nonnull)ad width:(NSInteger)width height:(NSInteger)height {
    [_statusLabel setText: @"OnLoad success"];
}
- (void)OnShowFailWithAd:(NAd * _Nonnull)ad error:(NError * _Nonnull)error {
    [_creativeIdLabel setText: @""];
    [_statusLabel setText: [NSString stringWithFormat: @"OnShowFail %@", error._message]];
}
- (void)OnShowWithAd:(NAd * _Nonnull)ad {
    [_statusLabel setText: @"OnShow"];
}
- (void)OnCloseWithAd:(NAd * _Nonnull)ad {
    _ad = nil;

    [_callback OnAdUnitClose: self];
}
@end
