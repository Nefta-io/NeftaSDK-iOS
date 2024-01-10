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

    _appId = @"5630785994358784";
    [NeftaPlugin_iOS EnableLogging: true];
    _plugin = [NeftaPlugin_iOS InitWithAppId: _appId];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    _plugin.OnReady = ^(NSDictionary<NSString *, Placement *> * placements) {
        NSString* userString = [weakSelf->_plugin GetToolboxUser];
        NSData *userData = [userString dataUsingEncoding:NSUTF8StringEncoding];
        if (userData) {
            NSError *error = nil;
            id user = [NSJSONSerialization JSONObjectWithData:userData options:0 error:&error];
            if (error) {
                NSLog(@"Error parsing user json: %@", error.localizedDescription);
            } else {
                if ([user isKindOfClass:[NSDictionary class]]) {
                    weakSelf->_nuid = user[@"user_id"];
                    [weakSelf->_nuidLabel setText: weakSelf->_nuid];
                }
            }
        }
        
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

    [_plugin PrepareRendererWithView: self.view];
    [_plugin EnableAds: true];
    
    NSString *appIdLabel;
    if (_appId == nil || [_appId length] == 0) {
        appIdLabel = @"Demo mode (appId not set)";
    } else {
        appIdLabel = [NSString stringWithFormat: @"AppId: %@", _appId];
    }
    [_appIdLabel setText: appIdLabel];
    UITapGestureRecognizer *appIdGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(appIdTapped:)];
    [_appIdLabel addGestureRecognizer: appIdGesture];
    [_appIdLabel setUserInteractionEnabled: YES];
    
    UITapGestureRecognizer *nuidGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nuidTapped:)];
    [_nuidLabel addGestureRecognizer: nuidGesture];
    [_nuidLabel setUserInteractionEnabled: YES];
}

- (void)appIdTapped:(UITapGestureRecognizer *)gestureRecognizer {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString: _appId];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AppId copied"
                                                                   message:_appId
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)nuidTapped:(UITapGestureRecognizer *)gestureRecognizer {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString: _nuid];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nuid copied"
                                                                   message:_nuid
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
