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

static NSString * const _logsKey = @"logs";
static NSString * const _overrideUrlKey = @"overrideUrl";

@implementation ViewController

-(void)viewDidAppear:(BOOL)animated {
    if (_controllers != nil) {
        return;
    }
    
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
    NSString *logs = [defaults objectForKey: _logsKey];
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
    
    NSString *overrideUrl = [defaults stringForKey: _overrideUrlKey];
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    if ([arguments count] > 1) {
        overrideUrl = arguments[1];
    }
    
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
    
    [_logsButton addTarget: self action:@selector(OnSendLogs:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *nuidGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nuidTapped:)];
    [_nuidLabel addGestureRecognizer: nuidGesture];
    [_nuidLabel setUserInteractionEnabled: YES];
    
    [_overrideText setText: overrideUrl];
    [_overrideButton addTarget: self action:@selector(OnOverride:) forControlEvents:UIControlEventTouchUpInside];
    
    [_closeButton addTarget: self action:@selector(OnClose:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    [NeftaPlugin_iOS EnableLogging: true];
    _plugin = [NeftaPlugin_iOS InitWithAppId: _appId];
    if (overrideUrl != nil && overrideUrl.length > 0) {
        [_plugin SetOverrideWithUrl: overrideUrl];
    }
    [_plugin SetCustomParameterWithId: @"5679149674921984" key: @"bidfloor" value: @0.3];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    _plugin.OnReady = ^(NSDictionary<NSString *, Placement *> * placements) {
        [weakSelf->_nuidLabel setText: [weakSelf->_plugin GetNuidWithPresent: false]];
        
        float height = 0;
        for (NSString* placementId in placements) {
            PlacementUiView *controller = (PlacementUiView *)[[NSBundle mainBundle] loadNibNamed:@"PlacementUiView" owner:nil options:nil][0];
            [controller SetPlacement:weakSelf->_plugin with: placements[placementId]];
            controller.frame = CGRectMake(0, height, 360, 160);
            [weakSelf->_placementContainer addSubview: controller];
            weakSelf->_controllers[placementId] = controller;
            height += 160;
        }
        weakSelf.placementsScroll.contentSize = CGSizeMake(360, height);
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
    _plugin.OnLoad = ^(Placement *placement, NSInteger width, NSInteger height) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnLoad: width height:height];
    };
    _plugin.OnShow = ^(Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnShow];
    };
    _plugin.OnClose = ^(Placement *placement) {
        PlacementUiView *view = weakSelf->_controllers[placement._id];
        [view OnClose];
    };
    
    [_plugin PrepareRendererWithViewController: self];
    [_plugin EnableAds: true];
    
    [_plugin.Events AddProgressionEventWithStatus:ProgressionStatusComplete type:ProgressionTypeAchievement source:ProgressionSourceUndefined];
}

- (void)titleTapped:(UITapGestureRecognizer *)gestureRecognizer {
    [_optionsView setHidden: false];
}

- (void)OnSendLogs:(UIButton *)sender {
    [self SendLogs];
}

- (void)nuidTapped:(UITapGestureRecognizer *)gestureRecognizer {
    NSString *nuid = [_plugin GetNuidWithPresent: true];
    
    [_plugin.Events AddSpendEventWithCategory:ResourceCategoryOther method:SpendMethodContinuity];
}

- (void)OnClose:(UITapGestureRecognizer *)gestureRecognizer {
    [_optionsView setHidden: true];
}

- (void)OnOverride:(UITapGestureRecognizer *)gestureRecognizer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: _overrideText.text forKey: _overrideUrlKey];
    [defaults synchronize];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
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
