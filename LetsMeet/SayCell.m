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

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.textColor = [UIColor darkGrayColor];
    self.titleColor = [UIColor darkGrayColor];
    self.dateColor = [UIColor darkGrayColor];
    self.nicknameColor = [UIColor darkGrayColor];
    self.commentColor = [UIColor darkGrayColor];
    
    self.textFont = [UIFont systemFontOfSize:10];
    self.titleFont = [UIFont boldSystemFontOfSize:12];
    self.dateFont = [UIFont systemFontOfSize:9];
    self.nicknameFont = [UIFont boldSystemFontOfSize:12];
    self.commentFont = [UIFont boldSystemFontOfSize:10];
}

- (void)setUserPostView:(UserPostView *)userPostView
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    _userPostView = userPostView;
    
    self.userPostView.frame = self.bounds;
    self.userPostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.userPostView translatesAutoresizingMaskIntoConstraints];
    [self addSubview:self.userPostView];
}

- (void)setPost:(UserPost *)post
{
    _post = post;
    
    self.user = [User objectWithoutDataWithObjectId:self.post.userId];
    [self.user fetched:^{
        [self.userPostView setLoadedPost:self.post andUser:self.user];
    }];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.userPostView.titleFont = titleFont;
}

- (void)setDateFont:(UIFont *)dateFont
{
    _dateFont = dateFont;
    self.userPostView.dateFont = dateFont;
}

- (void)setNicknameFont:(UIFont *)nicknameFont
{
    _nicknameFont = nicknameFont;
    self.userPostView.nicknameFont = nicknameFont;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.userPostView.titleColor = titleColor;
}

- (void)setNicknameColor:(UIColor *)nicknameColor
{
    _nicknameColor = nicknameColor;
    self.userPostView.nicknameColor = nicknameColor;
}

- (void)setDateColor:(UIColor *)dateColor
{
    _dateColor = dateColor;
    self.userPostView.dateColor = dateColor;
}

- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    self.userPostView.textFont = textFont;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.userPostView.textColor = textColor;
}

- (void)setCommentFont:(UIFont *)commentFont
{
    _commentFont = commentFont;
    self.userPostView.commentFont = commentFont;
}

- (void)setCommentColor:(UIColor *)commentColor
{
    _commentColor = commentColor;
    self.userPostView.commentColor = commentColor;
}

@end
