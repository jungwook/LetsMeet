//
//  ToggleButton.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ToggleButton.h"
#import "UIBarButtonItem+Badge.h"
#import "NSMutableDictionary+Bullet.h"
#import "Notifications.h"

typedef void(^BulletBlock)(id bullet);
typedef void (^BulletBlock)(id bullet);

@interface ToggleButton()
@property (nonatomic, strong) Notifications *notification;
@property (nonatomic, strong) FileSystem *system;
@end

@implementation ToggleButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _system = [FileSystem new];
        self.notification = [Notifications new];
        
        __typeof(self) __weak welf = self;
        [self.notification setBulletAction:^(id bullet) {
            [welf updateBadge];
        }];
        
        [self.notification setBroadcastAction:^(id senderId, NSString *message, NSTimeInterval duration) {
            [welf updateBadge];
        }];
        
        self.action = @selector(toggleMenu:);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateBadge];
        });        
    }
    return self;
}

- (void) updateBadge
{
    self.badgeValue = [NSString stringWithFormat:@"%ld", (unsigned long)self.system.unreadMessages];
}

- (void) toggleMenu:(id)sender
{
    [AppDelegate toggleMenu];
}

@end
