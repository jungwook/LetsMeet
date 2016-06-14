//
//  Notifications.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^BroadcastBlock)(id senderId, NSString* message, NSTimeInterval duration);
typedef void(^BulletBlock)(id bullet);
typedef void(^RefreshBadgeBlock)();

@interface Notifications : NSObject
- (void)setBulletAction:(BulletBlock)bulletAction;
- (void)setBroadcastAction:(BroadcastBlock)broadcastAction;
- (void)setRefreshBadgeAction:(RefreshBadgeBlock)refreshBadgeAction;
+ (instancetype) notificationWithMessage:(BulletBlock)block broadcast:(BroadcastBlock)broadcast refresh:(RefreshBadgeBlock)refresh;
- (void)off;
- (void)on;
@end
