//
//  RealPointDataBase.h
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/28.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RealPoint.h"
#import "FMDatabase.h"

@interface RealPointDataBase : NSObject

+ (RealPoint *) getTheMostUpdatedPoint;

/**
 *  @return All points in the database.
 */
+ (NSArray *) points;

/**
 *  Inset a point in the database.
 *
 *  @param point a point object.
 */
+ (void)addPoint:(RealPoint *)point;

/**
 *  Remove all records in the database table t_point.
 */
+ (void)removeAllPoints;

/**
 *  @return The total records number in the database.
 */
+ (NSUInteger) count;

/**
 *  Since as design, this system only need 10 points to draw the track line.
 *  Therefore, this function is design to get reasonable 10 points from the database.
 *
 *  @return a NSArray contains point objects.
 */
+ (NSArray *) trackedPoints;

@end
