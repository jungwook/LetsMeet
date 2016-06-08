//
//  AppDelegate.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 12..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "FileSystem.h"
#import "NSMutableDictionary+Bullet.h"
#import "SimulatedUsers.h"


@interface AppDelegate ()
@property (nonatomic, strong) FileSystem *system;
@end

@implementation AppDelegate

- (void)setupAWSCredentials
{
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:cf811cfd-3215-4274-aec5-82040e033bfe"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast2 credentialsProvider:credentialsProvider];
    configuration.maxRetryCount = 3;
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    [AWSLogger defaultLogger].logLevel = AWSLogLevelError;
}

- (void)testFileUpAndDownLoads
{
    UIImage *image = [UIImage imageNamed:@"image"];
    NSData *data = UIImagePNGRepresentation(image);
    
    NSURL *outputURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"image.png"];
    
    BOOL ret = [data writeToURL:outputURL atomically:YES];
    
    NSLog(@"UPLOADED DATA:%ld", data.length);
    if (ret) {
        NSLog(@"IMAGE ON DISK URL :%@", outputURL);
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.bucket = @"parsekr";
        uploadRequest.key = @"test/image.png";
        uploadRequest.body = outputURL;
        
        [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                           withBlock:^id(AWSTask *task) {
                                                               if (task.error != nil) {
                                                                   NSLog(@"%s %@","Error uploading :", uploadRequest.key);
                                                               }
                                                               else { NSLog(@"Upload completed"); }
                                                               return nil;
                                                           }];
    }
    
    
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"download.png"];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    [[NSFileManager defaultManager] removeItemAtURL:downloadingFileURL error:nil];
    
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = @"parsekr";
    downloadRequest.key = @"image.png";
    downloadRequest.downloadingFileURL = downloadingFileURL;
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    NSLog(@"Download started, please wait...");
    
    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                           withBlock:^id(AWSTask *task){
                                                               if (task.error != nil) {
                                                                   NSLog(@"%s %@","Error downloading :", downloadRequest.key);
                                                               }
                                                               else {
                                                                   NSLog(@"download completed");
                                                                   
                                                                   NSData *downloadedData = [NSData dataWithContentsOfURL:downloadingFileURL];
                                                                   NSLog(@"DOWNLOADED:%ld", downloadedData.length);
                                                               }
                                                               return nil;
                                                           }];
    

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setupAWSCredentials];
//    [self testFileUpAndDownLoads];
    
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
    
    PFACL *defaultACL = [PFACL ACL];
    
    defaultACL.publicReadAccess = YES;
    defaultACL.publicWriteAccess = YES;
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
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
    
    // Extract the notification data
    NSDictionary *payload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (payload) {
        NSLog(@"PAYLOAD:%@", payload);
    }
    
    self.system = [FileSystem new];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"Background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"Foreground");
    
    [self.system fetchOutstandingBullets];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
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
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
        [self.system timeKeep];
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self.system treatPushNotificationWith:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

+ (AppDelegate *)globalDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

+ (void) toggleMenu
{
    [[[self globalDelegate] mainMenu] toggleDrawerWithSide:FloatingDrawerSideLeft animated:YES completion:nil];
}

+ (void) toggleMenuWithScreenID:(NSString *)screen
{
    [[self globalDelegate].mainMenu selectScreenWithID:screen];
}

+ (NSDictionary*) screens
{
    return [self globalDelegate].mainMenu.screens;
}

@end
