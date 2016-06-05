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
@end

@implementation Notifications


- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newBroadcast:)
                                                     name:@"NotifySystemOfBroadcast"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newMessage:)
                                                     name:@"NotifySystemOfNewMessage"
                                                   object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"NotifySystemOfBroadcast"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"NotifySystemOfNewMessage"
                                                  object:nil];
}

- (void) newBroadcast:(NSNotification*)userInfo
{
    id notif = userInfo.object;
    
    id senderId = notif[@"senderId"];
    NSString* message = notif[@"message"];
    NSNumber* duration = notif[@"duration"];

    if (self.broadcastAction)
        self.broadcastAction(senderId, message, [duration doubleValue]);
}

- (void) newMessage:(NSNotification*)userInfo
{
    if (self.bulletAction) {
        self.bulletAction(userInfo.object);
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

@end
