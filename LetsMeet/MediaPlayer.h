//
//  MediaPlayer.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 7..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface MediaPlayer : NSObject
+ (instancetype)playerWithURL:(NSURL *)URL onView:(UIView *)view;
- (void)setURL:(NSURL*) url;
@end
