//
//  ViewController.m
//  TestbedIOS
//
//  Created by Tomaz Treven on 13/09/2023.
//

#import "ViewController.h"
#import "PlacementUiView.h"

#import "DirectIntegration-Swift.h"

#import <StoreKit/StoreKit.h>
#import <AdSupport/ASIdentifierManager.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@implementation ViewController

static UIView *BannerPlaceholder = nil;
static NSMutableArray *controllers;
static UIScrollView *placementsScroll;
static DebugServer *debugServer;

-(void)viewDidAppear:(BOOL)animated {
    if (controllers != nil) {
        return;
    }
    
    BannerPlaceholder = _bannerPlaceholder;
    controllers = [[NSMutableArray alloc] init];
    placementsScroll = _placementsScroll;
    
    _appId = @"5661184053215232";
    
    [_appIdLabel setText: [NSString stringWithFormat: @"AppId: %@", _appId]];
    
    [NeftaPlugin EnableLogging: true];
    debugServer = [[DebugServer alloc] initWithViewController: self];
    
    _plugin = [NeftaPlugin InitWithAppId: _appId];
    [_plugin SetContentRatingWithRating: NeftaPlugin.ContentRating_ParentalGuidance];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    _plugin.OnReady = ^(NSDictionary<NSString *, Placement *> * placements) {
        [weakSelf->_nuidLabel setText: [weakSelf->_plugin GetNuidWithPresent: false]];
        
        for (NSString* placementId in placements) {
            PlacementUiView *controller = [[NSBundle mainBundle] loadNibNamed:@"PlacementUiView" owner:nil options:nil][0];
            [controller Init: placements[placementId] viewController: weakSelf];

            [weakSelf->_placementContainer addSubview: controller];
            [controllers addObject: controller];
        }
        [ViewController Reposition];
    };
    
    [NeftaPlugin._instance GetInsights: Insights.Churn | Insights.Banner | Insights.Interstitial | Insights.Rewarded callback: ^(Insights * insights) {
        NSLog(@"On GetInsights");
        if (insights._churn != nil) {
            NSLog(@"D1 churn %f", insights._churn._d1_probability);
        }
        if (insights._interstitial != nil) {
            NSLog(@"Recommended interstitial %@: %f", insights._interstitial._adUnit, insights._interstitial._floorPrice);
        }
    } timeout: 5];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (@available(iOS 14.5, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                [self->_plugin SetTrackingWithIsAuthorized: status == ATTrackingManagerAuthorizationStatusAuthorized];
            }];
        } else {
            [self->_plugin SetTrackingWithIsAuthorized: [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]];
        }
    });
    
    if (@available(iOS 14.0, *)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SKAdNetwork updatePostbackConversionValue: 10 coarseValue: (SKAdNetworkCoarseConversionValue) @"high" lockWindow: true completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Failed to set postback conversion value: %@", error.localizedDescription);
                } else {
                    NSLog(@"Successfully set postback conversion value to %ld", (long)10);
                }
            }];
        });
    }
}

+(UIView *)GetBannerPlaceholder {
    return BannerPlaceholder;
}

+(void) Reposition {
    CGRect frame = CGRectMake(0, 0, 360, 0);
    for (int i = 0; i < [controllers count]; i++) {
        frame.origin.y += [controllers[i] Reposition: frame];
    }
    placementsScroll.contentSize = CGSizeMake(360, frame.origin.y);
}

@end
