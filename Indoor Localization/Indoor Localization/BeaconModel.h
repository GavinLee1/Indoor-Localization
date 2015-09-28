//
//  BeaconModel.h
//  IndoorScanData
//
//  Created by LIGAOZHAO on 15/9/24.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconModel : NSObject

@property (assign, nonatomic) NSInteger major;
@property (assign, nonatomic) NSInteger minor;
@property (assign, nonatomic) NSInteger rssi;
@property (assign, nonatomic) NSInteger scannedTimes;

@end
