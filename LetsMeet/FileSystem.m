//
//  FileSystem.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 4..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "FileSystem.h"
#import "CachedFile.h"

@interface FileSystem()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (nonatomic, strong) NSURL *applicationPath;
@property (nonatomic, strong) NSURL *systemPath;
@property (nonatomic, strong) NSURL *usersPath;
@property (nonatomic, strong) NSURL *messagesDirectoryPath;
@property (nonatomic, strong) NSFileManager *manager;
@property (nonatomic, strong) NSMutableDictionary *bullets;
@property (nonatomic, weak) User* me;
@end

@implementation FileSystem 

+ (instancetype) new
{
    NSLog(@"INITIALIZING FILE SYSTEM V2");
    
    static id sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[self alloc] initOnce];
    });
    return sharedFile;
}

- (instancetype)initOnce
{
    self = [super init];
    if (self) {
        NSError *error = [NSError new];
        self.me = [User me];
        
        // If me is nil then need to find a way of loging in a new user.
        
        self.applicationPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        self.systemPath = [self.applicationPath URLByAppendingPathComponent:@"Engine"];
        self.usersPath = [self.systemPath URLByAppendingPathComponent:@"Users"];
        self.messagesDirectoryPath = [self.systemPath URLByAppendingPathComponent:@"Messages"];
        self.manager = [NSFileManager defaultManager];
        self.bullets = [NSMutableDictionary dictionary];
        
        BOOL ret = [self.manager createDirectoryAtURL:self.messagesDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!ret) {
            NSLog(@"ERROR:%@", error.localizedDescription);
            NSLog(@"ERROR:%@", error.localizedRecoverySuggestion);
        } else {
            NSLog(@"SYSTEM & MESSAGES PATH[%@] SUCCESSFULLY SETUP", [self.messagesDirectoryPath path]);
        }
        [self load];
        [self initLocationServices];
    }
    return self;
}

- (NSArray*)usersInTheSystem
{
    return [self.bullets allKeys];
}

- (NSMutableArray*)bulletsWith:(id)userId
{
    return [self.bullets objectForKey:userId];
}

/**
 messages array converted to a "read only" NSArray of messages for the user. It will only pass a reflection of the underlying system array of messages for the user with userId.
 
 **/

- (NSArray*) messagesWith:(id)userId
{
    return [self.bullets objectForKey:userId];
}

- (NSString*)usersFilename
{
    return [self.usersPath path];
}

- (void)load
{
    NSError *error = [NSError new];
    NSLog(@"LOADING ALL USER MESSAGES");
    
    NSArray *fileURLs = [self.manager contentsOfDirectoryAtURL:self.messagesDirectoryPath includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    
    [fileURLs enumerateObjectsUsingBlock:^(NSURL* _Nonnull url, NSUInteger idx, BOOL * _Nonnull stop)
    {
        NSString *userId = [url lastPathComponent];
        
        NSMutableArray *bullets = [NSMutableArray arrayWithContentsOfURL:url];
        [self.bullets setObject:bullets ? bullets : [NSMutableArray array] forKey:userId];
        NSLog(@"==> LOADED MESSAGES %ld FOR USER %@", bullets.count, userId );
    }];
}

- (BOOL)save
{
    [self.usersInTheSystem enumerateObjectsUsingBlock:^(id _Nonnull userId, NSUInteger idx, BOOL * _Nonnull stop) {
        [self saveUser:userId];
    }];
    return YES;
}

- (BOOL)saveUser:(id)userId
{
    NSURL *userMessagesPath = [self.messagesDirectoryPath URLByAppendingPathComponent:userId];
    return [[self bulletsWith:userId] writeToURL:userMessagesPath atomically:YES];
}

- (BOOL)removeUser:(id)userId
{
    NSError *error = [NSError new];
    
    NSURL *userMessagesPath = [self.messagesDirectoryPath URLByAppendingPathComponent:userId];
    BOOL ret = [self.manager removeItemAtURL:userMessagesPath error:&error];
    if (ret) {
        NSUInteger count = [self bulletsWith:userId].count;
        [self.bullets removeObjectForKey:userId];
        NSLog(@"SUCCESSFULLY REMOVED %ld MESSAGES FOR USER:%@", count, userId);
    }
    else {
        NSLog(@"ERROR:%@", error.localizedDescription);
        NSLog(@"ERROR:%@", error.localizedRecoverySuggestion);
    }
    return ret;
}

- (void)add:(Bullet *)bullet for:(id)userId thumbnail:(NSData *)thumbnail originalData:(NSData*)originalData
{
    NSMutableArray *userMessages = [self bulletsWith:userId];
    
    [CachedFile saveData:thumbnail named:[bullet defaultNameForBulletType] inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
        if (succeeded) {
            bullet.isRead = NO;
            bullet.isSyncFromUser = YES;
            bullet.isSyncToUser = [bullet isFromMe];
            
            BulletObject *object = [bullet object];
            if (file) {
                object.file = file;
            }
            
            [userMessages addObject:bullet]; // ADD TO DICTIONARY SYSTEM.
            [self saveUser:userId];
            [self notifyChatSystemWithMessageId:bullet.objectId];
            
            [CachedFile saveData:originalData named:[bullet defaultNameForBulletType] inBackgroundWithBlock:^(PFFile *original, BOOL succeeded, NSError *error) {
                if (succeeded) {
                    Originals *media = [Originals new];
                    media.messageId = bullet.objectId;
                    if (original)
                        media.file = original;
                    
                    [media saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            [self sendPushMessage:bullet.message messageId:bullet.objectId toUserId:bullet.toUserId];
                        }];
                    }];
                }
                else {
                    NSLog(@"ERROR SAVING ORIGINAL MEDIA WITH ERROR:%@", error.localizedDescription);
                }
            } progressBlock:^(int percentDone) {
                // DO SOMETHING...
                printf("==>");
            }];
        }
        else {
            NSLog(@"ERROR SAVING THUMBNAIL WITH ERROR:%@", error.localizedDescription);
        }
    } progressBlock:nil];
    
}

- (void) update:(Bullet *)message for:(id)userId
{
    NSMutableArray *userMessages = [self bulletsWith:userId];
    
    [userMessages enumerateObjectsUsingBlock:^(Bullet* _Nonnull bullet, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([bullet.objectId isEqualToString:message.objectId]) {
            [userMessages removeObjectAtIndex:idx];
            [userMessages insertObject:message atIndex:idx];
            
            [self notifyChatSystemWithMessageId:message.objectId];
            *stop = YES;
        }
    }];
    [self saveUser:userId];
}

- (void)addMessageFromObjectId:(id)objectId
{
    BulletObject *object = [BulletObject new];
    object.objectId = objectId;
    
    [object fetchInBackgroundWithBlock:^(PFObject * _Nullable obj, NSError * _Nullable error) {
        
        Bullet *bullet = [object bullet];
        
        // ONLY ASSIGNS FILE NAME AND URL
        // LAZY LOADING OF THE THUMBNAIL HAPPENS NOW
        
        [CachedFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            bullet.data = data; //THUMBNAIL IMAGE OF THE MEDIA SENT
            
            NSMutableArray *userMessages = [self bulletsWith:object.fromUser.objectId];
            [userMessages addObject:bullet];
            
            [self notifyChatSystemWithMessageId:bullet.objectId];
            [self notifySystemOfNewMessage:bullet];
        } fromFile:object.file];
        
        // SET ISSYNCTOUSER TO YES SO THAT I DO NOT RELOAD THE SAME MESSAGE
        BOOL mine = [object.toUser.objectId isEqualToString:self.me.objectId];
        if (mine) {
            object.isSyncToUser = YES;
            [object saveInBackground];
        }
    }];
}

- (void) sendPushMessage:textToSend messageId:(id)messageId toUserId:(id)userId
{
    [PFCloud callFunctionInBackground:AppPushCloudAppPush
                       withParameters:@{
                                        AppPushRecipientIdField: userId,
                                        AppPushSenderIdField: self.me.objectId,
                                        AppPushMessageField: textToSend,
                                        AppPushObjectIdField: messageId,
                                        AppPushType: AppPushTypeMessage
                                        }
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        
                                    }
                                    else {
                                        NSLog(@"ERROR SENDING PUSH:%@", error.localizedDescription);
                                    }
                                }];
}



+ (void) appEngineBroadcastPush:(NSString*)message duration:(NSNumber*)duration
{
    User *me = [User currentUser];
    
    [PFCloud callFunctionInBackground:AppPushCloudAppBroadcast
                       withParameters:@{
                                        AppPushSenderIdField: me.objectId,
                                        AppPushMessageField: message,
                                        AppPushBroadcastDurationKey: duration,
                                        AppPushType: AppPushTypeBroadcast
                                        }
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"MESSAGE SENT SUCCESSFULLY:%@", message);
                                    }
                                    else {
                                        NSLog(@"ERROR SENDING PUSH:%@", error.localizedDescription);
                                    }
                                }];
}

+ (void) treatPushNotificationWith:(NSDictionary *)userInfo
{
    FileSystem* system = [FileSystem new];
    if ([userInfo[@"pushType"] isEqualToString:@"pushTypeMessage"]) {
        [system addMessageFromObjectId:userInfo[@"messageId"]];
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"pushTypeBroadcast"]) {
        [system notifySystemOfBroadcast:userInfo];
    }
}

- (void) notifySystemOfBroadcast:(id)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifySystemOfBroadcast" object:userInfo];
}

- (void) notifySystemOfNewMessage:(id)bullet
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifySystemOfNewMessage" object:bullet];
}

- (void) notifyChatSystemWithMessageId:(id)bulletId
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifyChatSystemWithMessageId" object:bulletId];
}

- (void) readUnreadBulletsWithUserId:(id)userId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"toUserId == %@ AND isRead == NO", self.me.objectId];
    NSArray *unreadBullets = [[self bulletsWith:userId] filteredArrayUsingPredicate:predicate];
    [unreadBullets enumerateObjectsUsingBlock:^(Bullet* _Nonnull bullet, NSUInteger idx, BOOL * _Nonnull stop) {
        bullet.isRead = YES;
    }];
    
    if ([self saveUser:userId]) {
        [self resetInstallationBadge];
    }
}

- (NSUInteger) unreadMessages
{
    __block NSUInteger count = 0;
    [[self usersInTheSystem] enumerateObjectsUsingBlock:^(id _Nonnull userId, NSUInteger idx, BOOL * _Nonnull stop) {
        count = count + [self unreadMessagesFromUser:userId];
    }];
    return count;
}

- (NSUInteger) unreadMessagesFromUser:(id)userId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"toUserId == %@ AND isRead == NO", self.me.objectId];
    return [[[self bulletsWith:userId] filteredArrayUsingPredicate:predicate] count];
}

- (void) resetInstallationBadge
{
    NSUInteger count = [self unreadMessages];
    PFInstallation *install = [PFInstallation currentInstallation];
    if (install.badge != count) {
        [install setBadge:count];
        [install saveInBackground];
    }
}

- (void)usersNearMeInBackground:(UsersArrayBlock)block
{
    PFQuery *query = [User query];
    [query whereKey:@"location" nearGeoPoint:self.location];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (block)
            block(users);
    }];
}

- (PFGeoPoint*) location
{
    return [PFGeoPoint geoPointWithLocation:self.currentLocation];
}

/**
The - (void) initLocationServices method initializes the location management system
 **/

- (void) initLocationServices
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestAlwaysAuthorization];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        default:
            break;
    }
    
    [self.locationManager startMonitoringSignificantLocationChanges];
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"LOCATION SERVICES ENABLED");
    }
    else {
        NSLog(@"LOCATION SERVICES NOT ENABLED");
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation* location = [locations lastObject];
    self.currentLocation = location;
    
    PFGeoPoint *geo = [PFGeoPoint geoPointWithLocation:location];
    [self.me setObject:geo forKey:@"location"];
    [self.me setObject:location.timestamp forKey:@"locationUpdatedAt"];
    [self.me saveInBackground];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            self.currentLocation = [[CLLocation alloc] initWithLatitude:37.520884 longitude:127.028360];
            break;
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestAlwaysAuthorization];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            break;
        default:
            break;
    }
}


@end

