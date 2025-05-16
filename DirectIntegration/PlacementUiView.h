//
//  PlacementUiViewController.h
//  TestbedIOS
//
//  Created by Tomaz Treven on 18/09/2023.
//

#import <UIKit/UIKit.h>
#import <NeftaSDK/NeftaSDK-Swift.h>

#import "IAdUnitCallback.h"
#import "AdUnitController.h"

@interface PlacementUiView : UIView<IAdUnitCallback>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak) IBOutlet UIStackView *adUnitContainer;

@property Placement * _Nonnull placement;
@property UIViewController * _Nonnull viewController;
@property NSMutableArray* _Nonnull adUnits;

-(void)Init:(Placement * _Nonnull)placement viewController:(UIViewController * _Nonnull)viewController;

-(int)Reposition:(CGRect) rect;
-(void)OnAdUnitClose:(AdUnitController * _Nonnull)adUnit;

@end
