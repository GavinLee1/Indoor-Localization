//
//  TestingData.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/10/3.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "TestingData.h"

@implementation TestingData

+ (NSArray *) initTestingData
{
    NSMutableArray *array = [NSMutableArray array];
    
    BeaconModel *beacon0 = [[BeaconModel alloc] init];
    beacon0.major = 0;
    beacon0.minor = 0;
    beacon0.rssi = (-1)*(arc4random()%30 + 50);
    beacon0.accuracy = 4.5;
    beacon0.proximity = CLProximityUnknown;
    //    CLProximityUnknown,
    //    CLProximityImmediate,
    //    CLProximityNear,
    //    CLProximityFar
    [array addObject:beacon0];
    
    BeaconModel *beacon1 = [[BeaconModel alloc] init];
    beacon1.major = 0;
    beacon1.minor = 1;
    beacon1.accuracy = 7.5;
    beacon1.proximity = CLProximityNear;
    beacon1.rssi = (-1)*(arc4random()%30 + 50);
    [array addObject:beacon1];
    
    BeaconModel *beacon2 = [[BeaconModel alloc] init];
    beacon2.major = 0;
    beacon2.minor = 2;
    beacon2.accuracy = 2.5;
    beacon2.proximity = CLProximityNear;
    beacon2.rssi = (-1)*(arc4random()%30 + 50);
    [array addObject:beacon2];
    
    BeaconModel *beacon3 = [[BeaconModel alloc] init];
    beacon3.major = 0;
    beacon3.minor = 3;
    beacon3.accuracy = 5.5;
    beacon3.proximity = CLProximityImmediate;
    beacon3.rssi = (-1)*(arc4random()%30 + 50);
    [array addObject:beacon3];
    
    return array;
}

@end
