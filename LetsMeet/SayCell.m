//
//  SayCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 15..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SayCell.h"
#import "MediaViewer.h"
#import "S3File.h"

@interface SayCell()
@property (strong, nonatomic) User *user;
@end


@implementation SayCell

- (void)setUserPostView:(UserPostView *)userPostView
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    _userPostView = userPostView;
    
    [self addSubview:self.userPostView];
    self.userPostView.frame = self.bounds;
    self.userPostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.userPostView translatesAutoresizingMaskIntoConstraints];
}

- (CABasicAnimation*) photoAnimations
{
    const CGFloat sf = 1.02;
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
    scale.toValue = [NSValue valueWithCGSize:CGSizeMake(sf, sf)];
    scale.duration = 0.1f;
    scale.autoreverses = YES;
    scale.repeatCount = 1;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scale.removedOnCompletion = YES;
    
    return scale;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.layer addAnimation:[self photoAnimations] forKey:nil];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}


@end
