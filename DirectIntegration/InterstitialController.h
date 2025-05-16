//
//  InterstitialController.h
//  DirectIntegration
//
//  Created by Tomaz Treven on 1. 10. 24.
//

#import "AdUnitController.h"

#import <NeftaSDK/NeftaSDK-Swift.h>

@interface InterstitialController : AdUnitController<NInterstitialListener>
@property NInterstitial * _Nonnull interstitial;
-(void)Init:(Placement *_Nonnull)placement viewController:(UIViewController * _Nonnull)viewController callback:(id<IAdUnitCallback> _Nonnull)callback;
@end
