//
//  RealPoint.m
//  Indoor Localization
//
//  Created by LIGAOZHAO on 15/9/28.
//  Copyright © 2015年 LIGAOZHAO. All rights reserved.
//

#import "RealPoint.h"

@implementation RealPoint

@synthesize originalX, originalY;

- (instancetype) initWith: (float) x andY: (float) y
{
    self = [super init];
    if (self) {
        self.originalX = x;
        self.originalY = y;
    }
    return self;
}

#pragma mark -Move to current location
/**
 *  Be called every 5 senconds in onTicking method.
 *  Designed to move current location UIImageView with calculated location point.
 *
 *  @param point returned RealPoint object from core calculation algorithms.
 */
- (void) moveCurrentLocation: (RealPoint *) point onView:(UIView *) view andImageView:(UIImageView *)imageView
{
    // The left up point of the map in the view.
#define origin_x 0
#define origin_y 60
    // 50 pixels for one meter
    // 50 像素代表一米
#define grid 55.1
    
    // UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    // UIImageView *location = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
    // location.image = [UIImage imageNamed:@"current_location"];
    
    // CGRect transferFrame = imageView.frame;
    CGPoint movingCenter = imageView.center;
    
    NSLog(@"Recevied Point Value is: ( %f, %f )",point.originalX, point.originalY);
    
    // transferFrame.origin.x = point.originalX * grid + origin_x;
    // transferFrame.origin.y = point.originalY * grid + origin_y;
    movingCenter.x = point.originalX * grid + origin_x;
    movingCenter.y = point.originalY * grid + origin_y;
    NSLog(@"Location Point Coordinate is : (%f, %f)",movingCenter.x,movingCenter.y);
    //NSLog(@"Location Point Coordinate is: ( %f, %f )",transferFrame.origin.x,transferFrame.origin.y);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2.0];
    //imageView.frame = transferFrame;
    imageView.center = movingCenter;
    [UIView commitAnimations];
    
    // Add animation to make the current point twinkling.
    [imageView.layer addAnimation:[self opacityForever_Animation:0.5f]
                           forKey:nil];
    // 添加缩放的动画
    //[imageView.layer addAnimation:[self scale:[NSNumber numberWithFloat:1.0f] orgin:[NSNumber numberWithFloat:2.0f] durTimes:2.0f Rep:MAXFLOAT] forKey:nil];
    
    [view addSubview:imageView];
    [view bringSubviewToFront:imageView];
}

/**
 *  The function is designed to draw track points and path
 *
 *  @param: the current UIView and the recorded points
 */
#pragma mark -Drawing Track Path
- (void) drawTrackPath: (UIView *) view withPoints: (NSArray *) trackedPoints{
//#define grid 40
//#define origin_x 0
//#define origin_y 80
    int trackedPointsNum = (int)[trackedPoints count];
    
    CGPoint oldlocation;
    
    oldlocation.x = 0;
    oldlocation.y = 0;
    
    int size=0;
    
    //float quan = grid;
    
    Boolean moved = true;
    
    for(int i=0; i < trackedPointsNum; i++){
        // 初始化location
        CGPoint location;
        RealPoint *tempPoint = [[RealPoint alloc] init];
        
        tempPoint = [trackedPoints objectAtIndex:i];
        location.x = tempPoint.originalX * grid + origin_x;
        location.y = tempPoint.originalY * grid + origin_y;
        
        // i=0时，表示起点，将起点直接画出来
        if (i == 0)
        {
            oldlocation.x = location.x;
            oldlocation.y = location.y;
            
            // CAShapeLayer画线或者圆的对象
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = [[self makeCircleAtLocation:location radius:5+size*2] CGPath];
            shapeLayer.strokeColor = [[UIColor orangeColor] CGColor];
            shapeLayer.fillColor = [[UIColor orangeColor] CGColor];
            shapeLayer.lineWidth = 3.0;
            
            [view.layer addSublayer:shapeLayer];
        }
        
        // 如果移动不足 50 像素 <即 1 米>  则不用画出来
//        if (fabs((location.x-oldlocation.x)) < quan && fabs((location.y-oldlocation.y)) < quan)
//        {
//            size = size+1;
//            moved = false;
//        }
//        else
//        {   //size=0;
//            moved=true;
//        }
        
        
        if(moved==true  && oldlocation.x != 0 && oldlocation.y != 0)
        {
            // 从以前的点 往 现在的点 画一条线
            CAShapeLayer *shapeLayer2=[CAShapeLayer layer];
            shapeLayer2.path=[[self trackLine:oldlocation endPoint:location]CGPath];
            shapeLayer2.strokeColor=[[UIColor greenColor]CGColor];// 线是绿色的
            shapeLayer2.lineWidth=2.0;
            
            [view.layer addSublayer:shapeLayer2];
            
            // 在新的位置处画一个圆
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = [[self makeCircleAtLocation:location radius:5+size*2] CGPath];
            shapeLayer.strokeColor=[[UIColor grayColor]CGColor];// 圆是蓝色的
            shapeLayer.fillColor=[[UIColor grayColor]CGColor];
            shapeLayer.lineWidth=3.0;
            [view.layer addSublayer:shapeLayer];
            // 往前移一个点
            oldlocation.x = location.x;
            oldlocation.y = location.y;
            size = 0;
            
        }
        
    }
}

// 以传入的点和半径 画一个圆
-(UIBezierPath *) makeCircleAtLocation:(CGPoint)location radius:(CGFloat) radius
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:location radius:radius startAngle:0.0 endAngle:M_PI*2.0 clockwise:YES];
    
    return path;
}

// 从开始的点到结束的点，画一条线
-(UIBezierPath *)trackLine:(CGPoint)startPoint endPoint:(CGPoint) endPoint
{
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    
    return path;
}

/**
 *  Animation for twinkling all the way
 *
 *  @param Time for completing each twinkling cycle
 *
 *  @return CABasicAnimation An basic CABasicAnimation object
 */
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
#pragma mark =====缩放-=============
-(CABasicAnimation *)scale:(NSNumber *)Multiple orgin:(NSNumber *)orginMultiple durTimes:(float)time Rep:(float)repertTimes
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = Multiple;
    animation.toValue = orginMultiple;
    animation.autoreverses = YES;
    animation.repeatCount = repertTimes;
    animation.duration = time;//不设置时候的话，有一个默认的缩放时间.
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return  animation;
}
@end
