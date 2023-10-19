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

- (void)viewDidLoad {
    [super viewDidLoad];

    _controllers = [[NSMutableDictionary alloc] init];
    
    _plugin = [[NeftaPlugin_iOS alloc] init];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    _plugin.OnReady = ^(NSDictionary<NSString *, Placement *> * placements) {
        int i = 0;
        for (NSString* placementId in placements) {
            PlacementUiView *controller = (PlacementUiView *)[[NSBundle mainBundle] loadNibNamed:@"PlacementUiView" owner:nil options:nil][0];
            [controller SetPlacement:weakSelf->_plugin with: placements[placementId] autoLoad: weakSelf->__autoLoadSwitch.isOn];
            controller.frame = CGRectMake(0, i * 160, 390, 160);
            [weakSelf->__placementContainer addSubview: controller];
            weakSelf->_controllers[placementId] = controller;
            i++;
        }
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
    _plugin.OnLoad = ^(Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnLoad];
    };
    _plugin.OnShow = ^(Placement *placement, NSInteger width, NSInteger height) {
        [weakSelf->_controllers[placement._id] OnShow: width height:height];
    };
    _plugin.OnClose = ^(Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnClose];
    };

    [_plugin InitWithUiView:self.view appId: @"5667525748588544" useMessages: false];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPause) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (IBAction)_onAutoLoadChange:(id)sender {
    for (NSString* key in _controllers) {
        [_controllers[key] SetAutoLoad: __autoLoadSwitch.isOn];
    }
}

- (void)onResume {
    [_plugin OnResume];
}

- (void)onPause {
    [_plugin OnPause];
}

@end
