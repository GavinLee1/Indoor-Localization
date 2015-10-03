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
@property (weak, nonatomic) IBOutlet UIImageView *batteryImageView;

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
    
    float distance = [[[BeaconTool alloc] init] computeDistance:tempRssi];
    
    self.majorLabel.text = [NSString stringWithFormat:@"Major: %@",beacon.major];
    self.minorLabel.text = [NSString stringWithFormat:@"Minor: %@",beacon.minor];
    self.distanceLabel.text = [NSString stringWithFormat:@"Dist: %0.3f",distance];
    self.accuracyLabel.text = [NSString stringWithFormat:@"Accu: %0.2f",(float)beacon.accuracy];
    
    [self.iconButton setTitle:[NSString stringWithFormat:@"%ld",tempRssi] forState:UIControlStateNormal];
    //    CLProximityUnknown,
    //    CLProximityImmediate,
    //    CLProximityNear,
    //    CLProximityFar
    // Set the button's background image according to different proximity value.
    switch (beacon.proximity) {
//            + (UIColor *)blackColor;      // 0.0 white
//            + (UIColor *)darkGrayColor;   // 0.333 white
//            + (UIColor *)lightGrayColor;  // 0.667 white
//            + (UIColor *)whiteColor;      // 1.0 white
//            + (UIColor *)grayColor;       // 0.5 white
//            + (UIColor *)redColor;        // 1.0, 0.0, 0.0 RGB
//            + (UIColor *)greenColor;      // 0.0, 1.0, 0.0 RGB
//            + (UIColor *)blueColor;       // 0.0, 0.0, 1.0 RGB
//            + (UIColor *)cyanColor;       // 0.0, 1.0, 1.0 RGB
//            + (UIColor *)yellowColor;     // 1.0, 1.0, 0.0 RGB
//            + (UIColor *)magentaColor;    // 1.0, 0.0, 1.0 RGB
//            + (UIColor *)orangeColor;     // 1.0, 0.5, 0.0 RGB
//            + (UIColor *)purpleColor;     // 0.5, 0.0, 0.5 RGB 
//            + (UIColor *)brownColor;      // 0.6, 0.4, 0.2 RGB
        case CLProximityUnknown:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconUnknown"] forState:UIControlStateNormal];
            [self.iconButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            self.batteryImageView.image = [UIImage imageNamed:@"batteryLow"];
            break;
        case CLProximityImmediate:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconImmediate"] forState:UIControlStateNormal];
            self.batteryImageView.image = [UIImage imageNamed:@"batteryHigh"];
            break;
        case CLProximityNear:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconNear"] forState:UIControlStateNormal];
            self.batteryImageView.image = [UIImage imageNamed:@"batteryHigh"];
            break;
        case CLProximityFar:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconFar"] forState:UIControlStateNormal];
            [self.iconButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            self.batteryImageView.image = [UIImage imageNamed:@"batteryLow"];
            break;
        default:
            [self.iconButton setBackgroundImage:[UIImage imageNamed:@"beaconIconNear"] forState:UIControlStateNormal];
            self.batteryImageView.image = [UIImage imageNamed:@"batteryHigh"];
            break;
    }
    
}
//***************************************************************************************************//



@end
