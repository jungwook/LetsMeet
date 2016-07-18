//
//  UserPostView.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserPostView.h"
#import "MediaViewer.h"
#import "NSDate+TimeAgo.h"

#define kPostStartTag 1199

@interface UserPostView()
@property (nonatomic, strong) UserPost *post;
@property (nonatomic, strong) UIView* lastView;

@property (nonatomic) CGFloat width;

@property (strong, nonatomic) MediaView *photo;
@property (strong, nonatomic) UILabel* nickname;
@property (strong, nonatomic) UILabel* date;
@property (strong, nonatomic) UILabel* title;
@property (nonatomic) CGFloat padding;
@end

@implementation UserPostView

#define PROP(__X__,__Y__) self.__X__ = properties[@"__X__"] ? properties[@"__X__"] : __Y__

- (instancetype)initWithWidth:(CGFloat)width post:(UserPost*)post properties:(id)properties
{
    self = [super init];
    if (self) {
        self.width = width;
        self.padding = 4.0f;
        
        self.photo = [MediaView new];
        self.nickname = [UILabel new];
        self.date = [UILabel new];
        self.title = [UILabel new];
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.photo];
        [self addSubview:self.nickname];
        [self addSubview:self.date];
        [self addSubview:self.title];
        
        self.textFont = properties[@"textFont"] ? properties[@"textFont"] : [UIFont systemFontOfSize:10];
        self.titleFont = properties[@"titleFont"] ? properties[@"titleFont"] : [UIFont systemFontOfSize:10];
        self.nicknameFont = properties[@"nicknameFont"] ? properties[@"nicknameFont"] : [UIFont systemFontOfSize:10];
        self.commentFont = properties[@"commentFont"] ? properties[@"commentFont"] : [UIFont systemFontOfSize:10];
        self.dateFont = properties[@"dateFont"] ? properties[@"dateFont"] : [UIFont systemFontOfSize:10];
        
        self.textColor = properties[@"textColor"] ? properties[@"textColor"] : [UIColor darkGrayColor];
        self.titleColor = properties[@"titleColor"] ? properties[@"titleColor"] : [UIColor darkGrayColor];
        self.nicknameColor = properties[@"nicknameColor"] ? properties[@"nicknameColor"] : [UIColor darkGrayColor];
        self.commentColor = properties[@"commentColor"] ? properties[@"commentColor"] : [UIColor darkGrayColor];
        self.dateColor = properties[@"dateColor"] ? properties[@"dateColor"] : [UIColor darkGrayColor];
        
        roundCorner(self.photo);
        roundCorner(self);

        _post = post;
        [self initializePostViews];
    }
    return self;
}

- (void)initializePostViews
{
    __LF

    __block NSInteger index = 0;
    [self.photo loadMediaFromUser:self.post.user animated:NO];
    self.nickname.text = self.post.user.nickname;
    self.nickname.font = self.nicknameFont;
    self.nickname.textColor = self.nicknameColor;
    
    self.date.text = self.post.updatedAt.timeAgo;
    self.date.font = self.dateFont;
    self.date.textColor = self.dateColor;
    
    self.title.text = [self.post.title uppercaseString];
    self.title.font = self.titleFont;
    self.title.textColor = self.titleColor;
    
    self.nickname.translatesAutoresizingMaskIntoConstraints = NO;
    self.date.translatesAutoresizingMaskIntoConstraints = NO;
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    self.photo.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[self.photo.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:self.padding] setActive:YES];
    [[self.photo.topAnchor constraintEqualToAnchor:self.topAnchor constant:self.padding] setActive:YES];
    [[self.photo.widthAnchor constraintEqualToConstant:30] setActive:YES];
    [[self.photo.heightAnchor constraintEqualToAnchor:self.photo.widthAnchor multiplier:1] setActive:YES];
    
    [[self.nickname.topAnchor constraintEqualToAnchor:self.photo.topAnchor] setActive:YES];
    [[self.nickname.leadingAnchor constraintEqualToAnchor:self.photo.trailingAnchor constant:self.padding] setActive:YES];
    [[self.nickname.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-self.padding] setActive:YES];
    [[self.nickname.heightAnchor constraintEqualToConstant:20] setActive:YES];
    
    [[self.date.bottomAnchor constraintEqualToAnchor:self.photo.bottomAnchor] setActive:YES];
    [[self.date.leadingAnchor constraintEqualToAnchor:self.photo.trailingAnchor constant:self.padding] setActive:YES];
    [[self.date.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-self.padding] setActive:YES];
    [[self.date.heightAnchor constraintEqualToConstant:15] setActive:YES];
    
    self.title.numberOfLines = FLT_MAX;
    [[self.title.topAnchor constraintEqualToAnchor:self.photo.bottomAnchor constant:self.padding] setActive:YES];
    [[self.title.leadingAnchor constraintEqualToAnchor:self.photo.leadingAnchor] setActive:YES];
    [[self.title.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-self.padding] setActive:YES];
    
    __block UIView *lastView = self.title;
    
    [self.post.posts enumerateObjectsUsingBlock:^(id _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        if (line && [line isKindOfClass:[NSString class]]) {
            lastView = [self labelAtIndex:kPostStartTag+index++ line:line isComment:NO font:self.textFont color:self.textColor lastView:lastView];
        }
        else if (line && [line isKindOfClass:[UserMedia class]]){
            UserMedia *media = line;
            lastView = [self mediaAtIndex:kPostStartTag+index++ userMedia:line lastView:lastView];
            lastView = [self labelAtIndex:kPostStartTag+index++ line:media.comment isComment:YES font:self.commentFont color:self.commentColor lastView:lastView];
        }
    }];
    self.lastView = lastView;
    self.frame = CGRectMake(0, 0, self.width, self.lastView.frame.size.height);
    [self layoutIfNeeded];
}

- (UILabel*) labelAtIndex:(NSInteger)index
                     line:(NSString*)line
                isComment:(BOOL)isComment
                     font:(UIFont*)font
                    color:(UIColor*)color
                 lastView:(UIView*)lastView
{
    UILabel *label = [UILabel new];
    label.text = line;
    label.font = font;
    label.textColor = color;
    label.tag = index;
    label.numberOfLines = FLT_MAX;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textAlignment = isComment ? NSTextAlignmentCenter : NSTextAlignmentNatural;
    [self addSubview:label];
    
    [[label.leadingAnchor constraintEqualToAnchor:lastView.leadingAnchor] setActive:YES];
    [[label.topAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:isComment ? self.padding : 0 ] setActive:YES];
    [[label.trailingAnchor constraintEqualToAnchor:lastView.trailingAnchor] setActive:YES];
    [label invalidateIntrinsicContentSize];
    
    return label;
}

- (MediaView*)mediaAtIndex:(NSInteger)index userMedia:(UserMedia*)media lastView:(UIView*)lastView
{
    MediaView* mediaView = [MediaView new];
    [mediaView loadMediaFromUserMedia:media animated:NO];
    roundCorner(mediaView);
    mediaView.tag = index;
    mediaView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:mediaView];
    
    [[mediaView.leadingAnchor constraintEqualToAnchor:lastView.leadingAnchor] setActive:YES];
    [[mediaView.topAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:self.padding] setActive:YES];
    [[mediaView.widthAnchor constraintEqualToAnchor:lastView.widthAnchor multiplier:1] setActive:YES];
    CGFloat ratio = media.mediaSize.width != 0 ? (media.mediaSize.height / media.mediaSize.width) : 0.75f;
    [[mediaView.heightAnchor constraintEqualToAnchor:mediaView.widthAnchor multiplier:ratio] setActive:YES];

    return mediaView;
}

- (CGFloat) viewHeight
{
    return self.lastView.frame.origin.y + self.lastView.frame.size.height+self.padding;
}

@end
