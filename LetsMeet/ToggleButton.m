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
        [self updateBadge];
    } broadcast:^(id senderId, NSString *message, NSTimeInterval duration) {
        [self updateBadge];
    } refresh:^{
        [self updateBadge];
    }];
    
    [self.notification on];
    
    self.action = @selector(toggleMenu:);
    [self updateBadge];
}

- (void) updateBadge
{
    __LF
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger count = (unsigned long)self.system.unreadMessages;
        
        self.badgeValue = [NSString stringWithFormat:@"%ld", count];
    });
}

- (void) toggleMenu:(id)sender
{
    __LF
    [AppDelegate toggleMenu];
}

@end
