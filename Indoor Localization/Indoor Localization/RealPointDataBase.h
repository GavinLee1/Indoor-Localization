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
+ (NSArray *) points;
+ (RealPoint *) getTheMostUpdatedPoint;
+ (void)addPoint:(RealPoint *)point;

@end
