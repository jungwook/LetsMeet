//
//  Hive.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 24..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Hive.h"
#import "AppEngine.h"

@interface Hive()
@property (nonatomic,strong) UILabel *nickname;
@end

@implementation Hive

- (instancetype) init
{
    self = [super init];
    if (self) {
        _centerPoint = CGPointZero;
        _radius = 30.0f;
        _nickname = [UILabel new];
        [_nickname setTextAlignment:NSTextAlignmentCenter];
        
        [self addSubview:self.nickname];
        self.backgroundColor = [UIColor colorWithRed:1.0 green:0.2 blue:0.3 alpha:0.4];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.nickname.frame = self.bounds;
    self.layer.cornerRadius = self.bounds.size.width/2.f;
    self.layer.masksToBounds = YES;
}

- (void) setUser:(PFUser*)user
{
    _user = user;
    self.nickname.text = user[AppKeyNicknameKey];
}

- (void) setCenterPoint:(CGPoint)centerPoint
{
    _centerPoint = centerPoint;
}

- (void)setIncrementsForX:(CGFloat)incX andY:(CGFloat)incY
{
    CGFloat cx = self.centerPoint.x, cy = self.centerPoint.y;
    CGFloat x = cx+incX*self.radius-self.radius/2.0f;
    CGFloat y = cy+incY*self.radius-self.radius/2.0f;
    
    self.frame = CGRectMake(x, y, self.radius, self.radius);
    [self setNeedsLayout];
}

@end
