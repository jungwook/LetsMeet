//
//  AppDelegate.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 12..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "NSMutableDictionary+Bullet.h"
#import "SimulatedUsers.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    __LF

    [self setupAWSCredentials];
    [Parse enableLocalDatastore];
    
    [BulletObject registerSubclass];
    [Originals registerSubclass];
    [User registerSubclass];
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"appLetsMeet";
        configuration.clientKey = @"clientLetsMeet";
        configuration.server = @"http://parse.kr:1338/parse";
    }]];
    
//    [SimulatedUsers createUsers];
    
    [self registerForNotifications:application launchOptions:launchOptions];
    [self setDefaultsForACL];
    
    return YES;
}

- (void)setDefaultsForACL
{
    PFACL *defaultACL = [PFACL ACL];
    defaultACL.publicReadAccess = YES;
    defaultACL.publicWriteAccess = YES;
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
}

- (void)setupAWSCredentials
{
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:cf811cfd-3215-4274-aec5-82040e033bfe"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast2 credentialsProvider:credentialsProvider];
    configuration.maxRetryCount = 3;
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    [AWSLogger defaultLogger].logLevel = AWSLogLevelError;
}

- (void)registerForNotifications:(UIApplication*)application launchOptions:(id)launchOptions
{
    __LF
    if (application.applicationState != UIApplicationStateBackground) {
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = !launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    NSDictionary *payload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (payload) {
        NSLog(@"PAYLOAD:%@", payload);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    __LF
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    __LF
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    __LF
    [self.system fetchOutstandingBullets];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    __LF
}

- (void)applicationWillTerminate:(UIApplication *)application {
    __LF
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    __LF
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
            [self.system fetchOutstandingBullets];
        } else {
            NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    __LF
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
        [self.system setIsSimulator:YES];
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    __LF
    [self.system treatPushNotificationWith:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

+ (AppDelegate *)globalDelegate {
    __LF
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

+ (void) toggleMenu
{
    __LF
    [[[self globalDelegate] mainMenu] toggleDrawerWithSide:FloatingDrawerSideLeft animated:YES completion:nil];
}

+ (void) toggleMenuWithScreenID:(NSString *)screen
{
    __LF
    [[self globalDelegate].mainMenu selectScreenWithID:screen];
}

+ (NSDictionary*) screens
{
    __LF
    return [self globalDelegate].mainMenu.screens;
}

@end
