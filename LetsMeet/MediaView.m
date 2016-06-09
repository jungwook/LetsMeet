//
//  MediaView.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MediaView.h"

@interface MediaView()
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) CALayer *photoLayer;
@property (nonatomic, strong) FrameChangedBlock frameChangedBlock;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIView *photoView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@end

#define S3LOCATION @"http://parsekr.s3.ap-northeast-2.amazonaws.com/"

@implementation MediaView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.photoView = [UIView new];
        self.playerView = [UIView new];
        
        self.playerItem = nil;
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.photoLayer = [CALayer layer];
        
        self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pauseItem)];
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(playItem) forControlEvents:UIControlEventTouchUpInside];
        [self.playButton setExclusiveTouch:YES];
        
        [self addGestureRecognizer:self.tap];
        
        [self addSubview:self.photoView];
        [self addSubview:self.playerView];
        
        [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.playerView.layer addSublayer:self.playerLayer];
        [self.photoView.layer addSublayer:self.photoLayer];
        [self.playerView addSubview:self.playButton];
        [self.playerView addGestureRecognizer:self.tap];
        
        self.playerView.alpha = 0.0f;
        self.photoView.alpha = 0.0f;
        self.playButton.alpha = 0.0f;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    __LF
    
    CGFloat s = 50.0f;
    CGRect r = self.bounds;
    CGRect f1 = CGRectMake((r.size.width-s)/2.0f,(r.size.height-s)/2.0f-25,s,s);
    
    self.playerView.frame = self.bounds;
    self.photoView.frame = self.bounds;
    
    self.playButton.frame = f1;
    self.playerLayer.frame = self.playerView.bounds;
    self.photoLayer.frame = self.photoView.bounds;
}

- (void)setMediaFromUser:(User *)user frameBlock:(FrameChangedBlock)frameBlock
{
    self.frameChangedBlock = frameBlock;
    [self setMediaFromUser:user];
}

- (void)showPhotoView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.photoView.alpha = 1.0f;
            self.playerView.alpha = 0.0f;
        }];
    });
}

- (void)showPlayerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.photoView.alpha = 0.0f;
            self.playerView.alpha = 1.0f;
        }];
    });
}

- (void)setMediaFromUser:(User *)user
{
    __LF
    
    NSURL *url = [NSURL URLWithString:[S3LOCATION stringByAppendingString:user.profileMedia]];
    
    [self pauseItem];
    
    switch (user.profileMediaType) {
        case kProfileMediaPhoto: {
            // Media Type Photo.
            [self showPhotoView];
            
            [S3File getDataFromFile:user.profileMedia completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                UIImage *image = [UIImage imageWithData:data];
                if (self.frameChangedBlock) {
                    self.frameChangedBlock(image.size);
                }
                self.photoLayer.contents = (id) image.CGImage;
                self.photoLayer.contentsGravity = kCAGravityResizeAspectFill;
                self.photoLayer.masksToBounds = YES;
                [self setNeedsLayout];
            } progressBlock:^(int percentDone) {
                
            }];
        }
            break;
        case kProfileMediaVideo:
            [self showPlayerView];
            [self setPlayerItemURL:url];
            break;
        default:
            break;
    }
}

- (void)setPlayerItemURL:(NSURL *)url
{
    __LF
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player pause];
        if (url) {
            [self removeObservers];
            self.playerItem = [AVPlayerItem playerItemWithURL:url];
            [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
            [self addObservers];
        }
    });
}

- (void)playerItemStalled:(NSNotification *)notification
{
    __LF
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player play];
    });
}

- (void)showPlayButton:(BOOL)show
{
    [UIView animateWithDuration:1.0f delay:0.5f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.playButton.alpha = show;
    } completion:nil];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    __LF
    [self.player seekToTime:kCMTimeZero];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reframe];
        [self setNeedsLayout];
        [self showPlayButton:YES];
    });
}

- (void)playItem
{
    __LF
    [self.player play];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self showPlayButton:NO];
    });
}

- (void)pause
{
    __LF;
    [self pauseItem];
}

- (void)pauseItem
{
    __LF
    [self.player pause];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showPlayButton:YES];
    });
}

- (void)reframe
{
    __LF
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.frameChangedBlock) {
            self.frameChangedBlock(self.playerItem.presentationSize);
        }
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    __LF
    if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {
        switch (self.playerItem.status) {
            case AVPlayerItemStatusReadyToPlay: {
                [self showPlayerView];
                [self playerItemDidReachEnd:nil];
            }
                break;
            case AVPlayerItemStatusFailed:
                NSLog(@"ITEM FAILED: PROBABLY CAUSE ITEM DOES NOT EXIST");
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"ITEM UNKNOWN");
            default:
                break;
        }
    }
}

- (void) removeObservers
{
    __LF
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
}

- (void) addObservers
{
    __LF
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.playerItem];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
