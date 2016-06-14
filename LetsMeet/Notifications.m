//
//  Notifications.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Notifications.h"

@interface Notifications ()
@property (nonatomic, strong) BulletBlock bulletAction;
@property (nonatomic, strong) BroadcastBlock broadcastAction;
@property (nonatomic, strong) RefreshBadgeBlock refreshBadgeAction;
@property (nonatomic, strong) NSNumber *turnedOn;
@end

@implementation Notifications

+ (instancetype) notificationWithMessage:(BulletBlock)block broadcast:(BroadcastBlock)broadcast refresh:(RefreshBadgeBlock)refresh
{
    return [[Notifications alloc] initWithMessage:block broadcast:broadcast refresh:refresh];
}

- (instancetype)initWithMessage:(BulletBlock)block broadcast:(BroadcastBlock)broadcast refresh:(RefreshBadgeBlock)refresh
{
    __LF
    self = [super init];
    if (self) {
        self.bulletAction = block;
        self.broadcastAction = broadcast;
        self.refreshBadgeAction = refresh;
    }
    return self;
}

- (void) dealloc
{
    __LF
    [self off];
}

- (void) newBroadcast:(NSNotification*)userInfo
{
    __LF
    dispatch_async(dispatch_get_main_queue(), ^{
        id notif = userInfo.object;
        
        id senderId = notif[@"senderId"];
        NSString* message = notif[@"message"];
        NSNumber* duration = notif[@"duration"];
        
        if (self.broadcastAction) {
            self.broadcastAction(senderId, message, [duration doubleValue]);
        }
    });
}

- (void) newMessage:(NSNotification*)userInfo
{
    __LF
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.bulletAction) {
            self.bulletAction(userInfo.object);
        }
    });
}

- (void) refreshBadges:(NSNotification*)userInfo
{
    __LF
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.refreshBadgeAction) {
            self.refreshBadgeAction();
        }
    });
}

- (void)on
{
    __LF
    @synchronized (self.turnedOn) {
        if (![self.turnedOn boolValue]) {
            self.turnedOn = @(YES);
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(newBroadcast:)
                                                         name:@"NotifySystemOfBroadcast"
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(newMessage:)
                                                         name:@"NotifySystemOfNewMessage"
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(refreshBadges:)
                                                         name:@"NotifySystemToRefreshBadge"
                                                       object:nil];
        }
    }
}

- (void)off
{
    __LF
    @synchronized (self.turnedOn) {
        if ([self.turnedOn boolValue]) {
            self.turnedOn = @(NO);
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:@"NotifySystemOfBroadcast"
                                                          object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:@"NotifySystemOfNewMessage"
                                                          object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:@"NotifySystemToRefreshBadge"
                                                          object:nil];
        }
    }
}

- (void)setBulletAction:(BulletBlock)bulletAction
{
    _bulletAction = bulletAction;
}

- (void)setBroadcastAction:(BroadcastBlock)broadcastAction
{
    _broadcastAction = broadcastAction;
}

- (void)setRefreshBadgeAction:(RefreshBadgeBlock)refreshBadgeAction
{
    _refreshBadgeAction = refreshBadgeAction;
}

@end
