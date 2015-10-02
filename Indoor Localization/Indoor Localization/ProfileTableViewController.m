//
//  ProfileViewController.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/25.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "ProfileTableHeadView.h"
#import "BeaconInfoCell.h"
#import "BeaconModel.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#define UUID @"77777777-7777-7777-7777-777777777777"
#define BeaconRegionIdentifier @"FYP"

@interface ProfileTableViewController () <UITableViewDataSource, UITableViewDelegate>



@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;

@property (assign, nonatomic) NSInteger newCycleTag;
@property (assign, nonatomic) NSInteger matchSameBeaconTag;

@property (strong, nonatomic) NSMutableArray *beaconsStore;

//@property (strong, nonatomic) CADisplayLink *timer;
@property (strong, nonatomic) NSTimer *timer;

@end


@implementation ProfileTableViewController

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
        _beaconRegion = [[CLBeaconRegion alloc]initWithProximityUUID:beaconUUID
                                                          identifier:beaconIdentifier];
        _beaconRegion.notifyOnEntry = YES;
        _beaconRegion.notifyOnExit = YES;
    }
    return _beaconRegion;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ProfileTableHeadView *headView = [ProfileTableHeadView headView];
    self.tableView.tableHeaderView = headView;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor grayColor];
    self.tableView.rowHeight = 120;
    
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    
    // 开始扫描并监听beacons
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    NSLog(@"The region is: %@",self.beaconRegion);
    
    [self.locationManager requestStateForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    
    [self.timer invalidate];
    self.timer = nil;
    
//    if(self.timer == nil)
//    {
//        self.timer = [CADisplayLink displayLinkWithTarget:self
//                                                 selector:@selector(updateTableView)];
//        
//        self.timer.frameInterval = 2;
//        
//        [self.timer addToRunLoop: [NSRunLoop currentRunLoop]
//                         forMode:NSDefaultRunLoopMode];
//    }
    // 每隔 5 秒调用一次 onTick 方法
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(updateTableView)
                                               userInfo:nil
                                                repeats:YES];
}


- (void) updateTableView
{
    NSLog(@"%s",__func__);
    [self.locationManager stopUpdatingLocation];
    
    [self.tableView reloadData];
    
    // It means that this is a new scanning cycle
    self.newCycleTag = 1;
    // Remove beacons in beaconsStore, which is added into the array in last scanning period.
    //[self.beaconsStore removeAllObjects];
    // 每五秒操作一次，执行完这个操作之后就再次进行监听
    [self.locationManager startUpdatingLocation];
    
    
    //[self.tableView reloadSections:nil withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark -TableView DataSource Method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%s",__func__);
    //**********************************************Testing**********************************************//
    BeaconModel *beacon0 = [[BeaconModel alloc] init];
    beacon0.major = 0;
    beacon0.minor = 0;
    beacon0.rssi = (-1)*(arc4random()%30 + 50);
    int m = (-1)*(arc4random()%30 + 50);
    beacon0.accuracy = 4.5;
    beacon0.proximity = CLProximityUnknown;
    //    CLProximityUnknown,
    //    CLProximityImmediate,
    //    CLProximityNear,
    //    CLProximityFar
    [self.beaconsStore addObject:beacon0];
    BeaconModel *beacon1 = [[BeaconModel alloc] init];
    beacon1.major = 0;
    beacon1.minor = 1;
    beacon1.accuracy = 7.5;
    beacon1.proximity = CLProximityNear;
    beacon1.rssi = (-1)*(arc4random()%30 + 50);
    [self.beaconsStore addObject:beacon1];
    BeaconModel *beacon2 = [[BeaconModel alloc] init];
    beacon2.major = 0;
    beacon2.minor = 2;
    beacon2.accuracy = 2.5;
    beacon2.proximity = CLProximityNear;
    beacon2.rssi = (-1)*(arc4random()%30 + 50);
    [self.beaconsStore addObject:beacon2];
    BeaconModel *beacon3 = [[BeaconModel alloc] init];
    beacon3.major = 0;
    beacon3.minor = 3;
    beacon3.accuracy = 5.5;
    beacon3.proximity = CLProximityImmediate;
    beacon3.rssi = (-1)*(arc4random()%30 + 50);
    [self.beaconsStore addObject:beacon3];
    //***************************************************************************************************//
    return [self.beaconsStore count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__func__);
    
    BeaconInfoCell *cell = [BeaconInfoCell cellWithTableView:tableView];
    cell.beacon = [self.beaconsStore objectAtIndex:indexPath.row];
    
    return cell;
}

# pragma mark -CLLocationManagerDelegate
/**
 ** Calling when start monitoring successfully and it will be called automatically.
 **
 **/
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"%s",__func__);
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
                
                //**********************************************Logging**********************************************//
                NSLog(@"The becaon information:( Major %ld, Minor %ld, RSSI %ld )",tempBeacon.major,tempBeacon.minor,tempBeacon.rssi);
                //***************************************************************************************************//
                
                [self.beaconsStore addObject:tempBeaconModel];
                // NSLog(@"The becaonStore information:%@",[self.beaconsStore description]);
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
                
                
                NSLog(@"The number of beacons in beaconsStore: %lu",[self.beaconsStore count]);
                // 与已经保存在 beaconAvg 数组里的beacon比较
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

// Beacon Manager did enter the region
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSLog(@"Enter region");
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager startUpdatingLocation];
    // self.infoLabel.text = @"Enter region";
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"You enterned the region.";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

// Beacon Manager did exit the region
- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"You exited the region.";
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end
