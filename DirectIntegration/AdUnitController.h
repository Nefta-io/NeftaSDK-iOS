//
//  AdUnitController.h
//  DirectIntegration
//
//  Created by Tomaz Treven on 1. 10. 24.
//
#import <Foundation/Foundation.h>

#import "PlacementUiView.h"
#import "IAdUnitCallback.h"

@interface AdUnitController : UIView

@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *bidButton;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIButton *showButton;
@property (weak, nonatomic) IBOutlet UIButton *destroyButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property NAd * _Nullable ad;
@property UIViewController * _Nonnull viewController;
@property id<IAdUnitCallback> _Nonnull callback;
-(void)Init:(Placement *_Nonnull)placement viewController:(UIViewController * _Nonnull)viewController callback:(id<IAdUnitCallback> _Nonnull) callback;

-(IBAction)OnBidClick:(id _Nonnull)sender;
-(IBAction)OnLoadClick:(id _Nonnull)sender;

-(void)OnBidWithAd:(NAd * _Nonnull)ad bidResponse:(BidResponse * _Nullable)bidResponse error:(NError * _Nullable)error;
-(void)OnLoadFailWithAd:(NAd * _Nonnull)ad error:(NError * _Nonnull)error;
-(void)OnLoadWithAd:(NAd * _Nonnull)ad width:(NSInteger)width height:(NSInteger)height;
-(void)OnShowFailWithAd:(NAd * _Nonnull)ad error:(NError * _Nonnull)error;
-(void)OnShowWithAd:(NAd * _Nonnull)ad;
-(void)OnCloseWithAd:(NAd * _Nonnull)ad;
@end
