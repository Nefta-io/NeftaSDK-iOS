//
//  PlacementUiViewController.m
//  TestbedIOS
//
//  Created by Tomaz Treven on 18/09/2023.
//

#import <Foundation/Foundation.h>
#import "PlacementUiView.h"

@implementation PlacementUiView

-(void)SetPlacement:(NeftaPlugin_iOS *) plugin with: (Placement *) placement autoLoad: (BOOL) autoLoad {
    _plugin = plugin;
    _placement = placement;
    _isAutoLoad = autoLoad;
    
    NSString *name;
    if (placement._type == 0) {
        name = [NSString stringWithFormat:@"BANNER(%@)", placement._id];
    } else if (placement._type == 1) {
        name = [NSString stringWithFormat:@"INTERSTITIAL(%@)", placement._id];
    } else if (placement._type == 2) {
        name = [NSString stringWithFormat:@"REWARDED(%@)", placement._id];
    }
    [_nameLabel setText: name];
    
    [_bidButton addTarget:self action:@selector(OnBidClick:) forControlEvents:UIControlEventTouchUpInside];
    [_loadButton addTarget:self action:@selector(OnLoadClick:) forControlEvents:UIControlEventTouchUpInside];
    [_showButton addTarget:self action:@selector(OnShowClick:) forControlEvents:UIControlEventTouchUpInside];
    [_closeButton addTarget:self action:@selector(OnCloseClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self SyncUi];
}

-(void)SetAutoLoad:(BOOL)autoLoad {
    _isAutoLoad = autoLoad;
}

- (IBAction)OnBidClick:(id)sender {
    if (_isAutoLoad) {
        [_plugin BidWithId: _placement._id];
    } else {
        [_plugin BidWithoutAutoLoadWithId: _placement._id];
    }
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
    [_bidButton setEnabled: !_placement._isBidding];
    [_loadButton setTitle: _placement._isLoading ? @"Loading" : @"Load" forState: UIControlStateNormal];
    [_loadButton setEnabled: [_placement CanLoad ] ];
    
    
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
