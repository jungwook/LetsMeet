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
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage* imageLeft, *imageRight;
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
//        UIEdgeInsets capsRight = UIEdgeInsetsMake(14, 10, 14, 14);
//        UIEdgeInsets capsLeft = UIEdgeInsetsMake(14, 14, 14, 10);
//        self.imageRight = [[UIImage imageNamed:@"messageRight"] resizableImageWithCapInsets:capsRight];
//        self.imageLeft = [[UIImage imageNamed:@"messageLeft"] resizableImageWithCapInsets:capsLeft];
        
    }
    return self;
}

- (void)awakeFromNib
{
//    if (!self.imageView) {
//        self.backgroundColor = [UIColor clearColor];
//        self.imageView = [UIImageView new];
//        [self insertSubview:self.imageView atIndex:0];
//    }
}

- (void)setIsMine:(BOOL)isMine
{
    _isMine = isMine;
    
    self.backgroundColor = isMine ?
    [UIColor colorWithRed:100/255.f green:167/255.f blue:229/255.f alpha:1] :
    [UIColor colorWithRed:110/255.f green:200/255.f blue:41/255.f alpha:1];
}

- (void)layoutSubviews
{
    [self setMask];
}

#define CPM(__X__,__Y__) CGPointMake(__X__, __Y__)

- (void) setMask
{
    /*
     __LF
    
    [self.imageView setImage:self.isMine ? self.imageRight : self.imageLeft];
    self.imageView.frame = self.bounds;
    return;
    */
    
    const CGFloat i1 = 5.0f, i2 = 5.0f, i3 = 7.0f;
    CGRect rect = self.frame;
    CAShapeLayer *mask = [CAShapeLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat w = rect.size.width, h=rect.size.height;
    CGFloat l = 0, r = w, t = 0, b = h;
    
    if (self.isMine) {
        [path moveToPoint:CPM(l, i1)];
        [path addQuadCurveToPoint:CPM(i1, t) controlPoint:CPM(l, t)];
        [path addLineToPoint:CPM(r-i1-i2, t)];
        [path addQuadCurveToPoint:CPM(r-i2, i1) controlPoint:CPM(r-i2, t)];
        [path addLineToPoint:CPM(r-i2, i3)];
        [path addLineToPoint:CPM(r, i3)];
        [path addLineToPoint:CPM(r-i2, i3+i2)];
        [path addLineToPoint:CPM(r-i2, b-i1)];
        [path addQuadCurveToPoint:CPM(r-i2-i1, b) controlPoint:CPM(r-i2, b)];
        [path addLineToPoint:CPM(i1, b)];
        [path addQuadCurveToPoint:CPM(l, b-i1) controlPoint:CPM(l, b)];
        [path addLineToPoint:CPM(l, i1)];
    }
    else {
        [path moveToPoint:CPM(l+i2, i1)];
        [path addQuadCurveToPoint:CPM(l+i2+i1, t) controlPoint:CPM(l+i2, t)];
        [path addLineToPoint:CPM(r-i1, t)];
        [path addQuadCurveToPoint:CPM(r, i1) controlPoint:CPM(r, t)];
        [path addLineToPoint:CPM(r, b-i1)];
        [path addQuadCurveToPoint:CPM(r-i1, b) controlPoint:CPM(r, b)];
        [path addLineToPoint:CPM(l+i1+i2, b)];
        [path addQuadCurveToPoint:CPM(l+i2, b-i1) controlPoint:CPM(l+i2, b)];
        [path addLineToPoint:CPM(l+i2, i3+i2)];
        [path addLineToPoint:CPM(l, i3)];
        [path addLineToPoint:CPM(l+i2, i3)];
        [path addLineToPoint:CPM(l+i2, i1)];
    }
    mask.path = path.CGPath;
    self.layer.mask = mask;
}

@end
