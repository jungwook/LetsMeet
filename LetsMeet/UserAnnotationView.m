//
//  UserAnnotationView.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 2..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserAnnotationView.h"

@implementation UserAnnotation

- (id)initWithLocation:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
    }
    return self;
}

@end

@implementation UserAnnotationView

- (CAAnimationGroup*) blowAnimations
{
    const CGFloat sf = 4;
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.beginTime = 0.35;
    scale.fromValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
    scale.toValue = [NSValue valueWithCGSize:CGSizeMake(sf, sf)];
    scale.duration = 2.0f;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.beginTime = 0.35;
    fade.fromValue = @(1);
    fade.toValue = @(0);
    fade.duration = 2.0f;
    fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *anim = [CAAnimationGroup new];
    anim.animations = @[scale, fade];
    anim.beginTime = 0;
    anim.duration = 4;
    anim.repeatCount = FLT_MAX;
    
    return anim;
}

- (CAAnimationGroup*) photoAnimations
{
    const CGFloat sf = 0.95;
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
    scale.toValue = [NSValue valueWithCGSize:CGSizeMake(sf, sf)];
    scale.duration = 0.25f;
    scale.autoreverses = YES;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *anim = [CAAnimationGroup new];
    anim.animations = @[scale];
    anim.beginTime = 0;
    anim.duration = 4;
    anim.repeatCount = FLT_MAX;
    
    return anim;
}

- (void)setDragState:(MKAnnotationViewDragState)dragState animated:(BOOL)animated
{
    const CGFloat x = self.frame.origin.x, y = self.frame.origin.y, w = self.frame.size.width, h = self.frame.size.height, o = 5;
    
    if (dragState == MKAnnotationViewDragStateStarting) {
        [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.alpha = 0.8;
            self.frame = CGRectMake(x, y-o, w, h);
        } completion:^(BOOL finished) {
            self.dragState = MKAnnotationViewDragStateDragging;
        }];
    } else if (dragState == MKAnnotationViewDragStateCanceling || dragState == MKAnnotationViewDragStateEnding) {
        [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.dragState = MKAnnotationViewDragStateNone;
        }];
    }
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        UserAnnotation *anno = annotation;
        
        const CGFloat offset = 3, size = 25, photoSize = 50, x = self.frame.origin.x, y = self.frame.origin.y;
        self.frame = CGRectMake(x, y, size, size);
        
        CALayer *blueLayer = [CALayer layer];
        blueLayer.backgroundColor = [UIColor colorWithRed:100/255.f green:167/255.f blue:229/255.f alpha:1].CGColor;
        blueLayer.frame = self.bounds;
        blueLayer.cornerRadius = size / 2.0f;
        blueLayer.masksToBounds = YES;
        
        [self.layer addSublayer:blueLayer];
        
        if (anno.animate) {
            [blueLayer removeAllAnimations];
            [blueLayer addAnimation:[self blowAnimations] forKey:nil];
        }
        
        CALayer *whiteLayer = [CALayer layer];
        whiteLayer.backgroundColor = [UIColor whiteColor].CGColor;
        whiteLayer.frame = self.bounds;
        whiteLayer.cornerRadius = size / 2.0f;
        whiteLayer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.2].CGColor;
        whiteLayer.borderWidth = 0.5f;
        whiteLayer.shadowOffset = CGSizeZero;
        whiteLayer.shadowColor = [UIColor colorWithWhite:0.2 alpha:1.0].CGColor;
        whiteLayer.shadowRadius = 4.0f;
        whiteLayer.shadowOpacity = 0.4f;
        
        [self.layer addSublayer:whiteLayer];
        
        self.opaque = NO;
        
        self.ball = [UIView new];
        self.ball.backgroundColor = [UIColor colorWithRed:100/255.f green:167/255.f blue:229/255.f alpha:1];
        self.ball.frame = CGRectMake(offset, offset, size-2*offset, size-2*offset);
        self.ball.layer.cornerRadius = self.ball.bounds.size.width / 2.0f;
        self.ball.layer.masksToBounds = YES;
        
        
        self.photoView = [[UIImageView alloc] initWithFrame:CGRectMake(offset, offset, photoSize-2*offset, photoSize-2*offset)];
        self.photoView.layer.cornerRadius = self.photoView.bounds.size.width / 2.0f;
        self.photoView.layer.masksToBounds = YES;
        
        if (anno.animate) {
            [self.ball.layer removeAllAnimations];
            [self.ball.layer addAnimation:[self photoAnimations] forKey:nil];
        }

        [self addSubview:self.ball];
        [self setDraggable:anno.draggable];
    }
    return self;
}
@end
