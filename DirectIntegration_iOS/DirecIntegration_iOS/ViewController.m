//
//  ViewController.m
//  TestbedIOS
//
//  Created by Tomaz Treven on 13/09/2023.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "PlacementUiView.h"

#import <sys/utsname.h>

@implementation ViewController

-(void)viewDidAppear:(BOOL)animated {
    
    _controllers = [[NSMutableDictionary alloc] init];
    
    _logDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _logDirectory = [_logDirectory stringByAppendingPathComponent:@"Logs"];
    BOOL isDirectory;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_logDirectory isDirectory:&isDirectory]) {
        [fileManager createDirectoryAtPath:_logDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Error creating directory: %@", [error localizedDescription]);
        }
    }
    
    _last3LogNames = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *logs = [defaults objectForKey:@"logs"];
    if (logs != nil && logs.length > 0) {
        NSArray *logArray = [logs componentsSeparatedByString: @","];
        long i = logArray.count - 2;
        if (i < 0) {
            i = 0;
        }
        for ( ; i < logArray.count; i++) {
            [_last3LogNames addObject: logArray[i]];
        }
    }
    
    NSString *logName = [NSString stringWithFormat: @"log_%d.txt", (int)[[NSDate date] timeIntervalSince1970]];
    NSString *logPath = [NSString stringWithFormat: @"%@/%@", _logDirectory, logName];
    [fileManager createFileAtPath: logPath contents:nil attributes:nil];
    NSFileHandle *logStreamer = [NSFileHandle fileHandleForWritingAtPath: logPath];
    [_last3LogNames addObject: logName];
    NeftaPlugin.OnLog = ^(NSString *log) {
        [logStreamer writeData: [log dataUsingEncoding: NSUTF8StringEncoding]];
    };
    
    [NeftaPlugin_iOS EnableLogging: true];
    
    NSMutableString *newLogs = [NSMutableString string];
    for (int i = 0; i < _last3LogNames.count; i++) {
        if (i > 0) {
            [newLogs appendString: @","];
        }
        [newLogs appendString: _last3LogNames[i]];
    }
    [defaults setObject: newLogs forKey:@"logs"];
    [defaults synchronize];
    
    _appId = @"5661184053215232";
    _plugin = [NeftaPlugin_iOS InitWithAppId: _appId];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    _plugin.OnReady = ^(NSDictionary<NSString *, Placement *> * placements) {
        NSString* userString = [weakSelf->_plugin GetToolboxUser];
        NSData *userData = [userString dataUsingEncoding:NSUTF8StringEncoding];
        if (userData) {
            NSError *error = nil;
            id user = [NSJSONSerialization JSONObjectWithData:userData options:0 error:&error];
            if (error) {
                NSLog(@"Error parsing user json: %@", error.localizedDescription);
            } else {
                if ([user isKindOfClass:[NSDictionary class]]) {
                    weakSelf->_nuid = user[@"user_id"];
                    [weakSelf->_nuidLabel setText: weakSelf->_nuid];
                }
            }
        }
        
        int i = 0;
        for (NSString* placementId in placements) {
            PlacementUiView *controller = (PlacementUiView *)[[NSBundle mainBundle] loadNibNamed:@"PlacementUiView" owner:nil options:nil][0];
            [controller SetPlacement:weakSelf->_plugin with: placements[placementId]];
            controller.frame = CGRectMake(0, i * 160, 390, 160);
            [weakSelf->_placementContainer addSubview: controller];
            weakSelf->_controllers[placementId] = controller;
            i++;
        }
    };
    
    _plugin.OnBid = ^(Placement *placement, BidResponse *bid) {
        [weakSelf->_controllers[placement._id] OnBid: bid];
    };
    _plugin.OnLoadStart = ^(Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnLoadStart];
    };
    _plugin.OnLoadFail = ^(Placement *placement, NSString *error) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnLoadFail: error];
    };
    _plugin.OnLoad = ^(Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnLoad];
    };
    _plugin.OnShow = ^(Placement *placement, NSInteger width, NSInteger height) {
        [weakSelf->_controllers[placement._id] OnShow: width height:height];
    };
    _plugin.OnClose = ^(Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnClose];
    };
    
    [_plugin PrepareRendererWithViewController: self];
    [_plugin EnableAds: true];
    
    UITapGestureRecognizer *titleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleTapped:)];
    [_titleLabel addGestureRecognizer: titleGesture];
    [_titleLabel setUserInteractionEnabled: YES];
    
    NSString *appIdLabel;
    if (_appId == nil || [_appId length] == 0) {
        appIdLabel = @"Demo mode (appId not set)";
    } else {
        appIdLabel = [NSString stringWithFormat: @"AppId: %@", _appId];
    }
    [_appIdLabel setText: appIdLabel];
    UITapGestureRecognizer *appIdGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(appIdTapped:)];
    [_appIdLabel addGestureRecognizer: appIdGesture];
    [_appIdLabel setUserInteractionEnabled: YES];
    
    UITapGestureRecognizer *nuidGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nuidTapped:)];
    [_nuidLabel addGestureRecognizer: nuidGesture];
    [_nuidLabel setUserInteractionEnabled: YES];
    
    [_plugin.Events AddProgressionEventWithStatus:ProgressionStatusComplete type:ProgressionTypeAchievement source:ProgressionSourceUndefined];
}

- (void)titleTapped:(UITapGestureRecognizer *)gestureRecognizer {
    [self SendLogs];
}

- (void)appIdTapped:(UITapGestureRecognizer *)gestureRecognizer {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString: _appId];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AppId copied"
                                                                   message:_appId
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)nuidTapped:(UITapGestureRecognizer *)gestureRecognizer {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString: _nuid];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nuid copied"
                                                                   message:_nuid
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    [_plugin.Events AddSpendEventWithCategory:ResourceCategoryOther method:SpendMethodContinuity];
}

- (void)SendLogs {
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Device does not support email sending.");
        return;
    }
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;

    [mc setSubject:@"Logs"];
    [mc setMessageBody:@"Logs:" isHTML:NO];
    
    NSError *error = nil;
    for (int i = 0; i < _last3LogNames.count; i++) {
        NSString *path = [NSString stringWithFormat: @"%@/%@", _logDirectory, _last3LogNames[i]];
        NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
        [mc addAttachmentData: data  mimeType: @"text/plain" fileName: _last3LogNames[i]];
    }
    
    [self presentViewController:mc animated:YES completion:nil];
}

@end
