//
//  MediaViewer.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 15..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MediaViewer.h"
#import "S3File.h"
#import "NSMutableDictionary+Bullet.h"

@interface MMediaView()
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) id mediaFile;
@property (nonatomic) MediaTypes mediaType;
@end

@implementation MMediaView
- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
}

- (void) tapped:(UITapGestureRecognizer*) gesture
{
//    [MediaViewer showMediaFromView:tap.view filename:self.profileMediaFile isPhoto:(self.profileMediaType == kProfileMediaPhoto)];
}

@end

@interface CenterView : UIScrollView
@end

@implementation CenterView

-(void)layoutSubviews
{
    [super layoutSubviews];
    UIView* v = [self.delegate viewForZoomingInScrollView:self];
    CGFloat svw = self.bounds.size.width;
    CGFloat svh = self.bounds.size.height;
    CGFloat vw = v.frame.size.width;
    CGFloat vh = v.frame.size.height;
    CGRect f = v.frame;
    if (vw < svw)
        f.origin.x = (svw - vw) / 2.0;
    else
        f.origin.x = 0;
    
    if (vh < svh)
        f.origin.y = (svh - vh) / 2.0;
    else
        f.origin.y = 0;
    v.frame = f;
}
@end


@interface MediaViewer() <UIScrollViewDelegate>
@property (nonatomic, strong) id mediaFile;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIProgressView *progress;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIView* playerView;
@property (nonatomic) CGFloat zoom;
@end

@implementation MediaViewer

+ (void)showMediaFromView:(UIView *)view filename:(id)filename isPhoto:(BOOL)isPhoto
{
    [[MediaViewer new] showMediaFromView:view filename:filename isPhoto:isPhoto];
}

- (void) dealloc
{
    __LF
    self.scrollView = nil;
    self.imageView = nil;
    self.progress = nil;
    self.playerItem = nil;
    self.player = nil;
    self.playerLayer = nil;
    self.playerView = nil;
}

#define S3LOCATION @"http://parsekr.s3.ap-northeast-2.amazonaws.com/"

- (void) showMediaFromView:(UIView*)view filename:(id)filename isPhoto:(BOOL)isPhoto
{
    self.alpha = 0.0f;
    self.mediaFile = filename;
    
    CGRect bigFrame = [self setupSelfAndGetRootFrameFromView:view];
    self.frame = bigFrame;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (isPhoto) {
            self.progress = [UIProgressView new];
            self.progress.frame = CGRectMake( 50, bigFrame.size.height / 2, bigFrame.size.width - 2* 50, 2);
            self.progress.progress = 0.0f;
            [self addSubview:self.progress];

            [S3File getDataFromFile:self.mediaFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                self.progress.progress = 1.0f;
                [self addGestureRecognizer:[self tapGestureRecognizer]];
                [self setupScrollViewFromImage:[UIImage imageWithData:data]];
                
                [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.imageView.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    [self.progress removeFromSuperview];
                }];
            } progressBlock:^(int percentDone) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.progress.progress = percentDone / 100.0f;
                });
            }];
        }
        else {
            [self initializeVideoWithURL:[NSURL URLWithString:[S3LOCATION stringByAppendingString:self.mediaFile]]];
            [self addGestureRecognizer:[self tapGestureRecognizer]];
        }
    }];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    __LF
    [self.player seekToTime:kCMTimeZero];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player play];
    });
}

- (void)playerItemStalled:(NSNotification *)notification
{
    __LF
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player play];
    });
}

- (void) initializeVideoWithURL:(NSURL*)url
{
    NSLog(@"URL:%@", url);
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.playerItem];


    self.playerView = [[UIView alloc] init];
    [self addSubview:self.playerView];
    
    [self.playerView.layer addSublayer:self.playerLayer];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    __LF
    if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {
        switch (self.playerItem.status) {
            case AVPlayerItemStatusReadyToPlay: {
                CGSize size = self.playerItem.presentationSize;
                CGFloat w = size.width, h=size.height;
                CGFloat W = self.bounds.size.width, H = self.bounds.size.height;
                CGRect rect;
                if (w >= h) { //landscape
                    CGFloat fW = W, fH = h * W / w;
                    rect = CGRectMake(0, (H-fH)/2, fW, fH);
                }
                else {
                    CGFloat fH = H, fW = w * H / h;
                    rect = CGRectMake((W-fW)/2, 0, fW, fH);
                }
                self.playerView.frame = rect;
                self.playerLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
                [self.player play];
            }
                break;
            case AVPlayerItemStatusFailed:
            case AVPlayerItemStatusUnknown:
            default:
                [self killThisView];
                break;
        }
    }
}

- (void) killThisView
{
    if (self.playerItem) {
        [self.player pause];
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (CGRect) setupSelfAndGetRootFrameFromView:(UIView*)view
{
    UIView *root = [[UIApplication sharedApplication] keyWindow];
    self.frame = [view convertRect:view.frame toView:root];
    self.clipsToBounds = YES;
    [root addSubview:self];
    
    [self addEffectsWithRootFrame:root.frame];
    
    
    return root.frame;
}

- (void)addEffectsWithRootFrame:(CGRect)frame
{
    UIVisualEffectView* blurView;
    UIVisualEffectView* vibracyView;

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVibrancyEffect *vibe = [UIVibrancyEffect effectForBlurEffect:blur];
    
    blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.frame = frame;
    
    vibracyView = [[UIVisualEffectView alloc] initWithEffect:vibe];
    vibracyView.frame = frame;
    
    [self addSubview:blurView];
    [self addSubview:vibracyView];
}

- (UITapGestureRecognizer*) tapGestureRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap.numberOfTapsRequired = 1;
    return tap;
}

- (void)doubleTap:(UITapGestureRecognizer*)gesture
{
    __LF
    [self killThisView];
}

- (void) setupScrollViewFromImage:(UIImage*)image
{
    self.scrollView = [[CenterView alloc] initWithFrame:self.frame];
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.alpha = 0.0f;
    [self.scrollView addSubview:self.imageView];
    
    NSDictionary *metrics = @{@"height" : @(image.size.height), @"width" : @(image.size.width)};
    NSDictionary *views = @{@"imageView":self.imageView};
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView(height)]|" options:kNilOptions metrics:metrics views:views]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView(width)]|" options:kNilOptions metrics:metrics views:views]];
    
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self initZoomWithImage:image];
}

- (void) doubleTapImageView:(id)sender
{
    __LF
    static CGFloat prev = 1;
    
    CGFloat zoom = self.scrollView.zoomScale;
    [UIView animateWithDuration:0.1 animations:^{
        self.scrollView.zoomScale = prev;
    }];
    prev = zoom;
}

- (void) initZoomWithImage:(UIImage*)image
{
    float minZoom = MIN(self.bounds.size.width / image.size.width,
                        self.bounds.size.height / image.size.height);
    if (minZoom > 1) return;
    
    self.scrollView.minimumZoomScale = minZoom;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.zoomScale = minZoom;
    self.zoom = minZoom;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.zoom = scale;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
