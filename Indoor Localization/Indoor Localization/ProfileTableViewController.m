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

#import "TestingData.h"

#define UUID @"77777777-7777-7777-7777-777777777777"
#define BeaconRegionIdentifier @"FYP"

@interface ProfileTableViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>



@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;

/**
 *  As a tag for deciding it is a new scanning cycle or not.
 */
@property (assign, nonatomic) NSInteger newCycleTag;

/**
 *  Be used in didRangeBeacons method, as a tag for deciding whether there has the same beacon in array.
 */
@property (assign, nonatomic) NSInteger matchSameBeaconTag;

/**
 *  Store scanned beacons.
 */
@property (strong, nonatomic) NSMutableArray *beaconsStore;

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
    
    // Initialize  the head view fot the table view.
    ProfileTableHeadView *headView = [ProfileTableHeadView headView];
    self.tableView.tableHeaderView = headView;
    
    // Set the separate line of each cell to be graColor
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor grayColor];
    
    // Set the height value for each cell
    self.tableView.rowHeight = 106;
    
    // Set locationManager delegate
    self.locationManager.delegate = self;
    
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    
    // 开始扫描并监听beacons
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    NSLog(@"The region is: %@",self.beaconRegion);
    
    [self.locationManager requestStateForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    self.newCycleTag = 1;
}


- (void) updateTableView
{
    NSLog(@"%s",__func__);
    NSLog(@"-----------------Update One Time----------------");
    
    //[self.locationManager stopUpdatingLocation];
    //[UIView beginAnimations:nil context:nil];
    //[UIView setAnimationDuration:10.0];
    
    [self.tableView reloadData];
    
    /* Animate the table view reload */
//    [UIView transitionWithView: self.tableView
//                      duration: 0.5f
//                       options: UIViewAnimationOptionTransitionCrossDissolve
//                    animations: ^(void)
//     {
//         [self.tableView reloadData];
//     }
//                    completion: ^(BOOL isFinished)
//     {
//         /* TODO: Whatever you want here */
//     }];
}

#pragma mark -TableView DataSource Method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%s",__func__);
    
    int numberOfRows = (int)[self.beaconsStore count];
    
    if (numberOfRows == 0) {
        return 0;
    }
    
    NSLog(@"The number of rows: %d", numberOfRows);
    return numberOfRows;
}

/**
 *  Initialize the cell in table view
 *
 *  @param tableView the current table view, or the table view you want to show.
 *  @param indexPath current index path
 *
 *  @return a table view cell
 */
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
    
    // [self.beaconsStore removeAllObjects];
    
    //**********************************************Testing**********************************************//
    if ([beacons count] < 1) {
        beacons = [TestingData initTestingData];
    }
    //***************************************************************************************************//
    
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
                
                CLProximity tempProximity = tempBeacon.proximity;
                CLLocationAccuracy tempAccu = tempBeacon.accuracy;
                NSNumber *tempMajor = tempBeacon.major;
                NSNumber *tempMinor = tempBeacon.minor;
                NSInteger tempRssi = tempBeacon.rssi;
                
                [tempBeaconModel setProximity:tempProximity];
                [tempBeaconModel setAccuracy:tempAccu];
                [tempBeaconModel setMajor:tempMajor];
                [tempBeaconModel setMinor:tempMinor];
                [tempBeaconModel setRssi:tempRssi];
                [tempBeaconModel setScannedTimes:1];
                
    //**********************************************Logging**********************************************//
                NSLog(@"The becaon information:( Major %@, Minor %@, RSSI %ld )",tempBeacon.major,tempBeacon.minor,tempBeacon.rssi);
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
    //**********************************************Logging**********************************************//
            NSLog(@"-----When sacnned for the second time or more-------");
            NSLog(@"The number of beacons in beaconsStore: %lu",[self.beaconsStore count]);
    //***************************************************************************************************//
            
            for(int i = 0; i < scannedBeaconCount; i++)
            {
                // Initialize the tag for judge the beacon is already there or not.
                self.matchSameBeaconTag = 0;
                
                CLBeacon *tempBeacon=[beacons objectAtIndex:i];
                
                CLProximity tempProximity1 = tempBeacon.proximity;
                CLLocationAccuracy tempAccu1 = tempBeacon.accuracy;
                NSNumber *tempMajor1 = tempBeacon.major;
                NSNumber *tempMinor1 = tempBeacon.minor;
                NSInteger tempRssi1 = tempBeacon.rssi;
                
                // 与已经保存在 beaconAvg 数组里的beacon比较
                for(int j = 0; j < [self.beaconsStore count]; j++)
                {
                    BeaconModel *tempBeaconModel = [self.beaconsStore objectAtIndex:j];
                    
                    NSNumber *tempMinor2 = tempBeaconModel.minor;
                    NSInteger tempRssi2 = tempBeaconModel.rssi;
                    NSInteger tempScannedTimes = tempBeaconModel.scannedTimes;
                    
                    if (tempMinor1 == tempMinor2)
                    {
                        // If finds the same beacons, set the tag as 1
                        self.matchSameBeaconTag = 1;
                        
                        // Add up rssi according to scanned times of the beacon, get the mean RSSI.
                        NSInteger changingRssi = tempRssi2 * tempScannedTimes + tempRssi1;
                        tempScannedTimes += 1;
                        changingRssi = changingRssi / tempScannedTimes;
                        
                        // Reset this beaconModel
                        [tempBeaconModel setProximity:tempProximity1];
                        [tempBeaconModel setAccuracy:tempAccu1];
                        [tempBeaconModel setRssi:changingRssi];
                        [tempBeaconModel setScannedTimes:tempScannedTimes];
                        
                        // Compare whether this beaconModel is nil, if not, renew it
                        if(tempBeaconModel != nil){
                            
                            [self.beaconsStore removeObjectAtIndex:j];
                            
                            [self.beaconsStore insertObject:tempBeaconModel atIndex:j];
                            
                        }
                    }
                }
                // 在第二次循环中，如果没有匹配到，就直接存到数组中，并将其读到的次数置为 1
                if (self.matchSameBeaconTag == 0)
                {
                    BeaconModel *tempBeaconModel;
                    
                    [tempBeaconModel setProximity:tempProximity1];
                    [tempBeaconModel setAccuracy:tempAccu1];
                    [tempBeaconModel setMajor:tempMajor1];
                    [tempBeaconModel setMinor:tempMinor1];
                    [tempBeaconModel setRssi:tempRssi1];
                    [tempBeaconModel setScannedTimes:1];
                    
                    if (tempBeaconModel != nil){
                        [self.beaconsStore addObject:tempBeaconModel];
                    }
                }
            }
        }
        
        self.newCycleTag = 0;
        NSLog(@"newCycleTag = %ld",self.newCycleTag);
    }
    
    // Afer each scanning period, call the updateTabelView method to reload the data in tableView.
    [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0];
    
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
