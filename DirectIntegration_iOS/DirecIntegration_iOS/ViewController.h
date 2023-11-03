//
//  ViewController.h
//  TestbedIOS
//
//  Created by Tomaz Treven on 13/09/2023.
//

#import <UIKit/UIKit.h>
#import <NeftaPlugin_iOS/NeftaPlugin_iOS.h>

@interface ViewController : UIViewController
@property NeftaPlugin_iOS *plugin;
@property (weak, nonatomic) IBOutlet UIView *placementContainer;
@property (weak, nonatomic) IBOutlet UILabel *appIdLabel;
@property NSMutableDictionary* controllers;
@end

