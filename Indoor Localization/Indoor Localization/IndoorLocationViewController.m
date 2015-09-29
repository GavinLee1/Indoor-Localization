//
//  IndoorLocationViewController.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/25.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "IndoorLocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "BeaconModel.h"
#import "RealPoint.h"
#import "BeaconTool.h"

@interface IndoorLocationViewController () <CLLocationManagerDelegate>

#define UUID @"77777777-7777-7777-7777-777777777777"
#define BeaconRegionIdentifier @"FYP"

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;

@property (strong, nonatomic) BeaconTool *beaconTool;
@property (strong, nonatomic) BeaconModel *beaconModel;

@property (strong, nonatomic) NSMutableArray *beaconsStore;
// 每隔5秒重新扫描出 RSSI 最强的前三个 beacon  每次扫描的时候会
@property (assign, nonatomic) NSInteger newCycleTag;
@property (assign, nonatomic) NSInteger matchSameBeaconTag;
@property (strong, nonatomic) NSTimer *time;
@property (assign, nonatomic) NSInteger tickTimes;

// Use to show operating information on the view
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) UIImageView *location;

// Wait to delete
@property (assign, nonatomic) NSInteger *movedTimes;
// Testing point
@property (strong, nonatomic) RealPoint *point;

- (IBAction)startLocate:(UIButton *)sender;
- (IBAction)track:(UIButton *)sender;
- (IBAction)reset:(UIButton *)sender;


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
// Initialization for motionManager
- (CMMotionManager *) motionManager
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
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

- (IBAction)startLocate:(UIButton *)sender {
    self.infoLabel.text = @"Locate Button Pressed!\n";
    
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    
    // 开始扫描并监听beacons
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    [self.motionManager startAccelerometerUpdates];
    
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
}

- (IBAction)reset:(UIButton *)sender {
    NSLog(@"%s", __func__);
    NSLog(@"Scanning process stop!");
    // self.infoLabel.text = @"Stop scanning!\n";
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
    
    NSArray *transferArray = [self getTopThreeBeacons];
    NSLog(@"Ranked beacons: %@",transferArray);
//    RealPoint *currentLocationPoint = [self.beaconTool computeRealTimePoint:transferArray];
//    NSLog(@"Computed location point: %@",currentLocationPoint);
//    [self moveCurrentLocation:currentLocationPoint];
    
    //********** Testing points **********//
    [self moveCurrentLocation:self.point];
    self.point.originalX += 0.5;
    self.point.originalY += 0.5;
    //***********************************//
    
    // It means that this is a new scanning cycle
    self.newCycleTag = 1;
    // Remove beacons in beaconsStore, which is added into the array in last scanning period.
    [self.beaconsStore removeAllObjects];
    // 每五秒操作一次，执行完这个操作之后就再次进行监听
    [self.locationManager startUpdatingLocation];
}

/**
 *  Be called every 5 senconds in onTicking method.
 *  It is designed to sort the beacon array with RSSI value and get the top three beacons.
 *
 *  @return NSArray records threes beaonModel objects.
 */
- (NSArray *) getTopThreeBeacons
{
    NSArray *sortedBeacons = [[NSArray alloc]init];
    NSMutableArray *tempBeacons = [NSMutableArray array];
    
    // 当beaconAvg数组中记录的数据大于3条时
    // 只有当其中存储的beacon信息超过3个时才说明 beacon以及准备好来定位，如果不足三个，就返回not ready
    NSLog(@"BeaconStore Info: %@",[self.beaconsStore description]);
    
    if([self.beaconsStore count] >= 3 )
    {
        // get beacons array with ascending rssi
        // rssi按降序排列
        NSSortDescriptor *sortDescriptor1=[[NSSortDescriptor alloc] initWithKey:@"rssi" ascending:NO];
        // major按升序排列
        NSSortDescriptor *sortDescriptor2=[[NSSortDescriptor alloc] initWithKey:@"minor" ascending:YES];
        // 根据前两个条件对 beaconAvg数组里的元素进行排序
        sortedBeacons = [self.beaconsStore sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil]];
        // 取出RSSI最强烈的前三条用于定位
        for (int i = 0; i < 3; i++)
        {
            BeaconModel *tempBeacon = [sortedBeacons objectAtIndex:i];
            [tempBeacons addObject:tempBeacon];
        }
    }
    else{
        NSLog(@"The number of beacons for localization is less than 3!");
    }
    
    return tempBeacons;
}

/**
 *  Be called every 5 senconds in onTicking method.
 *  Designed to move current location UIImageView with calculated location point.
 *
 *  @param point returned RealPoint object from core calculation algorithms.
 */
- (void) moveCurrentLocation: (RealPoint *) point
{
    // Wait to delete
    self.infoLabel.text = [NSString stringWithFormat:@"Moved for %ld times.",self.movedTimes];
    self.movedTimes++;
    
    // The left up point of the map in the view.
#define origin_x 0
#define origin_y 80
    // 50 pixels for one meter
    // 50 像素代表一米
#define grid 40
    // UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    // UIImageView *location = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
    // location.image = [UIImage imageNamed:@"current_location"];
    
    CGRect transferFrame = self.location.frame;
    
    NSLog(@"Recevied Point Value is:%@",point);
    transferFrame.origin.x = point.originalX * grid + origin_x;
    transferFrame.origin.y = point.originalY * grid + origin_y;
    NSLog(@"Location Point Coordinate is: ( %f, %f )",transferFrame.origin.x,transferFrame.origin.y);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:4.0];
    self.location.frame = transferFrame;
    [UIView commitAnimations];
    
    // Add animation to make the current point twinkling.
    [self.location.layer addAnimation:[self opacityForever_Animation:0.3] forKey:nil];
    [self.view addSubview:self.location];
    [self.view bringSubviewToFront:self.location];
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

#pragma mark === 永久闪烁的动画 ======
-(CABasicAnimation *)opacityForever_Animation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    //没有的话是均匀的动画
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return animation;
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
