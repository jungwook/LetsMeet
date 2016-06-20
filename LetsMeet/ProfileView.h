//
//  ProfileView.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSMutableDictionary+Bullet.h"
#import "S3File.h"

typedef void(^FrameChangedBlock)(CGSize size);

@interface ProfileView : UIView
- (void) setMediaFromUser:(User*)user;
- (void) setMediaFromUser:(User*)user frameBlock:(FrameChangedBlock)frameBlock;
- (void) setPlayerItemURL:(NSURL *)url;
- (void) pause;
@end
