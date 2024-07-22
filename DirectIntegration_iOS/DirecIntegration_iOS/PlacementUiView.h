//
//  PlacementUiViewController.h
//  TestbedIOS
//
//  Created by Tomaz Treven on 18/09/2023.
//

#import <UIKit/UIKit.h>
#import <NeftaSDK/NeftaSDK-Swift.h>

@interface PlacementUiView : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *bidButton;
@property (weak, nonatomic) IBOutlet UISwitch *enableBannerSwitch;
@property (weak, nonatomic) IBOutlet UILabel *enableBannerLabel;
@property (weak, nonatomic) IBOutlet UILabel *availableBidLabel;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UILabel *bufferedBidLabel;
@property (weak, nonatomic) IBOutlet UIButton *showButton;
@property (weak, nonatomic) IBOutlet UILabel *renderedBidLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property NeftaPlugin_iOS *plugin;
@property Placement *placement;

-(void)SetPlacement:(NeftaPlugin_iOS *) plugin with:(Placement *) placement;
-(void)OnBid:(BidResponse *)bidResponse;
-(void)OnLoadStart;
-(void)OnLoadFail:(NSString *)error;
-(void)OnLoad:(NSInteger)width height:(NSInteger)height;
-(void)OnShow;
-(void)OnClose;

-(void)SyncUi;
@end
