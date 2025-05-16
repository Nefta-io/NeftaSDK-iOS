//
//  BannerController.m
//  DirectIntegration
//
//  Created by Tomaz Treven on 1. 10. 24.
//

#import "BannerController.h"
#import "ViewController.h"

@implementation BannerController

static const int FLOW_NONE = 0;
static const int FLOW_MANUAL = 1;
static const int FLOW_AUTO_LOAD = 2;
static const int FLOW_AUTO_SHOWN = 3;
static const int FLOW_AUTO_HIDDEN = 4;

-(void)Init:(Placement *_Nonnull)placement viewController:(UIViewController *)viewController callback:(id<IAdUnitCallback> _Nonnull)callback {
    _banner = [[NBanner alloc] initWithId: placement._id parent: [ViewController GetBannerPlaceholder]];
    _banner._listener = self;
    
    super.ad = _banner;
    [super Init: placement viewController: viewController callback: callback];
}

- (IBAction)OnBidClick:(id)sender {
    if (_flowState == FLOW_NONE) {
        _flowState = FLOW_MANUAL;
    }
    
    NSDictionary *partial = [_banner GetPartialBidRequest];
    
    NSMutableDictionary *requestObject = [NSMutableDictionary dictionary];
    [requestObject setObject:[[NSUUID UUID] UUIDString] forKey:@"id"];
    
    [requestObject addEntriesFromDictionary: partial];
    
    [super OnBidClick: sender];
}

- (IBAction)OnLoadClick:(id)sender {
    if (_flowState == FLOW_NONE) {
        _flowState = FLOW_MANUAL;
    }
    [super OnLoadClick: sender];
}

- (IBAction)OnShowClick:(id)sender {    
    switch (_flowState) {
        case FLOW_NONE:
            [_banner SetAutoRefresh: true];
            [super.showButton setTitle: @"Loading" forState: UIControlStateNormal];
            _flowState = FLOW_AUTO_LOAD;
            [_banner Show: self.viewController];
            break;
        case FLOW_MANUAL:
            [_banner Show: self.viewController];
            break;
        case FLOW_AUTO_LOAD:
            break;
        case FLOW_AUTO_SHOWN:
            _flowState = FLOW_AUTO_HIDDEN;
            [super.showButton setTitle: @"Show" forState: UIControlStateNormal];
            [_banner Hide];
        case FLOW_AUTO_HIDDEN:
            _flowState = FLOW_AUTO_SHOWN;
            [super.showButton setTitle: @"Hide" forState: UIControlStateNormal];
            [_banner Show: self.viewController];
            break;
    }
}

- (void)OnShowWithAd:(NAd * _Nonnull)ad {
    if (_flowState == FLOW_AUTO_LOAD) {
        [super.showButton setTitle: @"Hide" forState: UIControlStateNormal];
        _flowState = FLOW_AUTO_SHOWN;
    }
    [super OnShowWithAd: ad];
}

- (void)OnCloseWithAd:(NAd * _Nonnull)ad {
    _banner = nil;
    [super OnCloseWithAd: ad];
}

@end
