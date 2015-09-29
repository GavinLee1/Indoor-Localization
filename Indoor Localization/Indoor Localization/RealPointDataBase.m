//
//  RealPointDataBase.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/28.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "RealPointDataBase.h"
#import "FMDatabaseAdditions.h"

@implementation RealPointDataBase

static FMDatabase *_db;

+ (void)initialize
{
    // 1.打开数据库
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"points.sqlite"];
    _db = [FMDatabase databaseWithPath:path];
    [_db open];
    // 2.创表
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_point (id integer PRIMARY KEY, xValue real NOT NULL, yValue real NOT NULL);"];
}

+ (NSArray *) points
{
    {
        // 得到结果集
        FMResultSet *set = [_db executeQuery:@"SELECT * FROM t_point;"];
        // 不断往下取数据
        NSMutableArray *points = [NSMutableArray array];
        while (set.next) {
            // 获得当前所指向的数据
            RealPoint *point = [[RealPoint alloc] init];
            point.originalX = [set doubleForColumn:@"xValue"];
            point.originalY = [set doubleForColumn:@"yValue"];
            [points addObject:point];
        }
        return points;
    }
}

/**
 *  Since as design, this system only need 10 points to draw the track line.
 *  Therefore, this function is design to get reasonable 10 points from the database.
 *
 *  @return a NSArray contains point objects.
 */
+ (NSArray *) trackedPoints
{
    NSMutableArray *points = [NSMutableArray array];
    NSUInteger sum = [self count];
    int steps;
    // Totally, we only need 10 points from the whole database, therefore, we need a step number to filter data if points in database are more than  10.
    if (sum >= 10) {
        steps = floor(sum/10);
    }else{
        steps = 1;
    }
    // Get a point for every "steps" points.
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_point WHERE id - (id / %d) * %d = 0;",steps,steps];
    //FMResultSet *set = [_db executeQuery:@"SELECT * FROM t_point WHERE id - (id / 3) * 3 = 0;"];
    while (set.next) {
        RealPoint *point = [[RealPoint alloc] init];
        point.originalX = [set doubleForColumn:@"xValue"];
        point.originalY = [set doubleForColumn:@"yValue"];
        [points addObject:point];
    }
    return points;
}

+ (RealPoint *) getTheMostUpdatedPoint
{
    return [[RealPoint alloc] init];
}

+ (NSUInteger) count
{
    NSUInteger count = [_db intForQuery:@"SELECT count(*) FROM t_point;"];
    return count;
}

+ (void)addPoint:(RealPoint *)point
{
    [_db executeUpdateWithFormat:@"INSERT INTO t_point(xValue, yValue) VALUES (%f, %f);", point.originalX, point.originalY];
}

+ (void)removeAllPoints
{
    [_db executeUpdateWithFormat:@"DELETE FROM t_point"];
}

@end
