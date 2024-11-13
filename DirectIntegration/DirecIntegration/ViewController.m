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

@implementation ViewController

static UIView *BannerPlaceholder = nil;
static NSMutableArray* controllers;
static UIScrollView* placementsScroll;

-(void)viewDidAppear:(BOOL)animated {
    if (controllers != nil) {
        return;
    }
    
    BannerPlaceholder = _bannerPlaceholder;
    controllers = [[NSMutableArray alloc] init];
    placementsScroll = _placementsScroll;
    
    _appId = @"5742528628260864";
    
    [_appIdLabel setText: [NSString stringWithFormat: @"AppId: %@", _appId]];
    
    [NeftaPlugin EnableLogging: true];
    _plugin = [NeftaPlugin InitWithAppId: _appId];
    
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    if ([arguments count] > 1) {
        NSString *overrideUrl = arguments[1];
        if (overrideUrl != nil && overrideUrl.length > 2) {
            [_plugin SetOverrideWithUrl: overrideUrl];
        }
    }
    
    if (@available(iOS 14.0, *)) {
        [SKAdNetwork updatePostbackConversionValue: 10 coarseValue: (SKAdNetworkCoarseConversionValue) @"abc" lockWindow: true completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Failed to set postback conversion value: %@", error.localizedDescription);
            } else {
                NSLog(@"Successfully set postback conversion value to %ld", (long)10);
            }
        }];
    }
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    _plugin.OnReady = ^(NSDictionary<NSString *, Placement *> * placements) {
        [weakSelf->_nuidLabel setText: [weakSelf->_plugin GetNuidWithPresent: false]];
        
        for (NSString* placementId in placements) {
            PlacementUiView *controller = [[NSBundle mainBundle] loadNibNamed:@"PlacementUiView" owner:nil options:nil][0];
            [controller Init: placements[placementId]];

            [weakSelf->_placementContainer addSubview: controller];
            [controllers addObject: controller];
        }
        [ViewController Reposition];
    };
    
    [_plugin PrepareRendererWithViewController: self];
    [_plugin EnableAds: true];
    
    if ([arguments count] > 3) {
        NSString *dmIp = arguments[2];
        NSString *serial = arguments[3];
        DebugServer *debugServer = [[DebugServer alloc] initWithIp: dmIp serial: serial];
        NeftaPlugin.OnLog = ^(NSString *log) {
            [debugServer sendWithMessage: [NSString stringWithFormat:@"log %@", log]];
        };
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
