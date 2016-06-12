//
//  FileSystem.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 4..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "FileSystem.h"
#import "CachedFile.h"
#import "Signup.h"

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
//        [PFUser logOut];
        
        self.lock = [NSObject new]; //MUTEX LOCK
        self.me = [User me];
        
        if (self.me) {
            [self.me fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                [self initializeSystem];
            }];
        }
        else {
            [User createMe];
            [self initializeSystem];
        }
    }
    return self;
}

- (void) initializeSystem
{
    __LF
    NSError *error = nil;
    
    NSLog( @"LOCAL:%@", [self createObjectId]);
    NSLog( @"LOCAL:%@", [self createObjectId]);
    NSLog( @"LOCAL:%@", [self createObjectId]);
    NSLog( @"LOCAL:%@", [self createObjectId]);
    NSLog( @"LOCAL:%@", [self createObjectId]);
    NSLog( @"LOCAL:%@", [self createObjectId]);
    NSLog( @"LOCAL:%@", [self createObjectId]);
    NSLog( @"LOCAL:%@", [self createObjectId]);
    NSLog( @"LOCAL:%@", [self createObjectId]);
    NSLog( @"LOCAL:%@", [self createObjectId]);
    NSLog( @"LOCAL:%@", [self createObjectId]);

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
    self.timeKeeper = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                       target:self
                                                     selector:@selector(timeKeep)
                                                     userInfo:nil
                                                      repeats:NO];
}

- (void) timeKeep
{
    static int count = 0;
    
    if ((++count)%10 == 0  && self.isSimulator) {
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
    __LF
    
    return [self.bullets objectForKey:userId];
}

/**
 messages array converted to a "read only" NSArray of messages for the user. It will only pass a reflection of the underlying system array of messages for the user with userId.
 
 **/

- (NSArray*) messagesWith:(id)userId
{
    __LF

    return [self.bullets objectForKey:userId];
}

- (NSString*)usersFilename
{
    __LF

    return [self.usersPath path];
}

- (void)load
{
    __LF

    NSError *error = nil;

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
    __LF

    [self.usersInTheSystem enumerateObjectsUsingBlock:^(id _Nonnull userId, NSUInteger idx, BOOL * _Nonnull stop) {
        [self saveUser:userId];
    }];
    return YES;
}

- (BOOL)saveUser:(id)userId
{
    __LF

    NSURL *userMessagesPath = [self.messagesDirectoryPath URLByAppendingPathComponent:userId];
    return [[self bulletsWith:userId] writeToURL:userMessagesPath atomically:YES];
}

- (BOOL)removeUser:(id)userId
{
    __LF

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

- (void)add:(Bullet *)bullet for:(id)userId thumbnail:(NSData *)thumbnail originalData:(NSData*)originalData
{
    __LF

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
            [self notifySystemOfNewMessage:bullet];
            
            [CachedFile saveData:originalData named:[bullet defaultNameForBulletType] inBackgroundWithBlock:^(PFFile *originalData, BOOL succeeded, NSError *error) {
                if (succeeded) {
                    Originals *media = [Originals new];
                    media.messageId = bullet.objectId;
                    if (originalData)
                        media.file = originalData;
                    
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
    
    // ONLY ASSIGNS FILE NAME AND URL
    // LAZY LOADING OF THE THUMBNAIL HAPPENS NOW
    
    [CachedFile getDataInBackgroundWithBlock:^(NSData *thumbnail, NSError *error, BOOL fromCache) {
        bullet.thumbnail = thumbnail; //THUMBNAIL IMAGE OF THE MEDIA SENT
        
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
    } fromFile:object.file];
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
    __LF

    __block NSUInteger count = 0;
    [[self usersInTheSystem] enumerateObjectsUsingBlock:^(id _Nonnull userId, NSUInteger idx, BOOL * _Nonnull stop) {
        count = count + [self unreadMessagesFromUser:userId];
    }];
    return count;
}

- (NSUInteger) unreadMessagesFromUser:(id)userId
{
    __LF

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"toUserId == %@ AND isRead == NO", self.me.objectId];
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
    [query whereKey:@"location" nearGeoPoint:self.location];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (block)
            block(users);
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

NSString* randomObjectId()
{
    int length = 8;
    char *base62chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    
    NSString *code = @"";
    
    for (int i=0; i<length; i++) {
        int rand = arc4random_uniform(36);
        code = [code stringByAppendingString:[NSString stringWithFormat:@"%c", base62chars[rand]]];
    }
    
    return code;
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
        self.systemPath = [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"Engine"] URLByAppendingPathComponent:@"ObjectIdStore"];
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

