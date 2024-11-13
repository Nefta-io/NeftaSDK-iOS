//
//  InterstitialController.m
//  DirectIntegration
//
//  Created by Tomaz Treven on 1. 10. 24.
//

#import "InterstitialController.h"

@implementation InterstitialController

-(void)Init:(Placement *_Nonnull)placement callback:(id<IAdUnitCallback> _Nonnull)callback {
    _interstitial = [[NInterstitial alloc] initWithId: placement._id];
    _interstitial._listener = self;
    
    super.ad = _interstitial;
    [super Init: placement callback: callback];
}

- (void)OnCloseWithAd:(NAd * _Nonnull)ad {
    _interstitial = nil;
    [super OnCloseWithAd: ad];
}

@end
