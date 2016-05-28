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
#import "PFUser+Attributes.h"

@interface Hive()
@property (nonatomic, strong) PFUser* user;
@property (nonatomic, strong) UILabel* nickname;
@property (nonatomic, weak) UIScrollView* view;
@end

@implementation Hive

+ hiveWithRadius:(CGFloat)radius
{
    return [[Hive alloc] initWithRadius:radius];
}

- (instancetype) initWithRadius:(CGFloat)radius
{
    self = [self init];
    if (self) {
        _radius = radius;
    }
    return self;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _nickname = [UILabel new];
        [_nickname setTextAlignment:NSTextAlignmentCenter];
        [_nickname setFont:[UIFont systemFontOfSize:8 weight:UIFontWeightSemibold]];
        
        [self addSubview:self.nickname];
        self.backgroundColor = [UIColor colorWithRed:1.0 green:0.2 blue:0.3 alpha:0.4];
    }
    return self;
}

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
    
/*
    const CGPoint points2[] = {
        CGPointMake(436,36),
        CGPointMake(563,36),
        CGPointMake(936,252),
        CGPointMake(1000,361),
        CGPointMake(1000,792),
        CGPointMake(936,902),
        CGPointMake(563,1118),
        CGPointMake(436,1118),
        CGPointMake(63,902),
        CGPointMake(0,792),
        CGPointMake(0,361),
        CGPointMake(63, 252),
        CGPointMake(436,36),
        CGPointMake(563,36),
        };
 */
    
    const CGPoint points[] = {
        CGPointMake(390,63),
        CGPointMake(609,63),
        CGPointMake(890,225),
        CGPointMake(1000,415),
        CGPointMake(1000,739),
        CGPointMake(890,929),
        CGPointMake(609,1091),
        CGPointMake(390,1091),
        CGPointMake(109,929),
        CGPointMake(0,739),
        CGPointMake(0,415),
        CGPointMake(109, 225),
        CGPointMake(390,63),
        CGPointMake(609,63),
    };
    const CGPoint anchor[] = {
        CGPointMake(500,0),
        CGPointMake(1000,288),
        CGPointMake(1000,866),
        CGPointMake(500,1154),
        CGPointMake(0,866),
        CGPointMake(0,288),
        CGPointMake(500,0),
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
    [super layoutSubviews];
    [self setMask];
}

- (void) drawImage:(UIImage *)image
{
    [self.layer setContents:(id)image.CGImage];
}

CGPoint hiveToCoord(CGPoint hive)
{
    const int offx[] = { 1, -1, -2, -1, 1, 2};
    const int offy[] = { 1, 1, 0, -1, -1, 0};
    
    int level = hive.x;
    int quad = hive.y;
    
    int sx = level, sy = -level;
    
    for (int i=0; i<quad; i++) {
        int side = (int) i / (level);
        int ox = offx[side];
        int oy = offy[side];
        
        sx += ox;
        sy += oy;
    }
    
    return CGPointMake(sx, sy);
}

- (void) addHiveToView:(Hive*)hive
{
    PFUser *user = hive.user;
    CGPoint coord = hiveToCoord(user.coords);
    
    const CGFloat f = 1.8;
    const CGFloat f2 = f*1.154;
    CGSize size = self.view.contentSize;
    
    CGFloat radius = self.radius;
    CGPoint centerPoint = CGPointMake(size.width/2, size.height/2);
    CGFloat cx = centerPoint.x, cy = centerPoint.y;
    CGFloat x = cx+(coord.x-0.5f)*radius;
    CGFloat y = cy+(coord.y-0.5f)*radius*1.5*1.154;
    hive.frame = CGRectMake(x, y, f*radius, f2*radius);
    
    [self.view addSubview:hive];
}

- (void) setUser:(PFUser*)user superview:(UIScrollView*)view
{
    _user = user;
    _view = view;
    
    self.nickname.text = user[AppKeyNicknameKey];
    
     bool sex = [self.user[AppKeySexKey] boolValue];
    drawImage([UIImage imageNamed:sex ? @"guy" : @"girl"], self); //SET DEFAULT PICTURE FOR NOW...
    [CachedFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        UIImage *profilePhoto = [UIImage imageWithData:data];
        [self drawImage:profilePhoto];
        [self setNeedsLayout];
    } fromFile:user[AppProfilePhotoField]];
    
    [self addHiveToView:self];
}

@end
