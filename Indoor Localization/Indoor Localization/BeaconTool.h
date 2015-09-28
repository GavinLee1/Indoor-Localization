//
//  BeaconTool.h
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/28.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RealPoint.h"
#import "BeaconModel.h"

@interface BeaconTool : NSObject

- (RealPoint *) computeRealTimePoint: (NSArray *) beaconModels;

@end
