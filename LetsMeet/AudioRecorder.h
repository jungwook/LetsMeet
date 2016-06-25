//
//  AudioRecorder.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 25..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AudioRecorderErrorBlock)(void);
typedef void(^AudioRecorderSendAudio)(NSURL *url);

@interface AudioRecorder : UIView <AVAudioRecorderDelegate, AVAudioPlayerDelegate, AVAudioSessionDelegate>
@property (nonatomic, readonly) BOOL ready;
@property (nonatomic, copy) AudioRecorderErrorBlock errorBlock;
@property (nonatomic, copy) AudioRecorderSendAudio sendBlock;
- (void) startRecording;
- (void) stopRecording;
@end
