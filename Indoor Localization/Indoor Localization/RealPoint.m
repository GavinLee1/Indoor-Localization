//
//  RealPoint.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/28.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "RealPoint.h"

@implementation RealPoint

@synthesize originalX, originalY;

- (instancetype) initWith: (float) x andY: (float) y
{
    self = [super init];
    if (self) {
        self.originalX = x;
        self.originalY = y;
    }
    return self;
}

@end
