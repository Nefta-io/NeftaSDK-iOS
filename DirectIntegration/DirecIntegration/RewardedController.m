//
//  RewardedController.m
//  DirectIntegration
//
//  Created by Tomaz Treven on 1. 10. 24.
//

#import "RewardedController.h"

@implementation RewardedController

-(void)Init:(Placement *_Nonnull)placement callback:(id<IAdUnitCallback> _Nonnull)callback {
    _rewarded = [[NRewarded alloc] initWithId: placement._id];
    _rewarded._listener = self;
    
    super.ad = _rewarded;
    [super Init: placement callback: callback];
}

- (void)OnRewardWithAd:(NAd * _Nonnull)ad {
    [self.statusLabel setText: @"OnReward"];
}

- (void)OnCloseWithAd:(NAd * _Nonnull)ad {
    _rewarded = nil;
    [super OnCloseWithAd: ad];
}

- (void)didCompleteRewardedVideoForAdWithAd:(NAd * _Nonnull)ad { 
    
}

- (void)didStartRewardedVideoForAdWithAd:(NAd * _Nonnull)ad { 
    
}

@end
