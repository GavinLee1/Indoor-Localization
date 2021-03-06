//
//  ScanBeaconViewController.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/25.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "ScanBeaconViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "BeaconModel.h"
#import "TestingData.h"

@interface ScanBeaconViewController () <CLLocationManagerDelegate>

#define UUID @"77777777-7777-7777-7777-777777777777"
#define BeaconRegionIdentifier @"FYP"

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;

@property (strong, nonatomic) BeaconModel *beaconModel;

@property (strong, nonatomic) NSMutableArray *beaconsStore;
// 每隔5秒重新扫描出 RSSI 最强的前三个 beacon  每次扫描的时候会
@property (assign, nonatomic) NSInteger newCycleTag;
@property (assign, nonatomic) NSInteger matchSameBeaconTag;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITextView *showDataView;
@property (weak, nonatomic) IBOutlet UIImageView *compassView;

- (IBAction)start:(UIButton *)button;
- (IBAction)stop:(UIButton *)button;

@end

@implementation ScanBeaconViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%s",__func__);
    
    self.infoLabel.text = @"Press 'start' button to begin scan beagons!\n";
    self.showDataView.text = @"Beacons Information:\n";
    
    // Set locationManager delegate
    self.locationManager.delegate=self;
    
    self.newCycleTag = 1;
    
    // Apply for authorization
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        NSLog(@"Current system is upper than ios 8.0");
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingHeading];
}

# pragma mark -Start And Stop Button Event

- (IBAction)start:(UIButton *)button {
    
    // self.locationManager = [[CLLocationManager alloc]init];
    // self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    
    // 开始扫描并监听beacons
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    NSLog(@"The region is: %@",self.beaconRegion);
    
    [self.locationManager requestStateForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    NSLog(@"%s",__func__);
    NSLog(@"Start button pressed!");
    self.infoLabel.text = @"Start scanning!\n";
    self.showDataView.text = @"Beacons Information:\n";
    
    self.newCycleTag = 1;
}

- (IBAction)stop:(UIButton *)button {
    NSLog(@"%s", __func__);
    NSLog(@"Scanning process stop!");
    self.infoLabel.text = @"Stop scanning!\n";
    
    // 关闭monitor 关闭扫描的region
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
}

# pragma mark -Timer
// At the end of 5 seconds, extract avg rssi, major, minor
-(void)tracking{
    NSLog(@"%s", __func__);
    NSLog(@"------------------Tracking------------------");
    
    [self.locationManager stopUpdatingLocation];
    
    self.infoLabel.text = @"Tracking........\n";
    
    //**********************************************Logging**********************************************//
    for (BeaconModel *beacon in self.beaconsStore) {
        NSLog(@"Original Beacon: Major:%@, Minor:%@, RSSI:%i", beacon.major, beacon.minor, beacon.rssi);
    }
    //***************************************************************************************************//
    
    // Will record the ranked beacons.
    NSArray *tempBeacons1 = [[NSArray alloc]init];
    
    // rssi按降序排列
    NSSortDescriptor *sortDescriptor1=[[NSSortDescriptor alloc] initWithKey:@"rssi" ascending:NO];
    // major按升序排列
    NSSortDescriptor *sortDescriptor2=[[NSSortDescriptor alloc] initWithKey:@"minor" ascending:YES];
    // 根据前两个条件对 beaconAvg数组里的元素进行排序
    tempBeacons1 = [self.beaconsStore sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil]];
    
    // Recored the text, shown in showDataView.
    NSMutableString *infor = [[NSMutableString alloc] init];;
    
    // 将排好序的beacon信息输出
    for (BeaconModel *beacon in tempBeacons1)
    {
        NSString *beaconsInfo=[NSString stringWithFormat:@"< Major:%@ -- Minor:%@ > | RSSI:%i  Scanned:%i |\n",beacon.major,beacon.minor,beacon.rssi,beacon.scannedTimes];
        
        //在TextView中以追加的形式显示beacon的信息
        [infor appendString:beaconsInfo];
        NSLog(@"Beacon minor: %i",beacon.minor);
    }
    
    self.showDataView.text = [self.showDataView.text stringByAppendingString:infor];
    
    //**********************************************Logging**********************************************//
    NSLog(@"View Field Text:\n %@",self.showDataView.text);
    //***************************************************************************************************//
    
    if ([tempBeacons1 count] < 1) {
        self.showDataView.text = [self.showDataView.text stringByAppendingString:@"No beacons around!\n"];
    }
    
    // It means that this is a new scanning cycle
    self.newCycleTag = 1;
    
    // Remove beacons in beaconsStore, which is added into the array in the past scanning period.
    [self.beaconsStore removeAllObjects];
    
    // 执行完这个操作之后就再次进行监听
    [self.locationManager startUpdatingLocation];
    
}

# pragma mark -Compass
// Just monitor the heading of the iPhone to the north, not with beacons
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    CGFloat angle = newHeading.magneticHeading * M_PI / 180;
    self.compassView.transform = CGAffineTransformIdentity;
    self.compassView.transform = CGAffineTransformMakeRotation( -angle);
    
}

# pragma mark -CLLocationManagerDelegate
/** 
 ** Calling when start monitoring successfully and it will be called automatically.
 **
 **/
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"%s",__func__);
    
    //**********************************************Testing**********************************************//
    if ([beacons count] < 1) {
        beacons = [TestingData initTestingData];
    }
    //***************************************************************************************************//
    
    
    // scannedBeaconCount: the number of beacons scanned.
    NSInteger scannedBeaconCount = [beacons count];
    
    self.infoLabel.text = @"Scanning......\n";
    NSLog(@"The number of scanned beacons:%i",[beacons count]);
    // 扫描到beacon 并把它们存到数组里面
    // Filter out the 0dBm RSSI beacons and store in tempBeacon0
    if (scannedBeaconCount > 1)
    {
        NSLog(@"newCyscleTag = %i",self.newCycleTag);
        // Every first time, just initialize the beacon model and add it into the array.
        if (self.newCycleTag == 1)
        {
            // At the first scanning cycle.
            // If scanned beacons are not empty, copy data from beacons to beaconsStore.
            for (int i = 0; i < scannedBeaconCount; i++)
            {
                BeaconModel *tempBeaconModel = [[BeaconModel alloc] init];
                
                CLBeacon *tempBeacon = [beacons objectAtIndex:i];
                
                NSNumber *tempMajor = tempBeacon.major;
                NSNumber *tempMinor = tempBeacon.minor;
                NSInteger tempRssi = tempBeacon.rssi;
                
                [tempBeaconModel setMajor:tempMajor];
                [tempBeaconModel setMinor:tempMinor];
                [tempBeaconModel setRssi:tempRssi];
                [tempBeaconModel setScannedTimes:1];
                
    //**********************************************Logging**********************************************//
                NSLog(@"The becaon information:( Major %@, Minor %@, RSSI %i )",tempBeacon.major,tempBeacon.minor,tempBeacon.rssi);
    //***************************************************************************************************//
                
                [self.beaconsStore addObject:tempBeaconModel];
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
                
                NSNumber *tempMajor1 = tempBeacon.major;
                NSNumber *tempMinor1 = tempBeacon.minor;
                NSInteger tempRssi1 = tempBeacon.rssi;
                
                // 与已经保存在 beaconAvg 数组里的beacon比较
                NSLog(@"The number of scanned beacons: %i",[self.beaconsStore count]);
                
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
        NSLog(@"newCycleTag = %i",self.newCycleTag);
    }
    
    [self performSelector:@selector(tracking) withObject:nil afterDelay:0.0f];
}

-(void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Failed monitoring region: %@",error);
    self.infoLabel.text = [NSString stringWithFormat:@"Monitor Fail with %@\n",error];
    
    NSLog(@"monitoringDidFailForRegion %@ %@",region, error.localizedDescription);
    NSInteger regionNum = [self.locationManager monitoredRegions].count;
    NSLog(@"The number of regions:%i", regionNum);
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
    self.infoLabel.text = [NSString stringWithFormat:@"Fail with %@\n",error];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSLog(@"Enter region");
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager startUpdatingLocation];
    self.infoLabel.text = @"Enter region";
}

@end
