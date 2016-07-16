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

@interface PostView : UIView
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *commentColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIFont *commentFont;

@property (nonatomic, strong) NSArray *posts;
@property (nonatomic) CGFloat viewHeight;
@property (nonatomic) BOOL ready;
@end

@implementation PostView

#define kPostStartTag 1199

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.viewHeight = 1;
    self.ready = NO;
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
}

CGRect getPostRect(NSString *string, UIFont *font, CGFloat maxWidth)
{
    const CGFloat padding = 4.f;
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    CGRect rect = CGRectIntegral([string boundingRectWithSize:CGSizeMake(maxWidth, 0)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{
                                                                NSFontAttributeName: font,
                                                                } context:nil]);
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height+padding);
}

- (void)setPosts:(NSArray *)posts
{
    _posts = posts;
    
    __block NSInteger count = self.posts.count;
    
    [self.posts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            if (--count == 0) {
                self.ready = YES;
                [self displayPosts];
            }
        }
        else if ([obj isKindOfClass:[UserMedia class]]){
            [((UserMedia*)obj) fetched:^{
                [S3File getDataFromFile:((UserMedia*)obj).thumbailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                    if (--count == 0) {
                        self.ready = YES;
                        [self displayPosts];
                    }
                }];
            }];
        }
    }];
}

UIView* viewWithTag(UIView *view, NSInteger tag)
{
    __block UIView *retView = nil;
    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == tag) {
            retView = obj;
            *stop = YES;
        }
    }];
    return retView;
}

- (void)layoutSubviews
{
    const CGFloat imagePadding = 4.f;
    [super layoutSubviews];
    
    CGFloat w = self.bounds.size.width, l = self.bounds.origin.x;
    NSInteger counter = 0;
    UIView *view = nil;
    CGFloat top = 0;
    do {
        view = viewWithTag(self, kPostStartTag+counter++);
        if (view && [view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel*)view;
            CGRect rect = getPostRect(label.text, label.font, w);
            CGFloat h = rect.size.height;
            label.frame = CGRectMake(l, top, w, h);
            top += h;
        }
        else if (view && [view isKindOfClass:[MediaView class]]) {
            MediaView *mediaView = (MediaView*)view;
            CGSize size = mediaView.media.mediaSize;
            CGFloat h = w*size.height/size.width;
            view.frame = CGRectMake(l, top+imagePadding, w, h);
            top+=(h+imagePadding);
        }
    } while (view);
}

- (void)displayPosts
{
    const CGFloat imagePadding = 4.f;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag >= kPostStartTag) {
            [obj removeFromSuperview];
        }
    }];
    
    __block CGFloat top = 0;
    const CGFloat w = self.bounds.size.width, l = self.bounds.origin.x;
    
    __block NSInteger counter = 0;
    
    [self.posts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *text = obj;
            CGRect rect = getPostRect(text, self.textFont, w);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l, top, w, rect.size.height)];
            label.text = text;
            label.font = self.textFont;
            label.textColor = self.textColor;
            label.tag = kPostStartTag+counter++;
            label.numberOfLines = FLT_MAX;
            [self addSubview:label];
            top += rect.size.height;
        }
        else if ([obj isKindOfClass:[UserMedia class]]){
            UserMedia *media = obj;
            UIImage *image = [UIImage imageWithData:[S3File objectForKey:media.thumbailFile]];
            if (image) {
                MediaView *mediaView = [[MediaView alloc] initWithFrame:CGRectMake(l, top+imagePadding, w, w*image.size.height/image.size.width)];
                [mediaView loadMediaFromUserMedia:media animated:NO];
                [mediaView setTag:kPostStartTag+counter++];
                mediaView.layer.cornerRadius = 2.0f;
                mediaView.layer.masksToBounds = YES;
                [self addSubview:mediaView];
                top+=(imagePadding+w*image.size.height/image.size.width);
            }
            NSString *comment = (!media.comment || [media.comment isEqualToString:@""]) ? @"NO COMMENT" : media.comment;
            CGRect rect = getPostRect(comment, self.commentFont, w);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l, top, w, rect.size.height)];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = comment;
            label.font = self.commentFont;
            label.textColor = self.commentColor;
            label.tag = kPostStartTag+counter++;
            label.numberOfLines = FLT_MAX;
            [self addSubview:label];
            top += rect.size.height;
        }
    }];
}

@end

@interface SayCell()
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet PostView *postView;
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

- (void)setPost:(UserPost *)post
{
    _post = post;
    
    self.user = [User objectWithoutDataWithObjectId:self.post.userId];
    [self.user fetched:^{
        [self.photo loadMediaFromUser:self.user animated:NO];
    }];
    self.nickname.text = self.post.nickname;
    self.date.text = [NSDateFormatter localizedStringFromDate:self.post.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    self.title.text = self.post.title;
    
    self.nickname.font = self.nicknameFont;
    self.date.font = self.dateFont;
    self.title.font = self.titleFont;
    
    self.postView.textColor = self.textColor;
    self.postView.commentColor = self.commentColor;
    self.postView.textFont = self.textFont;
    self.postView.commentFont = self.commentFont;
    self.postView.posts = self.post.posts;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.title.font = titleFont;
}

- (void)setDateFont:(UIFont *)dateFont
{
    _dateFont = dateFont;
    self.date.font = dateFont;
}

- (void)setNicknameFont:(UIFont *)nicknameFont
{
    _nicknameFont = nicknameFont;
    self.nickname.font = nicknameFont;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.title.textColor = titleColor;
}

- (void)setNicknameColor:(UIColor *)nicknameColor
{
    _nicknameColor = nicknameColor;
    self.nickname.textColor = nicknameColor;
}

- (void)setDateColor:(UIColor *)dateColor
{
    _dateColor = dateColor;
    self.date.textColor = dateColor;
}

- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    self.postView.textFont = textFont;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.postView.textColor = textColor;
}

- (void)setCommentFont:(UIFont *)commentFont
{
    _commentFont = commentFont;
    self.postView.commentFont = commentFont;
}

- (void)setCommentColor:(UIColor *)commentColor
{
    _commentColor = commentColor;
    self.postView.commentColor = commentColor;
}

@end
