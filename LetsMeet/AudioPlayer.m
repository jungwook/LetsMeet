//
//  AudioPlayer.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 26..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AudioPlayer.h"
#import "DisplayLinkView.h"
#import "S3File.h"

@interface AudioPlayer()
@property (weak, nonatomic) IBOutlet UIButton *playBut;
@property (weak, nonatomic) IBOutlet DisplayLinkView *displayLink;
@property (weak, nonatomic) IBOutlet UILabel *sec2;
@property (weak, nonatomic) IBOutlet UILabel *sec1;
@property (weak, nonatomic) IBOutlet UILabel *min1;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) CADisplayLink *playbackLink;
@property (strong, nonatomic) NSString* audioFile;
@end

@implementation AudioPlayer


+ (instancetype)audioPlayerOnView:(UIView *)view
{
    AudioPlayer *ar = [[[NSBundle mainBundle] loadNibNamed:@"AudioRecorder" owner:self options:nil] objectAtIndex:1];
    [view addSubview:ar];
    ar.frame = view.bounds;
    
    return ar;
}

- (void)awakeFromNib
{
    __LF
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self translatesAutoresizingMaskIntoConstraints];
    self.playBut.selected = NO;
}

- (void)layoutSubviews
{
    __LF
    self.backgroundColor = self.superview.superview.backgroundColor;
}

- (void)setupAudioThumbnailData:(NSData*)thumbnail audioData:(NSData *)audioData
{
    NSError *audioError = nil;
    
    self.displayLink.isRecording = NO;
    self.displayLink.audioData = [NSMutableData dataWithData:thumbnail];
    [self.displayLink setNeedsDisplay];
    
    self.player = [[AVAudioPlayer alloc] initWithData:audioData error:&audioError];
    self.player.delegate = self;
    if (audioError) {
        NSLog(@"ERROR:%@", audioError.localizedDescription);
    }
    [self updateTimerDisplayWithTime:self.player.duration];
    [self.player prepareToPlay];
}

- (void)setupAudioThumbnailData:(NSData *)thumbnail audioFile:(NSString *)audioFile
{
    self.audioFile = audioFile;
    self.displayLink.isRecording = NO;
    self.displayLink.audioData = [NSMutableData dataWithData:thumbnail];
    [self.displayLink setNeedsDisplay];

    self.player = nil;
}

- (void) updatePlayback
{
    static int count = 0;
    
    if (count++ % 5)
        return;
    
    NSTimeInterval now = self.player.currentTime;
    NSTimeInterval dur = self.player.duration;
    
    self.displayLink.progress = dur > 0 ? now / dur : 0;
    [self updateTimerDisplayWithTime:self.player.currentTime];
    [self.displayLink setNeedsDisplay];
}

- (void) startPlaybackLink
{
    self.playbackLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePlayback)];
    [self.playbackLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) stopPlaybackLink
{
    [self.playbackLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.playbackLink = nil;
}

- (void) playPlayer
{
    if (self.player == nil) {
        [S3File getDataFromFile:self.audioFile completedBlock:^(NSData *audioData, NSError *error, BOOL fromCache) {
            NSError *audioError = nil;
            
            self.player = [[AVAudioPlayer alloc] initWithData:audioData error:&audioError];
            self.player.delegate = self;
            if (audioError) {
                NSLog(@"ERROR:%@", audioError.localizedDescription);
            }
            else {
                [self updateTimerDisplayWithTime:self.player.duration];
                [self.player prepareToPlay];
                self.playBut.selected = YES;
                [self.player play];
                [self startPlaybackLink];
            }
        } progressBlock:nil];
    }
    else {
        [self updateTimerDisplayWithTime:self.player.duration];
        self.playBut.selected = YES;
        [self.player play];
        [self startPlaybackLink];
    }
}

- (void) pausePlayer
{
    self.playBut.selected = NO;
    [self.player pause];
    [self stopPlaybackLink];
}

- (IBAction)playOrPauseAudio:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self playPlayer];
    }
    else {
        [self pausePlayer];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.displayLink setProgress:0.0f];
    [self.displayLink setNeedsDisplay];
    [self pausePlayer];
}

- (void) updateTimerDisplayWithTime:(NSTimeInterval) time
{
    NSUInteger minutes = ((NSUInteger)time / 60) % 60;
    NSUInteger seconds = ((NSUInteger)time) % 60;
    
    NSUInteger sec1 = seconds / 10;
    NSUInteger sec2 = seconds % 10;
    
    self.sec1.text = [NSString stringWithFormat:@"%ld", sec1];
    self.sec2.text = [NSString stringWithFormat:@"%ld", sec2];
    self.min1.text = [NSString stringWithFormat:@"%ld", minutes % 10];
}

@end
