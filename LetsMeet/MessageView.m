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
@property (weak, nonatomic) UITableView* tableView;
@property (strong, nonatomic) MediaView *mediaView;
@property (strong, nonatomic) AudioPlayer *audioView;
@property (strong, nonatomic) UILabel* messageView;
@property (nonatomic, strong) Bullet* message;
@end

@implementation MessageView

#define kColorMine [UIColor colorWithRed:100/255.f green:167/255.f blue:229/255.f alpha:1]
#define kColorOther [UIColor colorWithRed:239/255.f green:239/255.f blue:244/255.f alpha:1]
#define kColorGreen [UIColor colorWithRed:110/255.f green:200/255.f blue:41/255.f alpha:1]

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
    self.mediaView = [MediaView new];
    self.audioView = [AudioPlayer audioPlayerOnView:self];
    self.messageView = [UILabel new];

    [self addSubview:self.mediaView];
    [self addSubview:self.messageView];
}

- (CGFloat) setupMessageView:(NSString*)message
{
    CGFloat boxSize = 0;
    NSString *string = [message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    self.messageView.text = string;
    CGRect rect = rectForString(string, self.messageView.font, kTextMessageWidth);
    boxSize = rect.size.width;
    
    return boxSize;
}

- (CGFloat) getSpacingWhileSettingMessage:(Bullet *)message
{
    _message = message;

    [self setBackgroundColor];
    [self showHideViews];
    
    switch (message.mediaType) {
        case kMediaTypeText: {
            return [self setupMessageView:message.message];
        }
        case kMediaTypeVideo:
        case kMediaTypePhoto: {
//            self.thumbnail.hidden = NO;
//            self.playView.hidden = (message.mediaType == kMediaTypePhoto);
            
            [self.mediaView loadMediaFromMessage:message completion:^(NSData *data, NSError *error, BOOL fromCache) {
                if (!error) {
                    if (fromCache) {
                        self.mediaView.image = [UIImage imageWithData:data];
                    }
                    else {
//                        [self lazyUpdateData:data onTableView:tableView];
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
    [self setMask];
    self.audioView.frame = self.bounds;
    self.mediaView.frame = self.bounds;
}

- (void) showHideViews
{
    switch (self.message.mediaType) {
        case kMediaTypePhoto:
        case kMediaTypeVideo:
            self.mediaView.hidden = NO;
            self.audioView.hidden = YES;
            self.messageView.hidden = YES;
            break;
        case kMediaTypeAudio:
            self.mediaView.hidden = YES;
            self.audioView.hidden = NO;
            self.messageView.hidden = YES;
            break;
        case kMediaTypeText:
            self.mediaView.hidden = YES;
            self.audioView.hidden = YES;
            self.messageView.hidden = NO;
            break;
            
        default:
            break;
    }
}

#define CPM(__X__,__Y__) CGPointMake(__X__, __Y__)

- (void) setMask
{
    CGRect rect = self.frame;
    CGFloat w = rect.size.width, h=rect.size.height;
    
    CGFloat i = w < 43 ? MIN(w/2.3, 18) : 19, j = 10.0f, k = 13.0f;
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
