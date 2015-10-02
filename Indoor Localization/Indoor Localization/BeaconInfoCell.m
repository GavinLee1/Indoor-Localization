//
//  BeaconInfoCell.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/10/2.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "BeaconInfoCell.h"

@interface BeaconInfoCell ()

@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;

@end

@implementation BeaconInfoCell

/**
 *  Initialize the cell inside the table view.
 *
 *  @param tableView parent table view
 *
 *  @return cell object
 */
+ (instancetype) cellWithTableView: (UITableView *) tableView
{
    static NSString *ID = @"Cell";
    BeaconInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        // 注意可重用标示符需要在XIB中指定
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BeaconInfoCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

/*- (void) setBeacon:(CLBeacon *)beacon
{
    _beacon = beacon;
    NSInteger tempRssi = beacon.rssi;
    
    NSInteger distance = [[[BeaconTool alloc] init] computeDistance:tempRssi];
    
    self.majorLabel.text = [NSString stringWithFormat:@"Major: %@",beacon.major];
    self.minorLabel.text = [NSString stringWithFormat:@"Minor: %@",beacon.minor];
    self.distanceLabel.text = [NSString stringWithFormat:@"Dist: %ld",distance];
    self.accuracyLabel.text = [NSString stringWithFormat:@"Accu: %f",beacon.accuracy];
    
    [self.iconButton setTitle:[NSString stringWithFormat:@"%ld",tempRssi] forState:UIControlStateNormal];
//    CLProximityUnknown,
//    CLProximityImmediate,
//    CLProximityNear,
//    CLProximityFar
    // Set the button's background image according to different proximity value.
    switch (beacon.proximity) {
        case CLProximityUnknown:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconUnknown"] forState:UIControlStateNormal];
            break;
        case CLProximityImmediate:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconImmediate"] forState:UIControlStateNormal];
            break;
        case CLProximityNear:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconNear"] forState:UIControlStateNormal];
            break;
        case CLProximityFar:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconFar"] forState:UIControlStateNormal];
            break;
        default:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconNormal"] forState:UIControlStateNormal];
            break;
    }
    
}*/
//**********************************************Testing**********************************************//
- (void) setBeacon:(BeaconModel *)beacon
{
    _beacon = beacon;
    NSInteger tempRssi = beacon.rssi;
    
    NSInteger distance = [[[BeaconTool alloc] init] computeDistance:tempRssi];
    
    self.majorLabel.text = [NSString stringWithFormat:@"Major: %ld",beacon.major];
    self.minorLabel.text = [NSString stringWithFormat:@"Minor: %ld",beacon.minor];
    self.distanceLabel.text = [NSString stringWithFormat:@"Dist: %ld",distance];
    self.accuracyLabel.text = [NSString stringWithFormat:@"Accu: %f",beacon.accuracy];
    
    [self.iconButton setTitle:[NSString stringWithFormat:@"%ld",tempRssi] forState:UIControlStateNormal];
    //    CLProximityUnknown,
    //    CLProximityImmediate,
    //    CLProximityNear,
    //    CLProximityFar
    // Set the button's background image according to different proximity value.
    switch (beacon.proximity) {
        case CLProximityUnknown:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconUnknown"] forState:UIControlStateNormal];
            break;
        case CLProximityImmediate:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconImmediate"] forState:UIControlStateNormal];
            break;
        case CLProximityNear:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconNear"] forState:UIControlStateNormal];
            break;
        case CLProximityFar:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconFar"] forState:UIControlStateNormal];
            break;
        default:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconNormal"] forState:UIControlStateNormal];
            break;
    }
    
}
//***************************************************************************************************//



@end
