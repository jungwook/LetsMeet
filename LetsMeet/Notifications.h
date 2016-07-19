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
typedef void(^ActionBlock)(id actionParams);

@interface Notifications : NSObject
+ (instancetype) notificationWithMessage:(BulletBlock)block broadcast:(BroadcastBlock)broadcast refresh:(RefreshBadgeBlock)refresh;
+ (instancetype) notification;

- (void)notify:(id)notification object:(id)object;
- (void)setNotification:(id)notification forAction:(ActionBlock)notificationActionBlock;
- (void)removeNotification:(id)notification;

- (void)setBulletAction:(BulletBlock)bulletAction;
- (void)setBroadcastAction:(BroadcastBlock)broadcastAction;
- (void)setRefreshBadgeAction:(RefreshBadgeBlock)refreshBadgeAction;
- (void)off;
- (void)on;
@end
