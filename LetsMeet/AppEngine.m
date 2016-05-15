//
//  AppEngine.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AppEngine.h"
@interface AppEngine()
@property BOOL isNewInstallation;
@end

@implementation AppEngine

+ (id) engine
{
    static id sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[self alloc] init];
    });
    return sharedFile;
}

- (id)init
{
    self = [super init];
    if (self) {
//        [[NSUserDefaults standardUserDefaults] objectForKey:@"IsNewInstallation"];
        NSLog(@"USER DEF:%@", [NSUserDefaults standardUserDefaults]);
        
    }
    return self;
}

- (void) initUserSystem
{
    if (![PFUser currentUser]) {
    }
}

- (BOOL) isLoggedIn
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"IsNewInstallation"] isEqualToString:@"NO"]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void) logIn
{
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IsNewInstallation"];
}

@end



