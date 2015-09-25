//
//  MapLocationViewController.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/25.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "MapLocationViewController.h"
#import <MapKit/MapKit.h>

@interface MapLocationViewController () <MKMapViewDelegate>
/**
 *  地图
 */
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *mgr;
/**
 *  地理编码对象
 */
@property (nonatomic ,strong) CLGeocoder *geocoder;

@end

@implementation MapLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.mapType = MKMapTypeStandard;
    
    // 注意:在iOS8中, 如果想要追踪用户的位置, 必须自己主动请求隐私权限
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        // 主动请求权限
        self.mgr = [[CLLocationManager alloc] init];
        [self.mgr requestAlwaysAuthorization];
    }
    // 设置不允许地图旋转
    //self.mapView.rotateEnabled = NO;
    // 成为mapVIew的代理
    self.mapView.delegate = self;
    // 如果想利用MapKit获取用户的位置, 可以追踪
    self.mapView.userTrackingMode =  MKUserTrackingModeFollowWithHeading;
    
}
#pragma MKMapViewDelegate
/**
 *  每次更新到用户的位置就会调用(调用不频繁, 只有位置改变才会调用)
 *
 *  @param mapView      促发事件的控件
 *  @param userLocation 大头针模型
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // 利用反地理编码获取位置之后设置标题
    [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks firstObject];
        NSLog(@"获取地理位置成功 name = %@ locality = %@", placemark.name, placemark.locality);
        userLocation.title = placemark.name;
        userLocation.subtitle = placemark.locality;
    }];
    // 设置地图显示的区域
    // 获取用户的位置
    CLLocationCoordinate2D center = userLocation.location.coordinate;
    // 指定经纬度的跨度
    MKCoordinateSpan span = MKCoordinateSpanMake(0.009310,0.007812);
    // 将用户当前的位置作为显示区域的中心点, 并且指定需要显示的跨度范围
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    // 设置显示区域
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - 懒加载
- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
