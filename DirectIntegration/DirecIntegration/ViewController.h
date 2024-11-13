//
//  ViewController.h
//  TestbedIOS
//
//  Created by Tomaz Treven on 13/09/2023.
//

#import <UIKit/UIKit.h>
#import <NeftaSDK/NeftaSDK-Swift.h>

#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property NeftaPlugin *plugin;
@property NSString *appId;
@property (weak, nonatomic) IBOutlet UIView *bannerPlaceholder;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *placementsScroll;
@property (weak, nonatomic) IBOutlet UIView *placementContainer;

@property (weak, nonatomic) IBOutlet UILabel *appIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *nuidLabel;

+(UIView *) GetBannerPlaceholder;
+(void) Reposition;
@end

