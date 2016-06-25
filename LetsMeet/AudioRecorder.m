//
//  AudioRecorder.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 25..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AudioRecorder.h"

CGFloat ampAtIndex(NSUInteger index, NSData* data)
{
    static int c = 0;
    
    if (index >= data.length)
        return 0;
    
    NSData *d = [data subdataWithRange:NSMakeRange(index, 1)];
    [d getBytes:&c length:1];
    CGFloat ret = ((CGFloat)c) / 256.0f;
    return ret;
}



@interface DisplayLinkView : UIView
@property (nonatomic, strong) NSMutableData *audioData;
@end

@implementation DisplayLinkView

- (void)awakeFromNib
{
    self.backgroundColor = self.superview.backgroundColor;
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat lineWidth = 5.f;
    const CGFloat offset = 0.5f;
    const CGFloat scale = 5;
    const CGFloat left = 0;
    const CGFloat right = 0;
    
    CGFloat w = (self.bounds.size.width-left-right)/lineWidth;
    CGFloat h = self.bounds.size.height;
    
    NSUInteger l = self.audioData.length;
    NSUInteger start = MAX(w - l, 0);
    NSUInteger rangeStart = MAX(l - w, 0);
    NSUInteger rangeLength = l - rangeStart;
    
    NSData *small = [self.audioData subdataWithRange:NSMakeRange(rangeStart, rangeLength)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextSetLineWidth(context, lineWidth-1);
    for (NSUInteger i = start; i<w; i++) {
        CGFloat amp = ampAtIndex(i-start, small)*scale;
        CGFloat val = MAX(MIN(amp*h*offset, h*offset), 1.0f);
        
        CGContextMoveToPoint(context, left+i*lineWidth, 0.5*h - val);
        CGContextAddLineToPoint(context, left+i*lineWidth, 0.5*h + val);
    }
    CGContextDrawPath(context, kCGPathStroke);
}

@end

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
@property (weak, nonatomic) IBOutlet UILabel *sec2;
@property (weak, nonatomic) IBOutlet UILabel *sec1;
@property (weak, nonatomic) IBOutlet UILabel *min1;
@property (weak, nonatomic) IBOutlet DisplayLinkView *equalizer;
@end


@implementation AudioRecorder

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

- (void)awakeFromNib
{
    __LF
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self translatesAutoresizingMaskIntoConstraints];
    [self initializeAVSessionAndRecorder];
    self.layer.cornerRadius = self.layer.bounds.size.height / 2.f;
    self.layer.masksToBounds = YES;
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
        self.sendBlock(self.recordURL);
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

- (void) startRecording
{
    [self pausePlayer];
    [self enablePlayBut:NO];
    [self.recorder record];
    [self startDisplayLink];
}

- (void)stopRecording
{
    [self enablePlayBut:YES];
    [self.recorder stop];
    [self stopDisplayLink];
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
    NSError *error = nil;
    
    [self selectPauseBut];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordURL error:&error];
    self.player.delegate = self;
    if (!error) {
        [self.player play];
    }
    else {
        NSLog(@"ERROR:%@", error.localizedDescription);
    }
}

- (void)pausePlayer
{
    [self.player pause];
    [self selectPlayBut];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        [self selectPlayBut];
    }
}

#define resolution (2^(sizeof(unichar)*8))

- (void) updateDisplay
{
    static int count = 0;
    
    if (count++ % 5)
        return;
    [self.recorder updateMeters];
    
    float amp = pow(10., 0.05 * MIN([self.recorder averagePowerForChannel:0],0));
    int ch = amp*256;

    [self.equalizer.audioData appendBytes:&ch length:1];
    
    NSTimeInterval time = self.recorder.currentTime;
    NSUInteger minutes = ((NSUInteger)time / 60) % 60;
    NSUInteger seconds = ((NSUInteger)time) % 60;
    
    NSUInteger sec1 = seconds / 10;
    NSUInteger sec2 = seconds % 10;
    
    self.sec1.text = [NSString stringWithFormat:@"%ld", sec1];
    self.sec2.text = [NSString stringWithFormat:@"%ld", sec2];
    self.min1.text = [NSString stringWithFormat:@"%ld", minutes % 10];
    
    [self.equalizer setNeedsDisplay];
}

@end
