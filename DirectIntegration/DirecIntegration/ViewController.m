//
//  ViewController.m
//  TestbedIOS
//
//  Created by Tomaz Treven on 13/09/2023.
//

#import "ViewController.h"
#import "PlacementUiView.h"

@implementation ViewController

-(void)viewDidAppear:(BOOL)animated {
    if (_controllers != nil) {
        return;
    }
    
    _controllers = [[NSMutableDictionary alloc] init];
    
    _appId = @"5661184053215232";
    
    NSString *appIdLabel;
    if (_appId == nil || [_appId length] == 0) {
        appIdLabel = @"Demo mode (appId not set)";
    } else {
        appIdLabel = [NSString stringWithFormat: @"AppId: %@", _appId];
    }
    [_appIdLabel setText: appIdLabel];
    
    [NeftaPlugin EnableLogging: true];
    _plugin = [NeftaPlugin InitWithAppId: _appId];
    
    Boolean isTest = false;
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    if ([arguments count] > 1) {
        NSString *overrideUrl = arguments[1];
        if (overrideUrl != nil && overrideUrl.length > 0) {
            [_plugin SetOverrideWithUrl: overrideUrl];
        }
        if ([arguments count] >= 3 && [arguments[2] isEqualToString: @"test"]) {
            isTest = true;
        }
    }
    
    [_plugin SetCustomParameterWithId: @"5679149674921984" key: @"bidfloor" value: @0.3];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    _plugin.OnReady = ^(NSDictionary<NSString *, Placement *> * placements) {
        [weakSelf->_nuidLabel setText: [weakSelf->_plugin GetNuidWithPresent: false]];
        
        float height = 0;
        for (NSString* placementId in placements) {
            PlacementUiView *controller = (PlacementUiView *)[[NSBundle mainBundle] loadNibNamed:@"PlacementUiView" owner:nil options:nil][0];
            [controller SetPlacement:weakSelf->_plugin with: placements[placementId] isTest: isTest];
            controller.frame = CGRectMake(0, height, 360, 160);
            [weakSelf->_placementContainer addSubview: controller];
            weakSelf->_controllers[placementId] = controller;
            height += 160;
        }
        weakSelf.placementsScroll.contentSize = CGSizeMake(360, height);
    };
    
    _plugin.OnBid = ^(Placement *placement, BidResponse *bid) {
        [weakSelf->_controllers[placement._id] OnBid: bid];
    };
    _plugin.OnLoadStart = ^(Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnLoadStart];
    };
    _plugin.OnLoadFail = ^(Placement *placement, NSString *error) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnLoadFail: error];
    };
    _plugin.OnLoad = ^(Placement *placement, NSInteger width, NSInteger height) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnLoad: width height:height];
    };
    _plugin.OnShow = ^(Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnShow];
    };
    _plugin.OnClose = ^(Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnClose];
    };
    
    [_plugin PrepareRendererWithViewController: self];
    [_plugin EnableAds: true];
    
    [_plugin.Events AddProgressionEventWithStatus:ProgressionStatusComplete type:ProgressionTypeAchievement source:ProgressionSourceUndefined];
}

@end
