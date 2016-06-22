//
//  FileSystem.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 4..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "FileSystem.h"
//#import "Signup.h"

#define CHATFILEEXTENSION @".ChatFile"
#define OBJECTIDSTORE @"ObjectIdStore"
#define SYSTEM_PATH_COMPONENT @"Engine"
#define SYSTEM_USER_PATH_COMPONENT @"Users"
#define SYSTEM_MESSAGES_PATH_COMPONENT @"Messages"

@interface ObjectIdStore : NSObject
+ (BOOL) addObjectId:(id)objectId;
+ (BOOL) containsObjectId:(id)objectId;
@end


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
@property (nonatomic, strong) NSTimer *timeKeeper;

@property (nonatomic, strong) NSObject *lock;
@end

@implementation FileSystem 

+ (instancetype) new
{
    static id sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[self alloc] initOnce];
    });
    return sharedFile;
}

- (instancetype)initOnce
{
    __LF
    self = [super init];
    if (self) {
        [self initializeSystem];
        self.lock = [NSObject new]; //MUTEX LOCK
    }
    return self;
}


- (void) initializeSystem
{
    __LF
    NSError *error = nil;
    
    self.applicationPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    self.systemPath = [self.applicationPath URLByAppendingPathComponent:SYSTEM_PATH_COMPONENT];
    self.usersPath = [self.systemPath URLByAppendingPathComponent:SYSTEM_USER_PATH_COMPONENT];
    self.messagesDirectoryPath = [self.systemPath URLByAppendingPathComponent:SYSTEM_MESSAGES_PATH_COMPONENT];
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
    self.timeKeeper = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                       target:self
                                                     selector:@selector(timeKeep)
                                                     userInfo:nil
                                                      repeats:YES];
    
    
}

- (void) timeKeep
{
    static int count = 0;
    
    if ((++count)%10 == 0  && self.isSimulator) {
        __LF
        [self fetchOutstandingBullets];
    }
}

- (NSArray*)usersInTheSystem
{
    __LF

    return [self.bullets allKeys];
}

- (NSMutableArray*)bulletsWith:(id)userId
{
//    __LF
    NSMutableArray *bullets = [self.bullets objectForKey:userId];
    if (!bullets) {
        bullets = [NSMutableArray array];
        [self.bullets setObject:bullets forKey:userId];
    }
    return [self.bullets objectForKey:userId];
}

/**
 messages array converted to a "read only" NSArray of messages for the user. It will only pass a reflection of the underlying system array of messages for the user with userId.
 
 **/

- (NSArray*) messagesWith:(id)userId
{
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    return [[self.bullets objectForKey:userId] sortedArrayUsingDescriptors:@[sd]];
}

- (NSString*)usersFilename
{
    __LF

    return [self.usersPath path];
}


#define FIXBULLETTYPEISSUE
#undef FIXBULLETTYPEISSUE

- (void)load
{
    __LF

    NSError *error = nil;

    NSArray *fileURLs = [self.manager contentsOfDirectoryAtURL:self.messagesDirectoryPath includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    
    [fileURLs enumerateObjectsUsingBlock:^(NSURL* _Nonnull url, NSUInteger idx, BOOL * _Nonnull stop)
    {
        NSString *filename = [url lastPathComponent];
        if ([filename containsString:CHATFILEEXTENSION]) {
            NSString *userId = [filename stringByReplacingOccurrencesOfString:CHATFILEEXTENSION withString:@""];
            NSMutableArray *bullets = [NSMutableArray arrayWithContentsOfURL:url];
            
#ifdef FIXBULLETTYPEISSUE
            [bullets enumerateObjectsUsingBlock:^(Bullet*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.mediaType = [obj[@"bulletType"] integerValue];
            }];
#endif
            [self.bullets setObject:bullets ? bullets : [NSMutableArray array] forKey:userId];
        }
        else {
            
        }
        
    }];
    
#ifdef FIXBULLETTYPEISSUE
    [self save];
#endif
}

- (BOOL)save
{
    __LF

    [self.usersInTheSystem enumerateObjectsUsingBlock:^(id _Nonnull userId, NSUInteger idx, BOOL * _Nonnull stop) {
        [self saveUser:userId];
    }];
    return YES;
}

- (BOOL)saveUser:(id)userId
{
    __LF

    @synchronized (self.lock) {
        NSString *filename = [userId stringByAppendingString:CHATFILEEXTENSION];
        NSURL *userMessagesPath = [self.messagesDirectoryPath URLByAppendingPathComponent:filename];
        return [[self bulletsWith:userId] writeToURL:userMessagesPath atomically:YES];
    };
}

- (BOOL)removeUser:(id)userId
{
    __LF
    @synchronized (self.lock) {
        NSError *error = nil;
        
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
}

- (void)add:(Bullet *)bullet for:(id)userId
{
    __LF
    
    bullet.isRead = NO;
    bullet.isSyncFromUser = YES;
    bullet.isSyncToUser = [bullet isFromMe];
    bullet.fromUserId = self.me.objectId;
    bullet.toUserId = userId;
    BulletObject *object = [bullet object];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            bullet.objectId = object.objectId;
            bullet.createdAt = object.createdAt;
            bullet.updatedAt = object.updatedAt;
            [[self bulletsWith:userId] addObject:bullet];
            BOOL ret = [self saveUser:userId];
            if (ret) {
                [self notifySystemOfNewMessage:bullet];
                [self sendPushMessage:bullet.message messageId:bullet.objectId toUserId:bullet.toUserId];
            }
            else {
                NSLog(@"ERROR: Could not save local repository file. Probably due to non-serializable objects in the bullet");
            }
        }
    }];
}

- (void) update:(Bullet *)message for:(id)userId
{
    __LF

    NSMutableArray *userMessages = [self bulletsWith:userId];
    
    [userMessages enumerateObjectsUsingBlock:^(Bullet* _Nonnull bullet, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([bullet.objectId isEqualToString:message.objectId]) {
            [userMessages removeObjectAtIndex:idx];
            [userMessages insertObject:message atIndex:idx];
            
            [self notifySystemOfNewMessage:message];
            *stop = YES;
        }
    }];
    [self saveUser:userId];
}

- (void)addMessageFromObject:(BulletObject*) object
{
    __LF

    Bullet *bullet = [object bullet];
    
    NSLog(@"BULLET RECEIVED:%@", bullet);
    NSLog(@"object RECEVIED:%@", object);
    
    // TODO DO SOMETHING ABOUT THE MEDIA SENT
    // ALSO DO SOMETHING ABOUT THE FILE ATTRIBUTE... SHOULD BE SOMETHING LIKE MEDIA
    
    NSMutableArray *userMessages = [self bulletsWith:object.fromUser.objectId];
    [userMessages addObject:bullet];
    
    // SET ISSYNCTOUSER TO YES SO THAT I DO NOT RELOAD THE SAME MESSAGE
    BOOL mine = [object.toUser.objectId isEqualToString:self.me.objectId];
    if (mine) {
        object.isSyncToUser = YES;
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self notifySystemOfNewMessage:bullet];
            }
        }];
    }
}

- (void)addMessageFromObjectId:(id)objectId
{
    __LF

    BulletObject *object = [BulletObject objectWithoutDataWithObjectId:objectId];
    [object fetchInBackgroundWithBlock:^(PFObject * _Nullable obj, NSError * _Nullable error) {
        [self addMessageFromObject:object];
    }];
}

- (void) sendPushMessage:textToSend messageId:(id)messageId toUserId:(id)userId
{
    __LF
    const NSInteger maxLength = 100;
    NSUInteger length = [textToSend length];
    if (length >= maxLength) {
        textToSend = [textToSend substringToIndex:maxLength];
        textToSend = [textToSend stringByAppendingString:@"..."];
    }
    
    [PFCloud callFunctionInBackground:@"sendPushToUser"
                       withParameters:@{
                                        @"recipientId": userId,
                                        @"senderId":    self.me.objectId,
                                        @"message":     textToSend,
                                        @"messageId":   messageId,
                                        @"pushType":    @"pushTypeMessage"
                                        }
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        
                                    }
                                    else {
                                        NSLog(@"ERROR SENDING PUSH:%@", error.localizedDescription);
                                    }
                                }];
}

+ (void) sendBroadcastMessage:(NSString*)message duration:(NSNumber*)duration
{
    __LF

    User *me = [User me];
    
    [PFCloud callFunctionInBackground:@"broadcastMessage"
                       withParameters:@{
                                        @"senderId":    me.objectId,
                                        @"message":     message,
                                        @"duration":    duration,
                                        @"pushType":    @"pushTypeBroadcast"
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

- (void) fetchOutstandingBullets
{
    __LF

    NSLog(@"Fetching Outstanding Bullets");
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"( fromUser == %@ AND isSyncFromUser != true) OR (toUser == %@ AND isSyncToUser != true)",
                              self.me,
                              self.me];
    
    
    PFQuery *query = [BulletObject queryWithPredicate:predicate];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable bullets, NSError * _Nullable error) {
        [bullets enumerateObjectsUsingBlock:^(BulletObject* _Nonnull bullet, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addMessageFromObjectId:bullet.objectId];
        }];
    }];
}

- (void) treatPushNotificationWith:(NSDictionary *)userInfo
{
    __LF

    FileSystem* system = [FileSystem new];
    if ([userInfo[@"pushType"] isEqualToString:@"pushTypeMessage"]) {
        [system addMessageFromObjectId:userInfo[@"messageId"]];
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"pushTypeBroadcast"]) {
        [system notifySystemOfBroadcast:userInfo];
    }
}

- (void) notifySystemToRefreshBadge
{
    __LF
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifySystemToRefreshBadge" object:nil];
}

- (void) notifySystemOfBroadcast:(id)userInfo
{
    __LF

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifySystemOfBroadcast" object:userInfo];
}

- (void) notifySystemOfNewMessage:(id)bullet
{
    __LF

    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifySystemOfNewMessage" object:bullet];
}

- (void) readUnreadBulletsWithUserId:(id)userId
{
    __LF

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"toUser == %@ AND isRead == NO", self.me.objectId];
    NSArray *unreadBullets = [[self bulletsWith:userId] filteredArrayUsingPredicate:predicate];
    [unreadBullets enumerateObjectsUsingBlock:^(Bullet* _Nonnull bullet, NSUInteger idx, BOOL * _Nonnull stop) {
        bullet.isRead = YES;
    }];
    
    if ([self saveUser:userId]) {
        [self notifySystemToRefreshBadge];
        [self resetInstallationBadge];
    }
}

- (NSUInteger) unreadMessages
{
    __LF

    __block NSUInteger count = 0;
    [[self usersInTheSystem] enumerateObjectsUsingBlock:^(id _Nonnull userId, NSUInteger idx, BOOL * _Nonnull stop) {
        count = count + [self unreadMessagesFromUser:userId];
    }];
    
    NSLog(@"UNREAD COUNT:%ld", count);
    return count;
}

- (NSUInteger) unreadMessagesFromUser:(id)userId
{
//    __LF

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"toUser == %@ AND isRead == NO", self.me.objectId];
    return [[[self bulletsWith:userId] filteredArrayUsingPredicate:predicate] count];
}

- (void) resetInstallationBadge
{
    __LF

    NSUInteger count = [self unreadMessages];
    PFInstallation *install = [PFInstallation currentInstallation];
    if (install.badge != count) {
        [install setBadge:count];
        [install saveInBackground];
    }
}

- (void)usersNearMeInBackground:(UsersArrayBlock)block
{
    __LF
    
    PFQuery *query = [User query];
    [query whereKey:@"location" nearGeoPoint:self.me.location];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (block)
            block(users);
    }];
}

- (void)usersNearMeInBackground2:(UsersArrayBlock)block
{
    __LF

    PFQuery *query = [User query];
    [query whereKey:@"location" nearGeoPoint:self.me.location];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (block)
            block([users sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                PFGeoPoint *p1 = ((User*)obj1).location;
                PFGeoPoint *p2 = ((User*)obj2).location;

                CGFloat distanceA = [self.me.location distanceInKilometersTo:p1];
                CGFloat distanceB = [self.me.location distanceInKilometersTo:p2];
                
                if (distanceA < distanceB) {
                    return NSOrderedAscending;
                } else if (distanceA > distanceB) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }]);
    }];
}

- (PFGeoPoint*) location
{
    __LF

    return [PFGeoPoint geoPointWithLocation:self.currentLocation];
}

/**
The - (void) initLocationServices method initializes the location management system
 **/

- (void) initLocationServices
{
    __LF

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
    __LF

    CLLocation* location = [locations lastObject];
    self.currentLocation = location;
    
    PFGeoPoint *geo = [PFGeoPoint geoPointWithLocation:location];
    [self.me setObject:geo forKey:@"location"];
    [self.me setObject:location.timestamp forKey:@"locationUpdatedAt"];
    [self.me saveInBackground];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    __LF

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
            [self.locationManager startMonitoringSignificantLocationChanges];
            break;
        default:
            break;
    }
}

+ (NSString *) objectId {
    FileSystem *system = [FileSystem new];
    
    @synchronized (system.lock) {
        NSString *randId = @"";
        do {
            randId = randomObjectId();
        } while ([ObjectIdStore containsObjectId:randId]);
        [ObjectIdStore addObjectId:randId];
        
        return randId;
    }
}

- (NSString *) createObjectId {
    @synchronized (_lock) {
        NSString *randId = @"";
        do {
            randId = randomObjectId();
        } while ([ObjectIdStore containsObjectId:randId]);
        [ObjectIdStore addObjectId:randId];
        
        return randId;
    }
}


@end
@interface ObjectIdStore()
@property (nonatomic, strong) NSMutableSet *objectIdSet;
@property (nonatomic, strong) NSObject *lock;
@property (nonatomic, strong) NSURL *systemPath;
@end

@implementation ObjectIdStore

+ (instancetype) new
{
    static id sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[self alloc] initOnce];
    });
    return sharedFile;
}


- (instancetype)initOnce
{
    __LF
    self = [super init];
    if (self) {
        self.systemPath = [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:SYSTEM_PATH_COMPONENT] URLByAppendingPathComponent:OBJECTIDSTORE];
        self.objectIdSet = [NSMutableSet setWithArray:[NSArray arrayWithContentsOfURL:self.systemPath]];
        self.lock = [NSObject new]; //MUTEX LOCK
    }
    return self;
}

+ (BOOL) addObjectId:(id)objectId
{
    ObjectIdStore *store = [ObjectIdStore new];
    return [store addObjectId:objectId];
}

- (BOOL) addObjectId:(id)objectId
{
    @synchronized (self.lock) {
        [self.objectIdSet addObject:objectId];
        return [[self.objectIdSet allObjects] writeToURL:self.systemPath atomically:YES];
    }
}

+ (BOOL) containsObjectId:(id)objectId
{
    ObjectIdStore *store = [ObjectIdStore new];
    return [store containsObjectId:objectId];
}

- (BOOL) containsObjectId:(id)objectId
{
    return [self.objectIdSet containsObject:objectId];
}



@end

