//
//  Hive.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 24..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Hive.h"
#import "AppEngine.h"
#import "CachedFile.h"

@interface Hive()
@property (nonatomic,strong) UILabel *nickname;
@end

@implementation Hive

- (instancetype) init
{
    self = [super init];
    if (self) {
        _nickname = [UILabel new];
        [_nickname setTextAlignment:NSTextAlignmentCenter];
        [_nickname setFont:[UIFont systemFontOfSize:12 weight:UIFontWeightSemibold]];
        
        [self addSubview:self.nickname];
        self.backgroundColor = [UIColor colorWithRed:1.0 green:0.2 blue:0.3 alpha:0.4];
    }
    return self;
}

#define PT(__x,__y) CGPointMake(__x, __y)

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void) setMask
{
    CGRect rect = self.frame;
    
    CAShapeLayer *hexagonMask = [CAShapeLayer layer];
    CAShapeLayer *hexagonBorder = [CAShapeLayer layer];
    hexagonBorder.frame = self.layer.bounds;
    UIBezierPath *hexagonPath = [UIBezierPath bezierPath];
    
    CGFloat w = rect.size.width, h=rect.size.height;
    
    CGFloat dx = w/1000;
    CGFloat dy = h/1154;
    
    const CGPoint points2[] = {
        PT(436,36),
        PT(563,36),
        PT(936,252),
        PT(1000,361),
        PT(1000,792),
        PT(936,902),
        PT(563,1118),
        PT(436,1118),
        PT(63,902),
        PT(0,792),
        PT(0,361),
        PT(63, 252),
        PT(436,36),
        PT(563,36),
        };
    const CGPoint points[] = {
        PT(390,63),
        PT(609,63),
        PT(890,225),
        PT(1000,415),
        PT(1000,739),
        PT(890,929),
        PT(609,1091),
        PT(390,1091),
        PT(109,929),
        PT(0,739),
        PT(0,415),
        PT(109, 225),
        PT(390,63),
        PT(609,63),
    };
    const CGPoint anchor[] = {
        PT(500,0),
        PT(1000,288),
        PT(1000,866),
        PT(500,1154),
        PT(0,866),
        PT(0,288),
        PT(500,0),
    };
    
    for (int i=0; i<sizeof(points)/sizeof(CGPoint); i=i+2) {
        if (i==0) {
            [hexagonPath moveToPoint:CGPointMake(points[i].x*dx, points[i].y*dy)];
        } else {
            [hexagonPath addLineToPoint:CGPointMake(points[i].x*dx, points[i].y*dy)];
        }
        [hexagonPath addQuadCurveToPoint:CGPointMake(points[i+1].x*dx, points[i+1].y*dy) controlPoint:CGPointMake(anchor[i/2].x*dx, anchor[i/2].y*dy)];
    }
    
    hexagonMask.path = hexagonPath.CGPath;
    hexagonBorder.path = hexagonPath.CGPath;
    hexagonBorder.fillColor = [UIColor clearColor].CGColor;
    hexagonBorder.strokeColor = [UIColor blackColor].CGColor;
    hexagonBorder.lineWidth = 2;
    self.layer.mask = hexagonMask;
    [self.layer addSublayer:hexagonBorder];
    [self setContentMode:UIViewContentModeScaleAspectFill];
    self.nickname.frame = self.bounds;
}

- (void) layoutSubviews
{
//    NSLog(@"LAYOUT");
    [super layoutSubviews];
    [self setMask];
}

- (void) drawImage:(UIImage *)image
{
    [self.layer setContents:(id)image.CGImage];
}

- (void) setUser:(PFUser*)user
{
    _user = user;
    self.nickname.text = user[AppKeyNicknameKey];
    
    bool sex = [self.user[AppKeySexKey] boolValue];
    drawImage([UIImage imageNamed:sex ? @"guy" : @"girl"], self); //SET DEFAULT PICTURE FOR NOW...
    [CachedFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        UIImage *profilePhoto = [UIImage imageWithData:data];
        [self drawImage:profilePhoto];
        [self setNeedsLayout];
    } fromFile:user[AppProfilePhotoField]];
    [self setNeedsLayout];
}

@end
