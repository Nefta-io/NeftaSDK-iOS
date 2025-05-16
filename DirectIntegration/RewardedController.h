//
//  RewardedController.h
//  DirectIntegration
//
//  Created by Tomaz Treven on 1. 10. 24.
//

#import "AdUnitController.h"

#import <NeftaSDK/NeftaSDK-Swift.h>

@interface RewardedController : AdUnitController<NRewardedListener>
@property NRewarded * _Nonnull rewarded;
-(void)Init:(Placement *_Nonnull)placement viewController:(UIViewController * _Nonnull)viewController callback:(id<IAdUnitCallback> _Nonnull)callback;
-(void)OnRewardWithAd:(NAd * _Nonnull)ad;
@end
