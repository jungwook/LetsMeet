//
//  AudioRecorder.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 25..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AudioRecorderErrorBlock)(void);
typedef void(^AudioRecorderSendAudioBlock)(NSData* thumbnail, NSData *original);

@interface AudioRecorder : UIView <AVAudioRecorderDelegate, AVAudioPlayerDelegate, AVAudioSessionDelegate>
@property (nonatomic, readonly) BOOL ready;
@property (nonatomic, copy) AudioRecorderErrorBlock errorBlock;
@property (nonatomic, copy) AudioRecorderSendAudioBlock sendBlock;
- (void) startRecording;
- (void) stopRecording;
- (void) setErrorBlock:(AudioRecorderErrorBlock)errorBlock sendBlock:(AudioRecorderSendAudioBlock)sendBlock;
+ (instancetype) audioRecorderWithErrorBlock:(AudioRecorderErrorBlock)errorBlock sendBlock:(AudioRecorderSendAudioBlock)sendBlock onView:(UIView*)parent;
@end
