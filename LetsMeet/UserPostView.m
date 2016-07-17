//
//  UserPostView.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserPostView.h"
#import "MediaViewer.h"

#define kPostStartTag 1199

@interface UserPostView()
@property (nonatomic, weak) UserPost *post;
@property (nonatomic, weak) User *user;

@property (nonatomic) CGFloat width;
@property (nonatomic) UIEdgeInsets titleInset;
@property (nonatomic) UIEdgeInsets textInset;
@property (nonatomic) UIEdgeInsets commentInset;

@property (strong, nonatomic) MediaView *photo;
@property (strong, nonatomic) UILabel* nickname;
@property (strong, nonatomic) UILabel* date;
@property (strong, nonatomic) UILabel* title;
@property (nonatomic) BOOL postInitialized;
@property (nonatomic) CGFloat padding;
@end

@implementation UserPostView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeWithWidth:100.0f];
    }
    return self;
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super init];
    if (self) {
        [self initializeWithWidth:width];
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeWithWidth:self.bounds.size.width];
}

- (void)initializeWithWidth:(CGFloat)width
{
    self.postInitialized = NO;
    self.padding = 4.0f;
    
    self.width = width;
    self.titleInset = UIEdgeInsetsMake(2, 0, 2, 0);
    self.textInset = UIEdgeInsetsMake(2, 0, 2, 0);
    self.commentInset = UIEdgeInsetsMake(2, 0, 0, 2);

    self.photo = [MediaView new];
    self.nickname = [UILabel new];
    self.date = [UILabel new];
    self.title = [UILabel new];
    
    [self addSubview:self.photo];
    [self addSubview:self.nickname];
    [self addSubview:self.date];
    [self addSubview:self.title];
    roundCorner(self.photo);
}

- (void)initializePostViews
{
    __block NSInteger index = 0;
    [self.photo loadMediaFromUser:self.user animated:NO];
    self.nickname.text = self.post.nickname;
    self.nickname.font = self.nicknameFont;
    self.nickname.textColor = self.nicknameColor;
    
    self.date.text = [NSDateFormatter localizedStringFromDate:self.post.updatedAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    self.date.font = self.dateFont;
    self.date.textColor = self.dateColor;
    
    self.title.text = self.post.title;
    self.title.font = self.titleFont;
    self.title.textColor = self.titleColor;
    
    [self.post.posts enumerateObjectsUsingBlock:^(id _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        if (line && [line isKindOfClass:[NSString class]]) {
            [self addSubview:[self labelAtIndex:kPostStartTag+index++ line:line font:self.textFont color:self.textColor]];
        }
        else if (line && [line isKindOfClass:[UserMedia class]]){
            UserMedia *media = line;
            [self addSubview:[self mediaAtIndex:kPostStartTag+index++ userMedia:line]];
            [self addSubview:[self labelAtIndex:kPostStartTag+index++ line:media.comment font:self.commentFont color:self.commentColor]];
        }
    }];
    self.postInitialized = YES;
}

- (UILabel*)labelAtIndex:(NSInteger)index line:(NSString*)line font:(UIFont*)font color:(UIColor*)color
{
    UILabel *label = [UILabel new];
    label.text = line;
    label.font = font;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    label.tag = index;
    
    return label;
}

- (MediaView*)mediaAtIndex:(NSInteger)index userMedia:(UserMedia*)media
{
    MediaView* view = [MediaView new];
    [view loadMediaFromUserMedia:media animated:NO];
    roundCorner(view);
    view.tag = index;
    
    return view;
}

- (void)setLoadedPost:(UserPost*)post andUser:(User*)user
{
    _post = post;
    _user = user;
    [self initializePostViews];
    [self setNeedsLayout];
}

#define sF(__X__) __X__.frame.origin.x
#define eF(__X__) (__X__.frame.origin.x+__X__.frame.size.width)
#define tF(__X__) __X__.frame.origin.y
#define bF(__X__) (__X__.frame.origin.y+__X__.frame.size.height)

- (void)layoutSubviews
{
    __LF
    const CGFloat photoSize = 30, w = self.bounds.size.width, p = self.padding;
    
    [super layoutSubviews];
    
    self.photo.frame = CGRectMake(p, p, photoSize, photoSize);
    self.nickname.frame = CGRectMake(eF(self.photo)+p, tF(self.photo), w-p-eF(self.photo)-p, 18);
    self.date.frame = CGRectMake(eF(self.photo)+p, tF(self.photo)+15, w-p-eF(self.photo)-p, 15);
    self.title.frame = CGRectMake(p, bF(self.photo)+p, w-p-p, 25);

    if (self.postInitialized) {
        CGFloat top = bF(self.title);
        UIView *view = nil;
        NSInteger index = 0;
        do {
            view = viewWithTag(self, kPostStartTag+index++);
            if (view && [view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)view;
                CGFloat h = labelHeight(label.text, label.font, w-p-p);
                view.frame = CGRectMake(p, top, w-p-p, h+4);
                top += bF(view);
                _viewHeight = top;
            }
            else if (view && [view isKindOfClass:[MediaView class]]) {
                MediaView *mediaView = (MediaView*)view;
                CGSize size = mediaView.media.mediaSize;
                CGFloat h = (w-p-p)*size.height/size.width;
                view.frame = CGRectMake(p, top+p, w-p-p, h);
                top+=bF(view);
                _viewHeight = top;
            }
        } while(view);
    }
}

- (CGFloat) viewHeight
{
    return _viewHeight + self.padding;
}

CGFloat labelHeight(NSString *string, UIFont *font, CGFloat maxWidth)
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    CGRect rect = CGRectIntegral([string boundingRectWithSize:CGSizeMake(maxWidth, 0)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{
                                                                NSFontAttributeName: font,
                                                                } context:nil]);
    return rect.size.height;
}

@end
