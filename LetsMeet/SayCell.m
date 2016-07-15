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

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.viewHeight = 1;
    self.ready = NO;
}

CGRect __rect(NSString *string, UIFont *font, CGFloat maxWidth)
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    CGRect rect = CGRectIntegral([string boundingRectWithSize:CGSizeMake(maxWidth, 0)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{
                                                                NSFontAttributeName: font,
                                                                } context:nil]);
    return rect;
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

- (CGFloat) viewHeight
{
    __block CGFloat top = 0;
    const CGFloat w = self.bounds.size.width, o = 4.f, width = w-o-o;

    [self.posts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *text = obj;
            CGRect rect = __rect(text, self.textFont, width);
            top += rect.size.height;
        }
        else if ([obj isKindOfClass:[UserMedia class]]){
            UserMedia *media = obj;
            UIImage *image = [UIImage imageWithData:[S3File objectForKey:media.thumbailFile]];
            if (image) {
                top+=w*image.size.height/image.size.width;
            }
            NSString *comment = media.comment;
            CGRect rect = __rect(comment, self.commentFont, width);
            top += rect.size.height;
        }
    }];
    return top;
}

- (void)displayPosts
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 1199) {
            [obj removeFromSuperview];
        }
    }];
    
    __block CGFloat top = 0;
    const CGFloat w = self.bounds.size.width, l = self.bounds.origin.x, o = 4.f, width = w-o-o;
    
    [self.posts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *text = obj;
            CGRect rect = __rect(text, self.textFont, width);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(o, top, width, rect.size.height)];
            label.text = text;
            label.font = self.textFont;
            label.textColor = self.textColor;
            label.tag = 1199;
            label.numberOfLines = FLT_MAX;
            [self addSubview:label];
            top += rect.size.height;
        }
        else if ([obj isKindOfClass:[UserMedia class]]){
            UserMedia *media = obj;
            UIImage *image = [UIImage imageWithData:[S3File objectForKey:media.thumbailFile]];
            if (image) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(l, top, w, w*image.size.height/image.size.width)];
                [imageView setImage:image];
                [imageView setContentMode:UIViewContentModeScaleAspectFill];
                [imageView setTag:1199];
                [self addSubview:imageView];
                top+=w*image.size.height/image.size.width;
            }
            NSString *comment = media.comment;
            CGRect rect = __rect(comment, self.commentFont, width);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(o, top, width, rect.size.height)];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = comment;
            label.font = self.commentFont;
            label.textColor = self.commentColor;
            label.tag = 1199;
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
    
    self.postView.textColor = self.textColor;
    self.postView.commentColor = self.commentColor;
    self.postView.textFont = self.textFont;
    self.postView.commentFont = self.commentFont;
    self.postView.posts = self.post.posts;
}

- (CGFloat) postHeight
{
    return self.postView.frame.origin.y+self.postView.viewHeight;
}

@end
