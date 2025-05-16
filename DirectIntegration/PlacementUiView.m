//
//  PlacementUiViewController.m
//  TestbedIOS
//
//  Created by Tomaz Treven on 18/09/2023.
//

#import <Foundation/Foundation.h>
#import "PlacementUiView.h"
#import "BannerController.h"
#import "InterstitialController.h"
#import "RewardedController.h"

#import "ViewController.h"

@implementation PlacementUiView

-(void)Init:(Placement *) placement viewController:(UIViewController * _Nonnull)viewController {
    _placement = placement;
    _viewController = viewController;
    _adUnits = [[NSMutableArray alloc] init];

    NSString *name;
    if (placement._type == TypesBanner) {
        name = [NSString stringWithFormat:@"Banner(%@)", placement._id];
    } else if (placement._type == TypesInterstitial) {
        name = [NSString stringWithFormat:@"Interstitial(%@)", placement._id];
    } else {
        name = [NSString stringWithFormat:@"Rewarded(%@)", placement._id];
    }
    [_nameLabel setText: name];
    
    [_createButton addTarget:self action:@selector(OnCreateClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(int)Reposition:(CGRect) rect {
    rect.size.height = 40 + [_adUnits count] * 130;
    self.frame = rect;
    _adUnitContainer.frame = CGRectMake(0, 35, 360, [_adUnits count] * 130);
    for (int i = 0; i < [_adUnits count]; i++) {
        ((UIView *)_adUnits[i]).frame = CGRectMake(0, i * 100, 360, 130);
    }
    return rect.size.height;
}

- (IBAction)OnCreateClick:(id)sender {
    AdUnitController *adUnit = nil;
    if (_placement._type == TypesBanner) {
        adUnit = [[NSBundle mainBundle] loadNibNamed:@"BannerController" owner:nil options:nil][0];
        [adUnit Init: _placement viewController: _viewController callback: self];
    } else if (_placement._type == TypesInterstitial) {
        adUnit = [[NSBundle mainBundle] loadNibNamed:@"InterstitialController" owner:nil options:nil][0];
        [adUnit Init: _placement viewController: _viewController callback: self];
    } else {
        adUnit = [[NSBundle mainBundle] loadNibNamed:@"RewardedController" owner:nil options:nil][0];
        [adUnit Init: _placement viewController: _viewController callback: self];
    }
    
    [_adUnits addObject: adUnit];
    [_adUnitContainer addSubview: adUnit];

    [ViewController Reposition];
}

-(void)OnAdUnitClose:(AdUnitController * _Nonnull)adUnit {
    for (int i = 0; i < [_adUnits count]; i++) {
        if (_adUnits[i] == adUnit) {
            [_adUnits removeObjectAtIndex: i];
            break;
        }
    }
    [adUnit removeFromSuperview];
    
    [ViewController Reposition];
}
@end
