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

/**
 *  Be called every 5 senconds in onTicking method.
 *  Designed to move current location UIImageView with calculated location point.
 *
 *  @param point returned RealPoint object from core calculation algorithms.
 */
- (void) moveCurrentLocation: (RealPoint *) point onView:(UIView *) view andImageView:(UIImageView *)imageView;

/**
 *  The function is designed to draw track points and path
 *
 *  @param: the current UIView and the recorded points
 */
- (void) drawTrackPath: (UIView *) view withPoints: (NSArray *) trackedPoints;

/**
 *  Animation for twinkling all the way
 *
 *  @param Time for completing each twinkling cycle
 *
 *  @return CABasicAnimation An basic CABasicAnimation object
 */
-(CABasicAnimation *)opacityForever_Animation:(float)time;

/**
 *  Animation for scaling UI object
 *
 *  @param Multiple is the initil size of the UI object
 *         orginMultiple is the desired biggest size scales to
 *         time for completing each twinkling cycle
 *         repertTimes is the repear times
 *
 *  @return CABasicAnimation An basic CABasicAnimation object
 */
-(CABasicAnimation *)scale:(NSNumber *)Multiple orgin:(NSNumber *)orginMultiple durTimes:(float)time Rep:(float)repertTimes;
@end
