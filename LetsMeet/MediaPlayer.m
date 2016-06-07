//
//  MediaPlayer.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 7..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MediaPlayer.h"

@interface MediaPlayer()
@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem *item;
@property (nonatomic, strong) AVPlayerLayer *layer;
@property (nonatomic, weak) UIView* view;
@end

@implementation MediaPlayer

+ (instancetype)playerWithURL:(NSURL *)URL onView:(UIView *)view
{
    return [[MediaPlayer alloc] initWithURL:URL onView:view];
}

- (instancetype) initWithURL:(NSURL *)URL onView:(UIView*)view
{
    self = [super init];
    if (self) {
        self.item = [AVPlayerItem playerItemWithURL:URL];
        self.player = [AVPlayer playerWithPlayerItem:self.item];
        self.view = view;
        self.layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [view.layer addSublayer:self.layer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.item];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.item];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.item];
        
        [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
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
    NSLog(@"STALLING");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.player play];
    });
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    NSLog(@"REACHED END");
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)setURL:(NSURL*) url
{
    self.item = [AVPlayerItem playerItemWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:self.item];
    [self.player seekToTime:kCMTimeZero];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self.item && [keyPath isEqualToString:@"status"]) {
        NSLog(@"STATUS CHANGED");
        switch (self.item.status) {
            case AVPlayerItemStatusReadyToPlay:
                [self.layer setFrame:self.view.bounds];
                [self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                [self.player play];
                break;
                
            case AVPlayerItemStatusFailed:
                NSLog(@"ITEM fAILED");
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"ITEM UNKNOWN");

            default:
                break;
        }
    }
}

@end
