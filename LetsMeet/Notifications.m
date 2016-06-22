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
@property (nonatomic, strong) NSMutableDictionary *actions;
@end

@implementation Notifications

+ (instancetype) notification
{
    return [[Notifications alloc] init];
}

+ (instancetype) notificationWithMessage:(BulletBlock)block broadcast:(BroadcastBlock)broadcast refresh:(RefreshBadgeBlock)refresh
{
    return [[Notifications alloc] initWithMessage:block broadcast:broadcast refresh:refresh];
}

- (instancetype)init
{
    __LF
    self = [super init];
    if (self) {
        self.actions = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithMessage:(BulletBlock)block broadcast:(BroadcastBlock)broadcast refresh:(RefreshBadgeBlock)refresh
{
    __LF
    self = [self init];
    if (self) {
        self.bulletAction = block;
        self.broadcastAction = broadcast;
        self.refreshBadgeAction = refresh;
        self.actions = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) dealloc
{
    __LF
    [self off];
}

- (void)notify:(id)notification object:(id)object
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:object];
}

- (void)setNotification:(id)notification forAction:(ActionBlock)notificationActionBlock;
{
    if (notification && notificationActionBlock) {
        [self.actions setObject:notificationActionBlock forKey:notification];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notify:)
                                                     name:notification
                                                   object:nil];
    }
}

- (void)removeNotification:(id)notification
{
    if (notification) {
        [self.actions removeObjectForKey:notification];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:notification
                                                      object:nil];
    }
}

- (void) notify:(NSNotification*)notification
{
    ActionBlock action = [self.actions objectForKey:notification.name];
    if (action) {
        action(notification.object);
    }
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
