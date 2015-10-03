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

/**
 *  Core calculation algorithms, invovling LDPL and Linear Least Square Algorithm.
 *  LDPL can compute the distance from device to a specific beacon with RSSI value.
 *  LLSA can compute a accurate location point with three beacons.
 *
 *  @param beaconModels NSArray including three sorted beaconModels, sorting or not is not mandatory.
 *
 *  @return a point object which means the current location, the x and y value for the point is in meter.
 */
- (RealPoint *) computeRealTimePoint: (NSArray *) beaconModels;

/**
 *  Be called every 5 senconds in onTicking method.
 *  It is designed to sort the beacon array with RSSI value and get the top three beacons.
 *
 *  @return NSArray records threes beaonModel objects.
 */
- (NSArray *) getTopThreeBeacons: (NSArray *) beaconsStore;

/**
 *  Compute the distance to the located beacon. Using the algorithm of LDPL.
 *
 *  @param rssi the rssi value received from beacon
 *
 *  @return the vallue of distance
 */
- (float) computeDistance: (float) rssi;

@end
