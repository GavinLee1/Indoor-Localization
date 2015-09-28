//
//  BeaconTool.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/28.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "BeaconTool.h"

@implementation BeaconTool

/**
 ** Design to initialize the located beacon points.
 ** Coodinate values of points must be in meter of the real indoor environment.
 **
 **/
- (NSMutableArray *) initializeLocatedBeaconPoints
{
    NSMutableArray *locatedBeaconPoints = [NSMutableArray array];
    RealPoint *point0 = [[RealPoint alloc] initWith:0.5 andY:0.8];
    [locatedBeaconPoints addObject:point0];
    RealPoint *point1 = [[RealPoint alloc] initWith:5.5 andY:0.8];
    [locatedBeaconPoints addObject:point1];
    RealPoint *point2 = [[RealPoint alloc] initWith:8.5 andY:0.5];
    [locatedBeaconPoints addObject:point2];
    RealPoint *point3 = [[RealPoint alloc] initWith:0.5 andY:3.8];
    [locatedBeaconPoints addObject:point3];
    RealPoint *point4 = [[RealPoint alloc] initWith:5.5 andY:3.8];
    [locatedBeaconPoints addObject:point4];
    RealPoint *point5 = [[RealPoint alloc] initWith:9 andY:4.5];
    [locatedBeaconPoints addObject:point5];
    
    return locatedBeaconPoints;
}

- (RealPoint *) computeRealTimePoint: (NSArray *) beaconModels
{
    if ([beaconModels count] < 3) {
        return [[RealPoint alloc] initWith:-1000 andY:-1000];
    }
    // RSSI for one meter from the beacon
#define A 70
    // The signal propagation constant in a specific environment
#define N 1.66
    // Record the output x value (in meter) afther calculating
    float xValue;
    // Record the output y value (in meter) afther calculating
    float yValue;
    // Record three distance value from user to each located beacon
    NSMutableArray *distances = [NSMutableArray array];
    // Record three located beacons, which are selected by ranking RSSI.
    NSMutableArray *selectedThreeBeacons = [NSMutableArray array];
    // Initialize the located beacon points
    NSArray *locatedBeaconPoints = [self initializeLocatedBeaconPoints];
    int computeTag = 0;
    
    while (computeTag <= 2) {
        // Get the beacon ranks from 0 to 2 in array beaconModels
        BeaconModel *tempBeacon = [beaconModels objectAtIndex:computeTag];
        // Be used to point at the specifical located beacon
        int locatedBeaconPointIndex = (int)tempBeacon.minor;
        float tempRSSI = (float) tempBeacon.rssi;
        // Get the selected beacon
        RealPoint *tempLocatedBeaconPoint = [locatedBeaconPoints objectAtIndex:locatedBeaconPointIndex];
        // Add it into the array, one by one
        [selectedThreeBeacons addObject:tempLocatedBeaconPoint];
        
        /********** Applying LDPL **********/
        // Calculate and get the distance from user to the current beacon
        float tempDistance = (0 - A - tempRSSI) / 10 / N;
        // temDistance 的10次方就是distance
        float distance = pow(10, tempDistance);
        if (distance > 1.0) {
            distance = distance * distance - 1;
            distance = sqrt(distance);
        }
        distance = round(distance);
        // Add each distance value into the array
        [distances addObject:@(distance)];
        computeTag++;
    }
    
    /**********  Applying Linear Least Square Algorithm  **********/
    /**************************************************************/
    RealPoint *selectedBeacon0 = [selectedThreeBeacons objectAtIndex:0];
    RealPoint *selectedBeacon1 = [selectedThreeBeacons objectAtIndex:1];
    RealPoint *selectedBeacon2 = [selectedThreeBeacons objectAtIndex:2];
    // b0 = x[1]*x[1]+y[1]*y[1]-x[0]*x[0]-y[0]*y[0]-d[1]*d[1]+d[0]*d[0]
    float b0 = selectedBeacon1.originalX * selectedBeacon1.originalX + selectedBeacon1.originalY * selectedBeacon1.originalY - selectedBeacon0.originalX * selectedBeacon0.originalX - selectedBeacon0.originalY * selectedBeacon0.originalY - [[distances objectAtIndex:1] floatValue] * [[distances objectAtIndex:1] floatValue] + [[distances objectAtIndex:0] floatValue] * [[distances objectAtIndex:0] floatValue];
    // b1 = x[2]*x[2]+y[2]*y[2]-x[0]*x[0]-y[0]*y[0]-d[2]*d[2]+d[0]*d[0]
    float b1 = selectedBeacon2.originalX * selectedBeacon2.originalX + selectedBeacon2.originalY * selectedBeacon2.originalY - selectedBeacon0.originalX * selectedBeacon0.originalX - selectedBeacon0.originalY * selectedBeacon0.originalY - [[distances objectAtIndex:2] floatValue] * [[distances objectAtIndex:2] floatValue] + [[distances objectAtIndex:0] floatValue] * [[distances objectAtIndex:0] floatValue];
    
    // M0=2*(x[1]-x[0])
    float M0 = 2 * (selectedBeacon1.originalX - selectedBeacon0.originalX);
    // M1=2*(y[1]-y[0])
    float M1 = 2 * (selectedBeacon1.originalY - selectedBeacon0.originalY);
    // M2=2*(x[2]-x[0])
    float M2 = 2 * (selectedBeacon2.originalX - selectedBeacon0.originalX);
    // M3=2*(y[2]-y[0])
    float M3 = 2 * (selectedBeacon2.originalY - selectedBeacon0.originalY);
    
    // T0=M0*M0+M2*M2
    float T0 = M0 * M0 + M2 * M2;
    // T1=M0*M1+M2*M3
    float T1 = M0 * M1 + M2 * M3;
    float T2 = T1;
    float T3 = M1 * M1 + M3 * M3;
    
    xValue = (( M0 * T3 - T1 * M1 ) * b0 + ( T3 * M2 - T1 * M3 ) * b1 ) / ( T0 * T3 - T1 * T2 );
    yValue = (( M1 * T0 - T2 * M0 ) * b0 + ( T0 * M3 - T2 * M2 ) * b1 ) / ( T0 * T3 - T1 * T2 );
    /**************************************************************/
    /**************************************************************/
    
    RealPoint *tempPoint = [[RealPoint alloc] initWith:xValue andY:yValue];
    
    return tempPoint;
}

@end
