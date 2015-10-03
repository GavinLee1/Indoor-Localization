//
//  ViewController.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/16.
//  Copyright (c) 2015年 LIGAOZHAO. All rights reserved.
//

#import "ViewController.h"
#import "IndoorLocationViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController () <CBCentralManagerDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;

@end

@implementation ViewController

#pragma mark -Initialization

- (CBCentralManager *) centralManager
{
    if (!_centralManager) {
        _centralManager = [[CBCentralManager alloc] init];
    }
    return _centralManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.centralManager.delegate = self;
    // 1.初始化子控制器
    [self addChildVc:@"MapLocation" title:@"MapLoc" image:@"tabbar_map" selectedImage:@"tabbar_map_selected"];
    [self addChildVc:@"ScanBeacon" title:@"BeData" image:@"tabbar_data" selectedImage:@"tabbar_data_selected"];
    [self addChildVc:@"IndoorLocation" title:@"Indoor" image:@"tabbar_indoor" selectedImage:@"tabbar_indoor_selected"];
    [self addChildVc:@"Profile" title:@"Profile" image:@"tabbar_profile" selectedImage:@"tabbar_profile_selected"];
}

#pragma mark -Add Sub Controller
/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图片
 *  @param selectedImage 选中的图片
 */
- (void)addChildVc:(NSString *)storyboardName title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *childVc = storyboard.instantiateInitialViewController;
    // 设置子控制器的文字
    childVc.title = title; // 同时设置tabbar和navigationBar的文字
    
    // 设置子控制器的图片
    childVc.tabBarItem.image = [UIImage imageNamed:image];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 设置文字的样式
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor colorWithRed:123/255.0 green:123/255.0 blue:123/255.0 alpha:1.0];
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSForegroundColorAttributeName] = [UIColor orangeColor];
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    
    // 添加为子控制器
    [self addChildViewController:childVc];
}

#pragma mark -CBCentralManager Delegate Method
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
}

@end
