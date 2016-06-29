//
//  MessageView.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 29..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MessageView.h"
#import "MediaViewer.h"
#import "AudioPlayer.h"

@interface MessageView()
@property (strong, nonatomic) MediaView *mediaView;
@property (strong, nonatomic) AudioPlayer *audioView;
@property (strong, nonatomic) UILabel* messageView;
@property (nonatomic, strong) Bullet* message;
@property (nonatomic, strong) UIImageView *playView;
@end

@implementation MessageView

#define kColorMine [UIColor colorWithRed:100/255.f green:167/255.f blue:229/255.f alpha:1]
#define kColorOther [UIColor colorWithRed:239/255.f green:239/255.f blue:244/255.f alpha:1]
#define kColorGreen [UIColor colorWithRed:110/255.f green:200/255.f blue:41/255.f alpha:1]

#define leadingMine 8
#define trailingMine 10
#define leadingOther 18
#define trailingOther 0
#define leadingAudio 10

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    __LF
}

- (CGFloat) setupMessageView:(NSString*)message
{
    CGFloat boxSize = 0;
    NSString *string = [message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    self.messageView.text = string;
    CGRect rect = rectForString(string, self.messageView.font, kTextMessageWidth);
    boxSize = rect.size.width;
    
    return boxSize + (self.message.isFromMe ? (leadingMine+trailingMine) : (leadingOther+trailingOther));
}

- (void) initializeViewsDependingOnMediaType
{
    [self.playView removeFromSuperview];
    [self.mediaView removeFromSuperview];
    [self.audioView removeFromSuperview];
    [self.messageView removeFromSuperview];
    
    self.mediaView = nil;
    self.audioView = nil;
    self.messageView = nil;
    self.playView = nil;
    
    switch (self.message.mediaType) {
        case kMediaTypeText: {
            self.messageView = [UILabel new];
            self.messageView.font = [UIFont systemFontOfSize:13];
            self.messageView.textColor = self.message.isFromMe ? [UIColor whiteColor] : [UIColor darkGrayColor];
            self.messageView.numberOfLines = CGFLOAT_MAX;
            [self addSubview:self.messageView];
        }
            break;
        case kMediaTypeAudio: {
            self.audioView = [AudioPlayer audioPlayerOnView:self];
        }
            break;
        case kMediaTypePhoto:
        case kMediaTypeVideo: {
            self.mediaView = [MediaView new];
            self.playView = [UIImageView new];
            [self.playView setImage:[UIImage imageNamed:@"play white"]];
            [self.mediaView addSubview:self.playView];
            [self addSubview:self.mediaView];
        }
            break;
        case kMediaTypeURL:
            break;
        case kMediaTypeNone:
        default:
            break;
    }
}

- (void)setThumbnailImage:(UIImage *)image
{
    self.mediaView.image = image;
}

- (CGFloat) getSpacingWhileSettingMessage:(Bullet *)message
{
    _message = message;
    [self initializeViewsDependingOnMediaType];
    [self setBackgroundColor];
    
    switch (message.mediaType) {
        case kMediaTypeText: {
            return MAX([self setupMessageView:message.message], 50);
        }
        case kMediaTypeVideo:
        case kMediaTypePhoto: {
            self.playView.hidden = (message.mediaType == kMediaTypePhoto);
            [self.mediaView loadMediaFromMessage:message completion:^(NSData *data, NSError *error, BOOL fromCache) {
                if (!error) {
                    if (fromCache) {
                        self.mediaView.image = [UIImage imageWithData:data];
                    }
                    else {
                        if (self.lazyBlock) {
                            self.lazyBlock(data);
                        }
                    }
                }
            }];
            return kThumbnailWidth;
        }
        case kMediaTypeAudio: {
            
            [S3File getDataFromFile:message.mediaThumbnailFile completedBlock:^(NSData *thumbnail, NSError *error, BOOL thumbnailFromCache) {
                if (!error) {
                    [self.audioView setupAudioThumbnailData:thumbnail audioFile:message.mediaFile];
                }
                else {
                    NSLog(@"ERROR:%@", error.localizedDescription);
                }
            }];
            
            return MIN(MAX(message.audioTicks*5 + 100, kAudioThumbnailWidth/2), kAudioThumbnailWidth);
        }
        case kMediaTypeURL:
        case kMediaTypeNone:
        default:
            return kThumbnailWidth;
    }
}

- (void) setBackgroundColor
{
    self.backgroundColor = self.message.isFromMe ? kColorMine : kColorOther;
}

- (void)layoutSubviews
{
    const CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    const CGFloat pw = 25, ph = 25;
    
    [self setMask];
    self.playView.frame = CGRectMake((w-pw)/2.f, (h-ph)/2.f, pw, ph);
    self.mediaView.frame = self.bounds;
    self.messageView.frame = CGRectMake(self.message.isFromMe ? leadingMine : leadingOther, 0, w-leadingMine-trailingMine, h);
    self.audioView.frame = CGRectMake(self.message.isFromMe ? 0 : leadingAudio, 0, w-leadingAudio, h);
}

#define CPM(__X__,__Y__) CGPointMake(__X__, __Y__)

- (void) setMask
{
    CGRect rect = self.frame;
    CGFloat w = rect.size.width, h=rect.size.height;
    
    const CGFloat min = self.message.mediaType == kMediaTypeText ? 13 : 18;
    const CGFloat i = w < 3*leadingAudio ? MIN(w/4, min) : min;
    const CGFloat j = leadingAudio, k = 13.0f;
    CAShapeLayer *mask = [CAShapeLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat l = 0, r = w, t = 0, b = h;
    
    if (self.message.isFromMe) {
        [path moveToPoint:CPM(l, i)];
        [path addQuadCurveToPoint:CPM(i, t) controlPoint:CPM(l, t)];
        [path addLineToPoint:CPM(r-i-j, t)];
        [path addQuadCurveToPoint:CPM(r-j, i) controlPoint:CPM(r-j, t)];
        [path addLineToPoint:CPM(r-j, b-j)];
        [path addQuadCurveToPoint:CPM(r, b) controlPoint:CPM(r-j, b)];
        [path addQuadCurveToPoint:CPM(r-k, b-j/2) controlPoint:CPM(r-k, b)];
        [path addQuadCurveToPoint:CPM(r-k-k, b) controlPoint:CPM(r-k, b)];
        [path addLineToPoint:CPM(l+i, b)];
        [path addQuadCurveToPoint:CPM(l, b-i) controlPoint:CPM(l, b)];
        [path addLineToPoint:CPM(l, i)];
    }
    else {
        [path moveToPoint:CPM(l+j, i)];
        [path addQuadCurveToPoint:CPM(l+i+j, t) controlPoint:CPM(l+j, t)];
        [path addLineToPoint:CPM(r-i, t)];
        [path addQuadCurveToPoint:CPM(r, i) controlPoint:CPM(r, t)];
        [path addLineToPoint:CPM(r, b-i)];
        [path addQuadCurveToPoint:CPM(r-i, b) controlPoint:CPM(r, b)];
        [path addLineToPoint:CPM(l+k+k, b)];
        [path addQuadCurveToPoint:CPM(l+k, b-j/2) controlPoint:CPM(l+k, b)];
        [path addQuadCurveToPoint:CPM(l, b) controlPoint:CPM(l+k, b)];
        [path addQuadCurveToPoint:CPM(l+j, b-j) controlPoint:CPM(l+j, b)];
        [path addLineToPoint:CPM(l+j, i)];
    }
    mask.path = path.CGPath;
    self.layer.mask = mask;
}
@end
