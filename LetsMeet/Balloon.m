//
//  Balloon.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Balloon.h"

@interface Balloon()
@property (nonatomic, strong) UIFont *font;

@end

@implementation Balloon

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)setIsMine:(BOOL)isMine
{
    _isMine = isMine;
}

- (void)layoutSubviews
{
    [self setMask];
}

- (void) setMask
{
    const CGFloat is = 10, inset = is / 2;
    CGRect rect = self.frame;
    CAShapeLayer *hexagonMask = [CAShapeLayer layer];
    UIBezierPath *hexagonPath = [UIBezierPath bezierPath];
    CGFloat w = rect.size.width, h=rect.size.height;
    
    const CGPoint points[] = {
        CGPointMake(0,is),
        CGPointMake(is,0),
        CGPointMake(w-is,0),
        CGPointMake(w,is),
        CGPointMake(w,h-is),
        CGPointMake(self.isMine ? w+is : w-is,h),
        CGPointMake(self.isMine ? is : -is ,h),
        CGPointMake(0,h-is),
        CGPointMake(0,is),
        CGPointMake(is,0)
    };
    const CGPoint anchor[] = {
        CGPointMake(0,0),
        CGPointMake(w,0),
        CGPointMake(w,h),
        CGPointMake(0,h),
        CGPointMake(0,0),
    };
    
    for (int i=0; i<sizeof(points)/sizeof(CGPoint); i=i+2) {
        if (i==0) {
            [hexagonPath moveToPoint:CGPointMake(points[i].x, points[i].y)];
        } else {
            [hexagonPath addLineToPoint:CGPointMake(points[i].x, points[i].y)];
        }
        [hexagonPath addQuadCurveToPoint:CGPointMake(points[i+1].x, points[i+1].y) controlPoint:CGPointMake(anchor[i/2].x, anchor[i/2].y)];
    }
    
    hexagonMask.path = hexagonPath.CGPath;
    self.layer.mask = hexagonMask;
}

@end
