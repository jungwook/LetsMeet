//
//  ToggleButton.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ToggleButton.h"
#import "AppEngine.h"
#import "AppDelegate.h"
#import "UIBarButtonItem+Badge.h"

@interface ToggleButton()
@end

@implementation ToggleButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateBadge)
                                                     name:AppUserNewMessageReceivedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateBadge)
                                                     name:AppUserRefreshBadgeNotificaiton
                                                   object:nil];
        
        self.action = @selector(toggleMenu:);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateBadge];
        });        
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserNewMessageReceivedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserRefreshBadgeNotificaiton
                                                  object:nil];
}

- (void) updateBadge
{
    self.badgeValue = [NSString stringWithFormat:@"%ld", (unsigned long)[AppEngine appEngineUnreadCount]];
}

- (void) toggleMenu:(id)sender
{
    [AppDelegate toggleMenu];
}


@end
