//
//  IndoorLocationViewController.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/25.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "IndoorLocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "BeaconModel.h"
#import "RealPoint.h"
#import "BeaconTool.h"
#import "RealPointDataBase.h"

@interface IndoorLocationViewController () <CLLocationManagerDelegate>

#define UUID @"77777777-7777-7777-7777-777777777777"
#define BeaconRegionIdentifier @"FYP"

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;

@property (strong, nonatomic) BeaconTool *beaconTool;
@property (strong, nonatomic) BeaconModel *beaconModel;

@property (strong, nonatomic) NSMutableArray *beaconsStore;
@property (strong, nonatomic) UIImageView *location;

// 每隔5秒重新扫描出 RSSI 最强的前三个 beacon  每次扫描的时候会
@property (assign, nonatomic) NSInteger newCycleTag;
@property (assign, nonatomic) NSInteger matchSameBeaconTag;
@property (strong, nonatomic) NSTimer *time;
@property (assign, nonatomic) NSInteger tickTimes;

// Use to show operating information on the view
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

// Testing point
@property (strong, nonatomic) RealPoint *point;

- (IBAction)startLocate:(UIButton *)sender;
- (IBAction)track:(UIButton *)sender;
- (IBAction)clear:(UIButton *)sender;
- (IBAction)stop:(UIButton *)sender;


@end

@implementation IndoorLocationViewController

#pragma mark -Initialization
// Initialization for beaconsStore
- (NSMutableArray *) beaconsStore
{
    if (!_beaconsStore) {
        _beaconsStore = [[NSMutableArray alloc] init];
    }
    return _beaconsStore;
}
// Initialization for locationManager
- (CLLocationManager *) locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return  _locationManager;
}
// Initialization for beaconRegion
- (CLBeaconRegion *) beaconRegion
{
    if (!_beaconRegion) {
        NSUUID *beaconUUID =[[NSUUID alloc]initWithUUIDString:UUID];
        NSString *beaconIdentifier = BeaconRegionIdentifier;
        _beaconRegion = [[CLBeaconRegion alloc]initWithProximityUUID:beaconUUID identifier:beaconIdentifier];
    }
    return _beaconRegion;
}
// Initialization for beconTool
- (BeaconTool *) beaconTool
{
    if (!_beaconTool) {
        _beaconTool = [[BeaconTool alloc] init];
    }
    return _beaconTool;
}
// Initialization for UIImageView <show current location>
- (UIImageView *) location
{
    if (!_location) {
        _location = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
        _location.image = [UIImage imageNamed:@"current_location"];
    }
    return _location;
}
// Initialization for testing point
- (RealPoint *) point
{
    if (!_point) {
        _point = [[RealPoint alloc] initWith:0.5 andY:0.5];
    }
    return _point;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Set locationManager delegate
    self.locationManager.delegate=self;
}

#pragma mark -Functional Buttons
- (IBAction)startLocate:(UIButton *)sender {
    self.infoLabel.text = @"Locate Button Pressed!\n";
    
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    
    // 开始扫描并监听beacons
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    NSLog(@"The region is: %@",self.beaconRegion);
    
    [self.locationManager requestStateForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    [self.time invalidate];
    self.time = nil;
    self.newCycleTag = 1;
    
    // 每隔 5 秒调用一次 onTick 方法
    self.time = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onTicking:) userInfo:nil repeats:YES];
}

- (IBAction)track:(UIButton *)sender {
    NSArray *trackedPoints = [RealPointDataBase trackedPoints];
    [self.point drawTrackPath:self.view withPoints:trackedPoints];
}



- (IBAction)clear:(UIButton *)sender {
    self.infoLabel.text = @"Cleared all data in database!\n";
    // Remove "location" UIImageView
    [self.location removeFromSuperview];
    //[self.circleLayer removeFromSuperlayer];
//    while (self.circleLayer) {
//        [self.circleLayer removeFromSuperlayer];
//        //[self.lineLayer removeFromSuperlayer];
//    }
    
    // Delete all points in the dataBase
    [RealPointDataBase removeAllPoints];
    // 停止时钟并重置
    [self.time invalidate];
    self.time = nil;
    // 关闭monitor 关闭扫描的region
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
}

- (IBAction)stop:(UIButton *)sender {
    NSLog(@"%s", __func__);
    NSLog(@"Scanning process stop!");
    self.infoLabel.text = @"Stop scanning! Press Locate to restart!\n";
    // 停止时钟并重置
    [self.time invalidate];
    self.time = nil;
    // 关闭monitor 关闭扫描的region
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
}

# pragma mark -Timer
// At the end of 5 seconds, extract avg rssi, major, minor
-(void)onTicking:(NSTimer *) timer {
    NSLog(@"%s", __func__);
    NSLog(@"------On Ticking------");
    self.tickTimes++;
    
    // 5秒到了之后就打断一次扫描
    [self.locationManager stopUpdatingLocation];
    
    NSArray *transferArray = [self.beaconTool getTopThreeBeacons:self.beaconsStore];
    NSLog(@"Ranked beacons: %@",transferArray);
//    RealPoint *currentLocationPoint = [self.beaconTool computeRealTimePoint:transferArray];
//    NSLog(@"Computed location point: %@",currentLocationPoint);
//    [self.point moveCurrentLocation:currentLocationPoint onView:self.view andImageView:self.location];
    
    //********** Testing points **********//
    [self.point moveCurrentLocation:self.point onView:self.view andImageView:self.location];
    self.point.originalX += 0.5;
    self.point.originalY += 0.5;
    //***********************************//
    
    // Insert the showing point into the database.
    [RealPointDataBase addPoint:self.point];
    
    //************ For testing **********//
    NSArray *points = [[NSArray alloc] init];
    points = [RealPointDataBase points];
    for (RealPoint *point in points) {
        NSLog(@"----------The point infor: %f, %f",point.originalX,point.originalY);
    }
    //***********************************//
    
    // It means that this is a new scanning cycle
    self.newCycleTag = 1;
    // Remove beacons in beaconsStore, which is added into the array in last scanning period.
    [self.beaconsStore removeAllObjects];
    // 每五秒操作一次，执行完这个操作之后就再次进行监听
    [self.locationManager startUpdatingLocation];
}

# pragma mark -CLLocationManagerDelegate
/**
 ** Calling when start monitoring successfully and it will be called automatically.
 **
 **/
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    self.infoLabel.text = @"Scanning...........!\n";
    NSLog(@"%s",__func__);
    // scannedBeaconCount: the number of beacons scanned.
    NSInteger scannedBeaconCount = [beacons count];
    NSLog(@"The number of scanned beacons:%ld",[beacons count]);
    // 扫描到beacon 并把它们存到数组里面
    // Filter out the 0dBm RSSI beacons and store in tempBeacon0
    if (scannedBeaconCount > 1)
    {
        NSLog(@"newCyscleTag = %ld",self.newCycleTag);
        // Every first time, just initialize the beacon model and add it into the array.
        if (self.newCycleTag == 1)
        {
            // At the first scanning cycle.
            // If scanned beacons are not empty, copy data from beacons to beaconsStore.
            for (int i = 0; i < scannedBeaconCount; i++)
            {
                BeaconModel *tempBeaconModel = [[BeaconModel alloc] init];
                
                CLBeacon *tempBeacon = [beacons objectAtIndex:i];
                
                NSInteger tempMajor = tempBeacon.major.integerValue;
                NSInteger tempMinor = tempBeacon.minor.integerValue;
                NSInteger tempRssi = tempBeacon.rssi;
                
                [tempBeaconModel setMajor:tempMajor];
                [tempBeaconModel setMinor:tempMinor];
                [tempBeaconModel setRssi:tempRssi];
                [tempBeaconModel setScannedTimes:1];
                NSLog(@"The becaon information:%@",[tempBeacon description]);
                [self.beaconsStore addObject:tempBeaconModel];
                NSLog(@"The becaonStore information:%@",[self.beaconsStore description]);
            }
        }else
        {
            // 如果不是第一次循环
            // 匹配是否重复扫描，如果当前扫描到的beacon有被扫描到过，就把被扫描的次数+1
            // 把  beacons 数组里的beacons都拿出来比较一下
            // In order to not store a same beacon for twice, when scan for more than second time, will compare it with beacons exist in beaconStore, if it already here, just add its scanned time instead of add it into the array.
            NSLog(@"-----When sacnned for the second time or more-------");
            for(int i = 0; i < scannedBeaconCount; i++)
            {
                // Initialize the tag for judge the beacon is already there or not.
                self.matchSameBeaconTag = 0;
                
                CLBeacon *tempBeacon=[beacons objectAtIndex:i];
                
                NSInteger tempMajor1 = tempBeacon.major.integerValue;
                NSInteger tempMinor1 = tempBeacon.minor.integerValue;
                NSInteger tempRssi1 = tempBeacon.rssi;
                
                // 与已经保存在 beaconAvg 数组里的beacon比较
                NSLog(@"%lu",[self.beaconsStore count]);
                
                for(int j = 0; j < [self.beaconsStore count]; j++)
                {
                    BeaconModel *tempBeaconModel = [self.beaconsStore objectAtIndex:j];
                    
                    NSInteger tempMinor2 = tempBeaconModel.minor;
                    NSInteger tempRssi2 = tempBeaconModel.rssi;
                    NSInteger tempScannedTimes = tempBeaconModel.scannedTimes;
                    
                    if (tempMinor1 == tempMinor2)
                    {
                        // If finds the same beacons, set the tag as 1
                        self.matchSameBeaconTag = 1;
                        
                        // Add up rssi according to scanned times of the beacon
                        NSInteger changingRssi = tempRssi2 * tempScannedTimes + tempRssi1;
                        tempScannedTimes += 1;
                        changingRssi = changingRssi / tempScannedTimes;
                        
                        // Reset this beaconModel
                        [tempBeaconModel setRssi:changingRssi];
                        [tempBeaconModel setScannedTimes:tempScannedTimes];
                        
                        // Compare whether this beaconModel is nil, if not, renew it
                        if(tempBeaconModel!=nil){
                            [self.beaconsStore removeObjectAtIndex:j];
                            [self.beaconsStore insertObject:tempBeaconModel atIndex:j];
                        }
                    }
                }
                // 在第二次循环中，如果没有匹配到，就直接存到数组中，并将其读到的次数置为 1
                if (self.matchSameBeaconTag == 0)
                {
                    BeaconModel *tempBeaconModel;
                    [tempBeaconModel setMajor:tempMajor1];
                    [tempBeaconModel setMinor:tempMinor1];
                    [tempBeaconModel setRssi:tempRssi1];
                    [tempBeaconModel setScannedTimes:1];
                    
                    if (tempBeaconModel!=nil){
                        [self.beaconsStore addObject:tempBeaconModel];
                    }
                }
            }
        }
        
        self.newCycleTag = 0;
        NSLog(@"newCycleTag = %ld",self.newCycleTag);
    }
}

-(void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Failed monitoring region: %@",error);
    // self.infoLabel.text = [NSString stringWithFormat:@"Monitor Fail with %@\n",error];
    
    NSLog(@"monitoringDidFailForRegion %@ %@",region, error.localizedDescription);
    NSInteger regionNum = [self.locationManager monitoredRegions].count;
    NSLog(@"The number of regions:%ld", regionNum);
    for (CLRegion *monitoredRegion in manager.monitoredRegions) {
        NSLog(@"Get Monitored Regions: %@", monitoredRegion);
    }
    if ((error.domain != kCLErrorDomain || error.code != 5) &&
        [manager.monitoredRegions containsObject:region]) {
        NSString *message = [NSString stringWithFormat:@"%@ %@",
                             region, error.localizedDescription];
        NSLog(@"%@",message);
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed: %@", error);
    // self.infoLabel.text = [NSString stringWithFormat:@"Fail with %@\n",error];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSLog(@"Enter region");
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager startUpdatingLocation];
    // self.infoLabel.text = @"Enter region";
}

# pragma mark -Heading
// Just monitor the heading of the iPhone to the north, not with beacons
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    CGFloat angle = newHeading.magneticHeading * M_PI / 180;
    self.location.transform = CGAffineTransformIdentity;
    self.location.transform = CGAffineTransformMakeRotation( -angle);
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
