//
//  TestingData.h
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/10/3.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeaconModel.h"

@interface TestingData : NSObject

@property (strong, nonatomic) BeaconModel *beacon;

+ (NSArray *) initTestingData;

@end
