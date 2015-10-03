//
//  BeaconInfoCell.h
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/10/2.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <CoreLocation/CoreLocation.h>
#import "BeaconTool.h"
#import "BeaconModel.h"//测试用的，用完删

@interface BeaconInfoCell : UITableViewCell

// @property (strong, nonatomic) CLBeacon *beacon;
@property (strong, nonatomic) BeaconModel *beacon;//测试用的，用完删

+ (instancetype) cellWithTableView: (UITableView *) tableView;

@end
