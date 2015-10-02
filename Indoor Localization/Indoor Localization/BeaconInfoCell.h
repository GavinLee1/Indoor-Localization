//
//  BeaconInfoCell.h
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/10/2.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BeaconTool.h"

@interface BeaconInfoCell : UITableViewCell

@property (strong, nonatomic) CLBeacon *beacon;

+ (instancetype) cellWithTableView: (UITableView *) tableView;

@end
