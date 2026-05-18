//
//  ViewController.m
//  TestbedIOS
//
//  Created by Tomaz Treven on 13/09/2023.
//

#import "ViewController.h"

#import "DirectIntegration-Swift.h"

@implementation ViewController
-(void)viewDidAppear:(BOOL)animated {
    [DebugServer InitWithViewController: self];
    
    _appId = @"5742528628260864";
    [_appIdLabel setText: [NSString stringWithFormat: @"AppId: %@", _appId]];
    
    [NeftaPlugin SetExtraParameterWithKey: NeftaPlugin.ExtParam_TestGroup value: @"split-direct"];
    
    [NeftaPlugin EnableLogging: true];
    _plugin = [NeftaPlugin NativeInitWithAppId: _appId clientId: nil onReady: ^(InitConfiguration *initConfig) {
        NSLog(@"NeftaPluginDI Nefta initialized, nuid: %@", initConfig._nuid);
    } integration: @"direct" mediationVersion: @"/"];
}

@end
