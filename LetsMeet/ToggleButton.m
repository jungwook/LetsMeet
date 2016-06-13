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
    __LF
    
    NSLog(@"%@ %s", [self class], __FUNCTION__);
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _system = [FileSystem new];
    }
    return self;
}

- (void)awakeFromNib
{
    __LF
    
    self.notification = [Notifications notificationWithMessage:^(id bullet) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateBadge];
        });
    } broadcast:^(id senderId, NSString *message, NSTimeInterval duration) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateBadge];
        });
    }];
    
    self.action = @selector(toggleMenu:);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateBadge];
    });
}

- (void) updateBadge
{
    NSUInteger count = (unsigned long)self.system.unreadMessages;
    
    self.badgeValue = [NSString stringWithFormat:@"%ld", count == 0 ? 99 : count];
}

- (void) toggleMenu:(id)sender
{
    [AppDelegate toggleMenu];
}

@end
