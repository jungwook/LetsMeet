//
//  AudioPlayer.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 26..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AudioPlayer.h"
#import "DisplayLinkView.h"

@interface AudioPlayer()
@property (weak, nonatomic) IBOutlet UIButton *playBut;
@property (weak, nonatomic) IBOutlet DisplayLinkView *displayLink;
@property (weak, nonatomic) IBOutlet UILabel *sec2;
@property (weak, nonatomic) IBOutlet UILabel *sec1;
@property (weak, nonatomic) IBOutlet UILabel *min1;
@property (strong, nonatomic) AVAudioPlayer *player;
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
}

- (void)layoutSubviews
{
    __LF
    self.backgroundColor = self.superview.superview.backgroundColor;
}

- (void)setupAudioThumbnailData:(NSData*)thumbnail audioURL:(NSURL *)playURL
{
    NSError *audioError = nil;

    self.displayLink.isRecording = NO;
    self.displayLink.audioData = [NSMutableData dataWithData:thumbnail];
    [self.displayLink setNeedsDisplay];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:playURL error:&audioError];
    if (audioError) {
        NSLog(@"ERROR:%@[%@]", audioError.localizedDescription, playURL);
    }
    [self updateTimerDisplayWithTime:self.player.duration];
}

- (void)setupAudioThumbnailData:(NSData *)data
{
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
