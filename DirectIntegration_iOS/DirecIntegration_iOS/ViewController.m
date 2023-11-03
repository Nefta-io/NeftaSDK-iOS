//
//  ViewController.m
//  TestbedIOS
//
//  Created by Tomaz Treven on 13/09/2023.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "PlacementUiView.h"

@implementation ViewController

-(void)viewDidAppear:(BOOL)animated {

    _controllers = [[NSMutableDictionary alloc] init];
    
    _plugin = [[NeftaPlugin_iOS alloc] init];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    _plugin.OnReady = ^(NSDictionary<NSString *, Placement *> * placements) {
        int i = 0;
        for (NSString* placementId in placements) {
            PlacementUiView *controller = (PlacementUiView *)[[NSBundle mainBundle] loadNibNamed:@"PlacementUiView" owner:nil options:nil][0];
            [controller SetPlacement:weakSelf->_plugin with: placements[placementId]];
            controller.frame = CGRectMake(0, i * 160, 390, 160);
            [weakSelf->_placementContainer addSubview: controller];
            weakSelf->_controllers[placementId] = controller;
            i++;
        }
    };
    
    _plugin.OnBid = ^(Types type, Placement *placement, BidResponse *bid) {
        [weakSelf->_controllers[placement._id] OnBid: bid];
    };
    _plugin.OnLoadStart = ^(Types type, Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnLoadStart];
    };
    _plugin.OnLoadFail = ^(Types type, Placement *placement, NSString *error) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnLoadFail: error];
    };
    _plugin.OnLoad = ^(Types type, Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnLoad];
    };
    _plugin.OnShow = ^(Types type, Placement *placement, NSInteger width, NSInteger height) {
        [weakSelf->_controllers[placement._id] OnShow: width height:height];
    };
    _plugin.OnClose = ^(Types type, Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnClose];
    };

    NSString *appId = @"5070114386870272";
    [_plugin InitWithAppId: appId useMessages: false];
    [_plugin PrepareRendererWithUiView: self.view];
    
    NSString *appIdLabel;
    if (appId == nil || [appId length] == 0) {
        appIdLabel = @"Demo mode (appId not set)";
    } else {
        appIdLabel = [NSString stringWithFormat: @"AppId: %@", appId];
    }
    [_appIdLabel setText: appIdLabel];
}

@end
