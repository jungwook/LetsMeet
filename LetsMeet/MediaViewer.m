//
//  MediaViewer.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 15..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MediaViewer.h"
#import "NSMutableDictionary+Bullet.h"

@interface MediaView()
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) id mediaFile;
@property (nonatomic) MediaTypes mediaType;
@property (nonatomic, strong) UIProgressView* progress;
@end

@implementation MediaView

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
    self.progress = [UIProgressView new];
}

- (void) tapped:(UITapGestureRecognizer*) gesture
{
    [MediaViewer showMediaFromView:self filename:self.mediaFile mediaType:self.mediaType];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    self.layer.contents = (id) image.CGImage;
    self.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.layer.masksToBounds = YES;
}

- (UIImage*) imageFromFile:(id)filename mediaType:(MediaTypes)mediaType
{
    switch (mediaType) {
        case kMediaTypeURL:
            return nil;
        case kMediaTypeNone:
            return nil;
        default:
            return nil;
    }
}

- (void)loadMediaFromFile:(id)filename mediaType:(MediaTypes)mediaType completion:(S3GetBlock)block
{
    switch (mediaType) {
        case kMediaTypeAudio:
        case kMediaTypeVideo:
        case kMediaTypePhoto: {
            self.progress.progress = 0;
            [S3File getDataFromFile:filename completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                if (block) {
                    block(data, error, fromCache);
                }
                self.progress.progress = 1.0f;
            } progressBlock:^(int percentDone) {
                self.progress.progress = percentDone / 100.0f;
            }];
        }
            break;

        case kMediaTypeNone:
        case kMediaTypeURL:
        {
            if (block) {
                UIImage *image = [self imageFromFile:filename mediaType:mediaType]; // create URL Image
                NSData *data = UIImageJPEGRepresentation(image, kJPEGCompressionFull);
                block(data, nil, YES);
            }
        }
            break;
        case kMediaTypeText:
            if (block) {
                block(nil, nil, YES);
            }
            break;
    }
}

- (UIImage*) postProcessImage:(UIImage*)image mediaType:(MediaTypes)mediaType
{
    switch (mediaType) {
        case kMediaTypeVideo:
        {
            //ADD VIDEO MARKET TO IMAGE
        }
            return image;
            
        default:
            return image;
    }
}

- (void)loadMediaFromFile:(id)filename mediaType:(MediaTypes)mediaType shouldRefresh:(ShouldRefreshBlock)block
{
    [self loadMediaFromFile:filename mediaType:mediaType completion:^(NSData *data, NSError *error, BOOL fromCache) {
        BOOL ret = NO;
        if (block) {
            ret = block(data, error, fromCache);
        }
        if (ret) {
            [self setImage:[self postProcessImage:[UIImage imageWithData:data] mediaType:mediaType]];
        }
    }];
}

- (void)loadMediaFromMessage:(Bullet *)message completion:(S3GetBlock)block
{
    [self loadMediaFromFile:message.mediaFile mediaType:message.mediaType completion:block];
}

- (void)loadMediaFromMessage:(Bullet *)message shouldRefresh:(ShouldRefreshBlock)block
{
    BOOL hasThumbnail = NO;
    if (message.mediaType == kMediaTypeVideo || message.mediaType == kMediaTypeAudio) {
        hasThumbnail = YES;
    }
    
    [self loadMediaFromFile:hasThumbnail ? message.mediaThumbnailFile : message.mediaFile mediaType:message.mediaType shouldRefresh:block];
}

- (void)loadMediaFromUser:(User *)user completion:(S3GetBlock)block
{
    [self loadMediaFromFile:user.profileMedia mediaType:(user.profileMediaType == kProfileMediaPhoto) ? kMediaTypePhoto : kMediaTypeVideo completion:block];
}

- (void)loadMediaFromUser:(User *)user shouldRefresh:(ShouldRefreshBlock)block
{
    [self loadMediaFromFile:user.profileMedia mediaType:(user.profileMediaType == kProfileMediaPhoto) ? kMediaTypePhoto : kMediaTypeVideo  shouldRefresh:block];
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
@property (nonatomic) BOOL alive;
@end

@implementation MediaViewer

+ (void)showMediaFromView:(UIView *)view filename:(id)filename mediaType:(MediaTypes)mediaType
{
    [[MediaViewer new] showMediaFromView:view filename:filename mediaType:mediaType];
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
    self.alive = YES;
}

#define S3LOCATION @"http://parsekr.s3.ap-northeast-2.amazonaws.com/"

- (void) showMediaFromView:(UIView*)view filename:(id)filename mediaType:(MediaTypes)mediaType
{
    self.alpha = 0.0f;
    self.mediaFile = filename;
    
    CGRect bigFrame = [self setupSelfAndGetRootFrameFromView:view];
    self.frame = bigFrame;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        switch (mediaType) {
            case kMediaTypePhoto:
            {
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
                break;
                
            case kMediaTypeVideo:
            {
                [self initializeVideoWithURL:[NSURL URLWithString:[S3LOCATION stringByAppendingString:self.mediaFile]]];
                [self addGestureRecognizer:[self tapGestureRecognizer]];
            }
                break;
                
            default:
                break;
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
    [self restartPlayingIfLikelyToKeepUp];
}

- (void) restartPlayingIfLikelyToKeepUp
{
    __LF
    if (!self.alive)
        return;
    
    if (self.playerItem.playbackLikelyToKeepUp) {
        [self.player play];
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self restartPlayingIfLikelyToKeepUp];
        });
    }
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
    self.alive = NO;
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
