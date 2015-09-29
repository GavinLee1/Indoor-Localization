//
//  RealPoint.h
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/28.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface RealPoint : NSObject

@property (assign, nonatomic) float originalX;
@property (assign, nonatomic) float originalY;

- (instancetype) initWith: (float) x andY: (float) y;

- (void) drawTrackPath: (UIView *) view withPoints: (NSArray *) trackedPoints;

- (void) moveCurrentLocation: (RealPoint *) point onView:(UIView *) view andImageView:(UIImageView *)imageView;

#pragma mark === 永久闪烁的动画 ======
-(CABasicAnimation *)opacityForever_Animation:(float)time;
#pragma mark =====缩放-=============
-(CABasicAnimation *)scale:(NSNumber *)Multiple orgin:(NSNumber *)orginMultiple durTimes:(float)time Rep:(float)repertTimes;
@end
