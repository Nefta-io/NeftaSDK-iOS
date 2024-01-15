//
//  PlacementUiViewController.m
//  TestbedIOS
//
//  Created by Tomaz Treven on 18/09/2023.
//

#import <Foundation/Foundation.h>
#import "PlacementUiView.h"

@implementation PlacementUiView

-(void)SetPlacement:(NeftaPlugin_iOS *) plugin with: (Placement *) placement {
    _plugin = plugin;
    _placement = placement;
    
    NSString *name;
    Boolean isBanner = false;
    if (placement._type == TypesBanner) {
        name = [NSString stringWithFormat:@"Banner(%@)", placement._id];
        isBanner = true;
    } else if (placement._type == TypesInterstitial) {
        name = [NSString stringWithFormat:@"Interstitial(%@)", placement._id];
    } else if (placement._type == TypesRewardedVideo) {
        name = [NSString stringWithFormat:@"Rewarded(%@)", placement._id];
    }
    [_nameLabel setText: name];
    
    [_enableBannerSwitch setHidden: !isBanner];
    [_enableBannerLabel setHidden: !isBanner];
    
    [_enableBannerSwitch addTarget:self action:@selector(OnEnableBannerSwitch:) forControlEvents:UIControlEventValueChanged];
    [_bidButton addTarget:self action:@selector(OnBidClick:) forControlEvents:UIControlEventTouchUpInside];
    [_loadButton addTarget:self action:@selector(OnLoadClick:) forControlEvents:UIControlEventTouchUpInside];
    [_showButton addTarget:self action:@selector(OnShowClick:) forControlEvents:UIControlEventTouchUpInside];
    [_closeButton addTarget:self action:@selector(OnCloseClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self SyncUi];
}

- (IBAction)OnEnableBannerSwitch:(UISwitch *)sender {
    [_plugin EnableBannerWithId: _placement._id enable:  sender.isOn];
    
    [self SyncUi];
}

- (IBAction)OnBidClick:(id)sender {
    [_plugin BidWithId: _placement._id];

    [self SyncUi];
}

- (IBAction)OnLoadClick:(id)sender {
    [_plugin LoadWithId: _placement._id];
}

- (IBAction)OnShowClick:(id)sender {
    [_plugin ShowWithId: _placement._id];
}

- (IBAction)OnCloseClick:(id)sender {
    [_plugin CloseWithId: _placement._id];
}

- (void)OnBid:(BidResponse *)bidResponse {
    [self SyncUi];
}

- (void)OnLoadStart {
    [self SyncUi];
}

- (void)OnLoadFail:(NSString *)error {
    [self SyncUi];
}

- (void)OnLoad {
    [self SyncUi];
}

- (void)OnShow:(NSInteger)width height:(NSInteger)height {
    [self SyncUi];
}

- (void)OnClose {
    [self SyncUi];
}

- (void)SyncUi {
    NSString *bid;
    if (_placement._availableBid == nil) {
        bid = @"Available bid:";
    } else {
        bid = [NSString stringWithFormat: @"Available bid: %@ (%f)", _placement._availableBid._id, _placement._availableBid._price];
    }
    [_availableBidLabel setText:bid];
 
    if (_placement.IsBidding) {
        [_bidButton setEnabled: false];
        [_bidButton setTitle: @"Bidding" forState: UIControlStateDisabled];
    } else {
        [_bidButton setEnabled: true];
        [_bidButton setTitle: @"Bid" forState: UIControlStateNormal];
    }
  
    if (_placement.CanLoad) {
        [_loadButton setEnabled: true ];
        [_loadButton setTitle: @"Load" forState: UIControlStateNormal];
    } else {
        [_loadButton setEnabled: false ];
        [_loadButton setTitle: _placement.IsLoading ? @"Loading" : @"Load" forState: UIControlStateDisabled];
    }
    
    if (_placement._bufferBid == nil) {
        bid = @"Buffered bid:";
    } else {
        bid = [NSString stringWithFormat: @"Buffered bid: %@", _placement._bufferBid._id];
    }
    [_bufferedBidLabel setText:bid];
    [_showButton setEnabled: [_placement CanShow ] ];
    
    if (_placement._renderedBid == nil) {
        bid = @"Rendered bid:";
    } else {
        bid = [NSString stringWithFormat: @"Rendered bid: %@", _placement._renderedBid._id];
    }
    [_renderedBidLabel setText:bid];
    [_closeButton setEnabled: _placement._renderedBid != nil];
}
@end
