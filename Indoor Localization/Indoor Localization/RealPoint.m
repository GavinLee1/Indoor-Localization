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

#pragma mark -Drawing Track Path
- (void) drawTrackPath: (UIView *) view withPoints: (NSArray *) trackedPoints{
#define grid 40
#define origin_x 0
#define origin_y 80
    int trackedPointsNum = [trackedPoints count];
    
    //int number;
    CGPoint oldlocation;
    
    oldlocation.x = 0;
    oldlocation.y = 0;
    
    int size=0;
    float quan = grid;
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
            shapeLayer.strokeColor = [[UIColor redColor] CGColor];
            shapeLayer.fillColor = [[UIColor redColor] CGColor];
            shapeLayer.lineWidth = 3.0;
            
            [view.layer addSublayer:shapeLayer];
        }
        
        // 如果移动不足 50 像素 <即 1 米>  则不用画出来
        if (fabs((location.x-oldlocation.x)) < quan && fabs((location.y-oldlocation.y)) < quan)
        {
            size = size+1;
            moved = false;
        }
        else
        {   //size=0;
            moved=true;
        }
        
        if(moved==true  && oldlocation.x!=0 && oldlocation.y!=0)
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
            shapeLayer.strokeColor=[[UIColor blueColor]CGColor];// 圆是蓝色的
            shapeLayer.fillColor=[[UIColor blueColor]CGColor];
            shapeLayer.lineWidth=3.0;
            [view.layer addSublayer:shapeLayer];
            // 往前移一个点
            oldlocation.x = location.x;
            oldlocation.y = location.y;
            size = 0;
            
        }
        
    }
}

// 以传入的点和半径 画一个圆，55行和88行 调用两次
-(UIBezierPath *) makeCircleAtLocation:(CGPoint)location radius:(CGFloat) radius
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:location radius:radius startAngle:0.0 endAngle:M_PI*2.0 clockwise:YES];
    
    return path;
}

// 从开始的点到结束的点，画一条线，在第80行调用一次
-(UIBezierPath *)trackLine:(CGPoint)startPoint endPoint:(CGPoint) endPoint
{
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    
    return path;
}

@end
