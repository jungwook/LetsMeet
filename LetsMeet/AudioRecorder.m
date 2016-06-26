//
//  AudioRecorder.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 25..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AudioRecorder.h"
#import "DisplayLinkView.h"

@interface AudioRecorder()
@property (weak, nonatomic) IBOutlet UIButton *playBut;
@property (weak, nonatomic) IBOutlet UIButton *sendBut;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leading;
@property (strong, nonatomic) NSURL *recordURL;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) CADisplayLink *playbackLink;
@property (weak, nonatomic) IBOutlet UILabel *sec2;
@property (weak, nonatomic) IBOutlet UILabel *sec1;
@property (weak, nonatomic) IBOutlet UILabel *min1;
@property (weak, nonatomic) IBOutlet DisplayLinkView *equalizer;
@property (nonatomic) NSTimeInterval playbackTime;
@end


@implementation AudioRecorder

+(instancetype)audioRecorderWithErrorBlock:(AudioRecorderErrorBlock)errorBlock sendBlock:(AudioRecorderSendAudioBlock)sendBlock onView:(UIView*)parent
{
    AudioRecorder *ar = [[[NSBundle mainBundle] loadNibNamed:@"AudioRecorder" owner:self options:nil] firstObject];
    [ar setErrorBlock:errorBlock sendBlock:sendBlock];

    [parent addSubview:ar];
    ar.frame = parent.bounds;
    ar.layer.cornerRadius = ar.frame.size.height / 2.f;

    return ar;
}

- (void) sendBackError
{
    _ready = NO;
    if (_errorBlock)
        self.errorBlock();
}

- (void) initializeAVSessionAndRecorder
{
    static BOOL init = NO;
    if (init) {
        _ready = YES;
    }
    
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if (sessionError) {
        NSLog(@"ERROR:%@", sessionError.localizedDescription);
        [self sendBackError];
        return;
    }
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            [[AVAudioSession sharedInstance] setActive: YES error: nil];
        }
        else {
            NSLog(@"ERROR: permission not granted!");
            [self sendBackError];
        }
    }];
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    
    if (!self.recordURL) {
        NSString *filename = [randomObjectId() stringByAppendingString:@".caf"];
        self.recordURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filename]];
    }
    
    self.recorder = [[AVAudioRecorder alloc]
                     initWithURL:self.recordURL
                     settings:@{
                                AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                AVEncoderAudioQualityKey : @(AVAudioQualityMedium),
                                AVSampleRateConverterAudioQualityKey : @(AVAudioQualityMedium),
                                AVNumberOfChannelsKey : @(1),
                                AVSampleRateKey : @(22050.0)
                                }
                     error:&error];
    [self.recorder setMeteringEnabled:YES];
    
    if (error || ![self.recorder prepareToRecord]) {
        NSLog(@"ERROR:%@", error.localizedDescription);
        [self sendBackError];
    }
    
    init = YES;
    _ready = YES;
}

- (void)setErrorBlock:(AudioRecorderErrorBlock)errorBlock sendBlock:(AudioRecorderSendAudioBlock)sendBlock
{
    self.errorBlock = errorBlock;
    self.sendBlock = sendBlock;
}

- (void)awakeFromNib
{
    __LF
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self translatesAutoresizingMaskIntoConstraints];
    [self initializeAVSessionAndRecorder];
    
    UIView *backdrop = [UIView new];
    backdrop.layer.cornerRadius = self.layer.bounds.size.height / 2.f;
    backdrop.backgroundColor = self.backgroundColor;
    backdrop.layer.masksToBounds = YES;
    backdrop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [backdrop translatesAutoresizingMaskIntoConstraints];
    
    [self insertSubview:backdrop atIndex:0];
    self.equalizer.isRecording = YES;
}

- (void)layoutSubviews
{
    __LF
}

- (void)selectPlayBut
{
    self.playBut.selected = NO;
}

- (void)selectPauseBut
{
    self.playBut.selected = YES;
}

- (void)enablePlayBut:(BOOL)enable
{
    self.playBut.enabled = enable;
    self.playWidth.constant = enable ? 40 : 25;
    self.playHeight.constant = enable ? 40 : 25;
    self.leading.constant = 5 - (enable ? (40-25)/2.0f : 0);
    [UIView animateWithDuration:0.25 animations:^{
        [self.playBut layoutIfNeeded];
    }];
}

- (IBAction)sendAudio:(id)sender {
    [self pausePlayer];
    if (self.sendBlock) {
        NSData *original = [NSData dataWithContentsOfURL:self.recordURL];
        NSData *thumbnail = self.equalizer.audioData;
        self.sendBlock(thumbnail, original);
    }
}

- (void) startDisplayLink
{
    self.equalizer.audioData = [NSMutableData data];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) stopDisplayLink
{
    [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink = nil;
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

- (void) startRecording
{
    self.playbackTime = 0;
    
    [self pausePlayer];
    [self enablePlayBut:NO];
    [self.recorder record];
    [self startDisplayLink];
    [self.equalizer setIsRecording:YES];
}

- (void)stopRecording
{
    [self enablePlayBut:YES];
    [self.recorder stop];
    [self stopDisplayLink];
    [self.equalizer setIsRecording:NO];

    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordURL error:&error];
    self.player.delegate = self;
    if (!error) {
        [self.player prepareToPlay];
    }
    else {
        NSLog(@"ERROR:%@", error.localizedDescription);
    }
}

- (IBAction)playPauseRecording:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected) { //PLAY AUDIO
        [self playPlayer];
    }
    else { // PAUSE AUDIO
        [self pausePlayer];
    }
}
 
- (void)playPlayer
{
    [self selectPauseBut];
    [self.player play];
    [self startPlaybackLink];
}

- (void)pausePlayer
{
    self.playbackTime = self.player.currentTime;
    NSLog(@"CURRENT:%f", self.playbackTime);
    
    [self.player pause];
    [self selectPlayBut];
    [self stopPlaybackLink];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        [self selectPlayBut];
        [self.equalizer setProgress:1.0f];
        [self.equalizer setNeedsDisplay];
        [self stopPlaybackLink];
    }
}

#define resolution (2^(sizeof(unichar)*8))

- (void) updatePlayback
{
    static int count = 0;
    
    if (count++ % 5)
        return;
    
    
    NSTimeInterval now = self.player.currentTime;
    NSTimeInterval dur = self.player.duration;
    
    self.equalizer.progress = dur > 0 ? now / dur : 0;
    [self updateTimerDisplayWithTime:self.player.currentTime];
    [self.equalizer setNeedsDisplay];
}

- (void) updateDisplay
{
    static int count = 0;
    
    if (count++ % 5)
        return;
    [self.recorder updateMeters];
    
    float amp = pow(10., 0.05 * MIN([self.recorder averagePowerForChannel:0],0));
    int ch = amp*256;

    [self.equalizer.audioData appendBytes:&ch length:1];
    [self updateTimerDisplayWithTime:self.recorder.currentTime];
    [self.equalizer setNeedsDisplay];
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
