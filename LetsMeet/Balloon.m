//
//  Balloon.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Balloon.h"

@interface Balloon()
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

- (void)awakeFromNib
{
}

- (void)setIsMine:(BOOL)isMine
{
    _isMine = isMine;
    
    self.backgroundColor = isMine ?
    [UIColor colorWithRed:100/255.f green:167/255.f blue:229/255.f alpha:1] :
//    [UIColor colorWithRed:110/255.f green:200/255.f blue:41/255.f alpha:1];
    [UIColor colorWithRed:239/255.f green:239/255.f blue:244/255.f alpha:1];
}

- (void)layoutSubviews
{
    [self setMask];
}

#define CPM(__X__,__Y__) CGPointMake(__X__, __Y__)

- (void) setMask
{
    CGRect rect = self.frame;
    CGFloat w = rect.size.width, h=rect.size.height;
    
    CGFloat i = w < 43 ? MIN(w/2.3, 18) : 19, j = 10.0f, k = 13.0f;
    CAShapeLayer *mask = [CAShapeLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat l = 0, r = w, t = 0, b = h;
    
    if (self.isMine) {
        [path moveToPoint:CPM(l, i)];
        [path addQuadCurveToPoint:CPM(i, t) controlPoint:CPM(l, t)];
        [path addLineToPoint:CPM(r-i-j, t)];
        [path addQuadCurveToPoint:CPM(r-j, i) controlPoint:CPM(r-j, t)];
        [path addLineToPoint:CPM(r-j, b-j)];
        [path addQuadCurveToPoint:CPM(r, b) controlPoint:CPM(r-j, b)];
        [path addQuadCurveToPoint:CPM(r-k, b-j/2) controlPoint:CPM(r-k, b)];
        [path addQuadCurveToPoint:CPM(r-k-k, b) controlPoint:CPM(r-k, b)];
        [path addLineToPoint:CPM(l+i, b)];
        [path addQuadCurveToPoint:CPM(l, b-i) controlPoint:CPM(l, b)];
        [path addLineToPoint:CPM(l, i)];
    }
    else {
        [path moveToPoint:CPM(l+j, i)];
        [path addQuadCurveToPoint:CPM(l+i+j, t) controlPoint:CPM(l+j, t)];
        [path addLineToPoint:CPM(r-i, t)];
        [path addQuadCurveToPoint:CPM(r, i) controlPoint:CPM(r, t)];
        [path addLineToPoint:CPM(r, b-i)];
        [path addQuadCurveToPoint:CPM(r-i, b) controlPoint:CPM(r, b)];
        [path addLineToPoint:CPM(l+k+k, b)];
        [path addQuadCurveToPoint:CPM(l+k, b-j/2) controlPoint:CPM(l+k, b)];
        [path addQuadCurveToPoint:CPM(l, b) controlPoint:CPM(l+k, b)];
        [path addQuadCurveToPoint:CPM(l+j, b-j) controlPoint:CPM(l+j, b)];
        [path addLineToPoint:CPM(l+j, i)];
    }
    mask.path = path.CGPath;
    self.layer.mask = mask;
}

@end
