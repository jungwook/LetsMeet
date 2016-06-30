//
//  MediaPlayer.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 7..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MediaPlayer.h"

#define S3LOCATION @"http://parsekr.s3.ap-northeast-2.amazonaws.com/"

@interface MediaPlayer()
@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem *item;
@property (nonatomic, strong) AVPlayerLayer *layer;
@property (nonatomic, weak) UIView* view;
@end

@implementation MediaPlayer

+ (instancetype)playerWithPath:(NSString *)path onView:(UIView *)view frameChange:(FrameChangedBlock)frameChange
{
    return [[MediaPlayer alloc] initWithPath:path onView:view frameChange:frameChange];
}

- (void) setPlayerItemWithPath:(NSString*)path
{
    NSString *fullPath = [S3LOCATION stringByAppendingString:path];
    [self setPlayerItemwithURL:[NSURL URLWithString:fullPath]];
}

- (void) reframe
{
    if (self.frameChangedBlock) {
        CGSize size = self.item.presentationSize;
        self.frameChangedBlock(CGRectMake(0, 0, size.width, size.height));
    }
}

- (void) setPlayerItemwithURL:(NSURL*)url
{
    [self.player pause];
    self.view.alpha = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [self.item removeObserver:self forKeyPath:@"status"];
    self.item = [AVPlayerItem playerItemWithURL:url];
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.item];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.item];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.item];
}

- (instancetype) initWithPath:(NSString *)path onView:(UIView*)view frameChange:(FrameChangedBlock)frameChange
{
    self = [super init];
    if (self) {
        self.frameChangedBlock = frameChange;
        [self setPlayerItemWithPath:path];
        
        self.player = [AVPlayer playerWithPlayerItem:self.item];
        self.view = view;
        self.layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [self.view.layer addSublayer:self.layer];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [self.item removeObserver:self forKeyPath:@"status"];
}

- (void)playerItemStalled:(NSNotification *)notification
{
//    NSLog(@"STALLING");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player play];
    });
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    NSLog(@"REACHED END");
    [self.player seekToTime:kCMTimeZero];
    [self playVideo];
}

- (void)setURL:(NSURL *)url
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.layer removeFromSuperlayer];
        if (url) {
            [self.view.layer addSublayer:self.layer];
        }
        [self setPlayerItemwithURL:url];
        [self.player replaceCurrentItemWithPlayerItem:self.item];
        [self.player seekToTime:kCMTimeZero];
    });
}

- (void)setPath:(NSString *)path
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.layer removeFromSuperlayer];
        if (path) {
            [self.view.layer addSublayer:self.layer];
        }
        [self setPlayerItemWithPath:path];
        [self.player replaceCurrentItemWithPlayerItem:self.item];
        [self.player seekToTime:kCMTimeZero];
    });
}

- (void) playVideo
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.view.alpha = 1;
        [self.player play];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self.item && [keyPath isEqualToString:@"status"]) {
        NSLog(@"STATUS CHANGED");
        switch (self.item.status) {
            case AVPlayerItemStatusReadyToPlay: {
                [self.layer setFrame:self.view.bounds];
                [self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                [self reframe];
                [self playVideo];
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

@end
