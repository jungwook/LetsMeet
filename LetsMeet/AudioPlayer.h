//
//  AudioPlayer.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 26..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioPlayer : UIView
- (void)setupAudioThumbnailData:(NSData*)thumbnail audioURL:(NSURL*)playURL;
+ (instancetype)audioPlayerOnView:(UIView*)view;
@end
