//
//  ViewController.h
//  TestbedIOS
//
//  Created by Tomaz Treven on 13/09/2023.
//

#import <UIKit/UIKit.h>
#import <NeftaSDK/NeftaSDK-Swift.h>

@interface ViewController : UIViewController
@property NeftaPlugin_iOS *plugin;
@property NSString *appId;
@property NSString *nuid;
@property (weak, nonatomic) IBOutlet UIView *placementContainer;
@property (weak, nonatomic) IBOutlet UILabel *appIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *nuidLabel;
@property NSMutableDictionary* controllers;
@end

