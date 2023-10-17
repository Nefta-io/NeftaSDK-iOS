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
    
    _plugin.OnReady = ^(NSDictionary<NSString *, Placement *> * placements) {
        int i = 0;
        for (NSString* placementId in placements) {
            PlacementUiView *controller = (PlacementUiView *)[[NSBundle mainBundle] loadNibNamed:@"PlacementUiView" owner:nil options:nil][0];
            [controller SetPlacement:_plugin with: placements[placementId] autoLoad: __autoLoadSwitch.isOn];
            controller.frame = CGRectMake(0, i * 160, 390, 160);
            [self->__placementContainer addSubview: controller];
            self->_controllers[placementId] = controller;
            i++;
        }
    };
    
    _plugin.OnBid = ^(Placement *placement, BidResponse *bid) {
        [self->_controllers[placement._id] OnBid: bid];
    };
    _plugin.OnLoadStart = ^(Placement *placement) {
        PlacementUiView *view = self->_controllers[placement._id];
        [view OnLoadStart];
    };
    _plugin.OnLoadFail = ^(Placement *placement, NSString *error) {
        PlacementUiView *view = self->_controllers[placement._id];
        [view OnLoadFail: error];
    };
    _plugin.OnLoad = ^(Placement *placement) {
        PlacementUiView *view = self->_controllers[placement._id];
        [view OnLoad];
    };
    _plugin.OnShow = ^(Placement *placement, NSInteger width, NSInteger height) {
        [self->_controllers[placement._id] OnShow: width height:height];
    };
    _plugin.OnClose = ^(Placement *placement) {
        PlacementUiView *view = self->_controllers[placement._id];
        [view OnClose];
    };

    [_plugin InitWithUiView:self.view appId: nil useMessages: false];
    
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
