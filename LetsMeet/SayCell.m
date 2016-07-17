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

@end
