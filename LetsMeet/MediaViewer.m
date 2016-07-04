//
//  MediaViewer.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 15..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MediaViewer.h"
#import "UserAnnotationView.h"
#import "UIButton+Badge.h"
#import "Notifications.h"

@interface MediaView()
@property (nonatomic, strong) id mediaFile;
@property (nonatomic) MediaTypes mediaType;
@property (nonatomic, strong) UIProgressView *progress;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Notifications *notifications;
@property (nonatomic) BOOL isReal;
@property (nonatomic) BOOL animated;
@property (nonatomic) CALayer* playLayer;
@end

@implementation MediaView

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    __LF
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype) init
{
    __LF
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    __LF
    
    const CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    const CGFloat minSize = 12, maxSize = 25, size = MIN(MAX(MIN(w,h)/4.0f, minSize), maxSize);
    
    self.backgroundColor = [UIColor clearColor];
    self.playLayer = [CALayer layer];
    self.playLayer.frame = CGRectMake((w-size)/2.0f, (h-size)/2.0f, size, size);
    self.playLayer.contents = (id) [UIImage imageNamed:@"play white"].CGImage;
    self.playLayer.opacity = 0.4f;
    self.playLayer.hidden = YES;
    self.playLayer.shadowColor = [UIColor colorWithWhite:0.1 alpha:1].CGColor;
    self.playLayer.shadowOffset = CGSizeZero;
    self.playLayer.shadowRadius = 3.0f;
    self.playLayer.shadowOpacity = 0.4f;
    
    self.imageView.backgroundColor = [UIColor blackColor];
    
    [self.layer addSublayer:self.playLayer];
    
    self.notifications = [Notifications notificationWithMessage:^(id bullet) {
        [self updateBadge];
    } broadcast:^(id senderId, NSString *message, NSTimeInterval duration) {
        [self updateBadge];
    } refresh:^{
        [self updateBadge];
    }];
    [self.notifications on];
}

- (void) updateBadge
{
    __LF
    NSInteger count = [[FileSystem new] unreadMessagesFromUser:self.user.objectId];
    if (count>0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.badgeValue = [NSString stringWithFormat:@"%ld", count];
        });
    }
}

- (void)setShowsShadow:(BOOL)hasShadow
{
    if (hasShadow) {
        self.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:1].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOpacity = 0.4f;
    }
}

- (void)setShowsSex:(BOOL)showsSex
{
    if (self.user) {
        self.imageView.layer.borderWidth = showsSex ? 2.0f : 0.0f;
        self.imageView.layer.borderColor = showsSex ? self.user.sexColor.CGColor : [UIColor clearColor].CGColor;
    }
}

- (void)setIsCircle:(BOOL)isCircle
{
    self.imageView.layer.cornerRadius = isCircle ? MIN(self.bounds.size.width, self.bounds.size.height) / 2.0f : 0;
    self.imageView.layer.masksToBounds = isCircle;
    [self setButtonIsCircle:isCircle];
}

- (void)setMapLocationForUser:(User *)user
{
    _user = user;
    _mediaType = kMediaTypeMap;
}

- (void)setUser:(User *)user
{
    _user = user;
    [self updateBadge];
}

- (void) initialize
{
    __LF
    [self addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) tapped:(id)sender
{
    __LF
    switch (self.mediaType) {
        case kMediaTypePhoto:
        case kMediaTypeVideo:
            [MediaViewer showMediaFromView:self filename:self.mediaFile mediaType:self.mediaType isReal:self.isReal];
            break;
        case kMediaTypeMap: {
            [S3File getDataFromFile:self.user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                [MediaViewer showMapFromView:self user:self.user photo:[UIImage imageWithData:data]];
            }];
        }
            break;
        default:
            break;
    }
}

- (void)setImage:(UIImage *)image
{
    self.playLayer.hidden = !(self.mediaType == kMediaTypeVideo);
    if (self.animated) {
        self.alpha = 0.0;
    }
    [self setImage:image forState:UIControlStateNormal];
    [self.imageView setContentMode: UIViewContentModeScaleAspectFill];
    if (self.animated) {
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 1.0f;
        }];
    }
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

- (void)loadMediaFromFile:(id)filename isReal:(BOOL)isReal completion:(S3GetBlock)block
{
    self.isReal = isReal;
    
    switch (self.mediaType) {
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
                UIImage *image = [self imageFromFile:filename mediaType:self.mediaType]; // create URL Image
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
        case kMediaTypeMap:
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

- (void)loadMediaFromFile:(id)filename isReal:(BOOL)isReal shouldRefresh:(ShouldRefreshBlock)block
{
    [self loadMediaFromFile:filename isReal:isReal completion:^(NSData *data, NSError *error, BOOL fromCache) {
        BOOL ret = NO;
        if (block) {
            ret = block(data, error, fromCache);
        }
        if (ret) {
            [self setImage:[self postProcessImage:[UIImage imageWithData:data] mediaType:self.mediaType]];
        }
    }];
}

- (void)loadMediaFromMessage:(Bullet *)message completion:(S3GetBlock)block
{
    self.mediaType = message.mediaType;
    self.mediaFile = message.mediaFile;
    self.isReal = message.realMedia;

    [self loadMediaFromFile:message.mediaThumbnailFile isReal:self.isReal completion:block];
}

- (void)loadMediaFromMessage:(Bullet *)message shouldRefresh:(ShouldRefreshBlock)block
{
    self.mediaType = message.mediaType;
    self.mediaFile = message.mediaFile;
    self.isReal = message.realMedia;

    [self loadMediaFromFile:message.mediaThumbnailFile isReal:self.isReal shouldRefresh:block];
}

#pragma From User Media

- (void)loadMediaFromUserMedia:(UserMedia *)media animated:(BOOL)animated
{
    self.mediaFile = media.mediaFile;
    self.mediaType = (media.mediaType == kProfileMediaPhoto) ? kMediaTypePhoto : kMediaTypeVideo;
    self.isReal = NO;
    self.animated = YES;
    
    [self loadMediaFromFile:media.thumbailFile isReal:self.isReal completion:^(NSData *data, NSError *error, BOOL fromCache) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:[UIImage imageWithData:data]];
        });
    }];
}

#pragma From User

- (void)loadMediaFromUser:(User *)user animated:(BOOL)animated
{
    self.animated = animated;
    [self loadMediaFromUser:user];
}

- (void)loadMediaFromUser:(User *)user
{
    self.user = user;
    self.mediaFile = user.profileMedia;
    self.mediaType = (user.profileMediaType == kProfileMediaPhoto) ? kMediaTypePhoto : kMediaTypeVideo;
    self.isReal = user.isRealMedia;
    
    [self loadMediaFromFile:user.thumbnail isReal:self.isReal completion:^(NSData *data, NSError *error, BOOL fromCache) {
        UIImage* photo = [UIImage imageWithData:data];
        if (error || !data) {
            photo = [UIImage imageNamed:user.sex == kSexMale ? @"guy" : @"girl"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:photo];
        });
    }];
}

- (void)loadMediaFromUser:(User *)user completion:(S3GetBlock)block
{
    self.user = user;
    self.mediaFile = user.profileMedia;
    self.mediaType = (user.profileMediaType == kProfileMediaPhoto) ? kMediaTypePhoto : kMediaTypeVideo;
    self.isReal = user.isRealMedia;
    
    [self loadMediaFromFile:user.thumbnail isReal:self.isReal completion:block];
}

- (void)loadMediaFromUser:(User *)user shouldRefresh:(ShouldRefreshBlock)block
{
    self.user = user;
    self.mediaFile = user.profileMedia;
    self.mediaType = (user.profileMediaType == kProfileMediaPhoto) ? kMediaTypePhoto : kMediaTypeVideo;
    self.isReal = user.isRealMedia;

    [self loadMediaFromFile:user.thumbnail isReal:self.isReal shouldRefresh:block];
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
@property (nonatomic, strong) MKMapView* map;
@property (nonatomic) CGFloat zoom;
@property (nonatomic) BOOL alive;
@property (nonatomic) BOOL isReal;
@property (nonatomic, strong) CALayer *realLayer;
@property (nonatomic, strong) UIImage *photoForAnnotation;
@property (nonatomic) CLLocationCoordinate2D mapCenter;
@end

@implementation MediaViewer

+ (void)showMapFromView:(UIView *)view user:(User *)user photo:(UIImage *)photo
{
    [[MediaViewer new] showMapFromView:view user:user photo:photo];
}

+ (void)showMediaFromView:(UIView *)view filename:(id)filename mediaType:(MediaTypes)mediaType isReal:(BOOL)isReal
{
    [[MediaViewer new] showMediaFromView:view filename:filename mediaType:mediaType isReal:isReal];
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
    self.map = nil;
    self.alive = YES;
}

#define S3LOCATION @"http://parsekr.s3.ap-northeast-2.amazonaws.com/"

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        UserAnnotationView* pinView = (UserAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"UserAnnotationView"];
        
        if (!pinView)
        {
            pinView = [[UserAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"UserAnnotationView"];
            [pinView.photoView setImage:self.photoForAnnotation];
        }
        else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void) showMapFromView:(UIView*)view user:(User*)user photo:(UIImage *)photo
{
    self.photoForAnnotation = photo;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(user.location.latitude, user.location.longitude);
    self.mapCenter = coordinate;
    const CGFloat span = 2500.0f;
    
    self.frame = [self setupSelfAndGetRootFrameFromView:view];
    self.map = [[MKMapView alloc] initWithFrame:self.frame];
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(coordinate, span, span) animated:YES];
    [self.map setZoomEnabled:YES];
    [self.map setShowsScale:YES];
    [self.map setShowsCompass:YES];
    [self.map setShowsBuildings:YES];
    [self.map setShowsUserLocation:YES];
    [self.map setDelegate:self];
    [self addSubview:self.map];
    
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = self.mapCenter;
    
    [self.map addAnnotation:annotation];

    self.alpha = 0.0f;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self addGestureRecognizer:[self tapGestureRecognizer]];
        [self addGestureRecognizer:[self longPressMapGestureRecognizer]];
    }];
}

- (UILongPressGestureRecognizer*) longPressMapGestureRecognizer
{
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(centerMap:)];
    press.minimumPressDuration = 0.2f;
    return press;
}

- (UITapGestureRecognizer*) tapMapGestureRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(centerMap:)];
    tap.numberOfTapsRequired = 2;
    return tap;
}

- (void)centerMap:(UITapGestureRecognizer*)gesture
{
    [self.map setCenterCoordinate:self.mapCenter];
}


- (void) showMediaFromView:(UIView*)view filename:(id)filename mediaType:(MediaTypes)mediaType isReal:(BOOL)isReal
{
    self.alpha = 0.0f;
    self.mediaFile = filename;
    self.isReal = isReal;
    
    CGRect bigFrame = [self setupSelfAndGetRootFrameFromView:view];
    self.frame = bigFrame;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self addGestureRecognizer:[self tapGestureRecognizer]];
        switch (mediaType) {
            case kMediaTypePhoto:
            {
                self.progress = [UIProgressView new];
                self.progress.frame = CGRectMake( 50, bigFrame.size.height / 2, bigFrame.size.width - 2* 50, 2);
                self.progress.progress = 0.0f;
                [self addSubview:self.progress];
                
                [S3File getDataFromFile:self.mediaFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                    self.progress.progress = 1.0f;
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
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
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
                CGFloat fW = W, fH = h * W / w;
                self.playerView.frame = CGRectMake(0, (H-fH)/2, fW, fH);
                self.playerLayer.frame = self.playerView.bounds;
                if (self.isReal && !self.realLayer) {
                    self.realLayer = [CALayer layer];
                    UIImage *image = [UIImage imageNamed:@"real"];
                    self.realLayer.contents = (id) image.CGImage;
                    self.realLayer.frame = CGRectMake(10 + fabs(rect.origin.x), 10, 40, 40);
                    
                    [self.playerLayer addSublayer:self.realLayer];
                }
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

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(killTap:)];
    tap.numberOfTapsRequired = 1;
    return tap;
}

- (void)killTap:(UITapGestureRecognizer*)gesture
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
