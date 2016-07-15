//
//  ActivityView.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ActivityView.h"
@interface ActivityView()
@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, strong) UIVisualEffectView *visual;
@end

@implementation ActivityView

+ (instancetype)activityView
{
    UIView *root = [[UIApplication sharedApplication] keyWindow];
    return [[ActivityView alloc] initWithFrame:root.bounds];
}


- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *root = [[UIApplication sharedApplication] keyWindow];
        
        self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.visual = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        self.visual.frame = self.bounds;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.visual];
        
        CGFloat size = 25, w = root.bounds.size.width, h = root.bounds.size.height;
        self.activity.frame = CGRectMake((w-size)/2.0f, (h-size)/2.0f, size, size);
        
        [self addSubview:self.activity];
        [self.activity startAnimating];

        [root addSubview:self];
    }
    return self;
}

- (void)stopAndDie
{
    [self.activity stopAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

@end
