//
//  BannerController.h
//  DirectIntegration
//
//  Created by Tomaz Treven on 1. 10. 24.
//
#import <UIKit/UIKit.h>
#import "AdUnitController.h"

#import <NeftaSDK/NeftaSDK-Swift.h>

@interface BannerController : AdUnitController<NBannerListener>
@property int flowState;
@property NBanner * _Nonnull banner;
-(void)Init:(Placement *_Nonnull)placement viewController:(UIViewController * _Nonnull)viewController callback:(id<IAdUnitCallback> _Nonnull)callback;
@end
