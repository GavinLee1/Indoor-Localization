//
//  RealPointDataBase.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/28.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "RealPointDataBase.h"


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
    {// 得到结果集
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

+ (RealPoint *) getTheMostUpdatedPoint
{
    return [[RealPoint alloc] init];
}

+ (void)addPoint:(RealPoint *)point
{
    [_db executeUpdateWithFormat:@"INSERT INTO t_point(xValue, yValue) VALUES (%f, %f);", point.originalX, point.originalY];
}

@end
