//
//  MediaPlayer.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 7..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

typedef void(^FrameChangedBlock)(CGRect rect);

@interface MediaPlayer : NSObject
@property (nonatomic, strong) FrameChangedBlock frameChangedBlock;
+ (instancetype)playerWithPath:(NSString*)path onView:(UIView *)view frameChange:(FrameChangedBlock)frameChange;
- (void) setPath:(NSString*)path;
- (void) setURL:(NSURL*)url;
@end
