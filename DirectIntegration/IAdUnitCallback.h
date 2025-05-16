//
//  IAdUnitCallback.h
//  DirectIntegration
//
//  Created by Tomaz Treven on 26. 10. 24.
//

#import <Foundation/Foundation.h>

@class AdUnitController;

@protocol IAdUnitCallback <NSObject>
-(void)OnAdUnitClose:(AdUnitController * _Nonnull)adUnit;
@end
