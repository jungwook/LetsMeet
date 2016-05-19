//
//  AppEngine.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AppEngine.h"
@interface AppEngine()
@property (nonatomic, strong) CLLocationManager *locMgr;
@property (nonatomic, strong) CLLocation* curLoc;
@property (nonatomic, strong, readonly) PFUser *me;
@property (nonatomic, strong, readonly) NSMutableDictionary *userMessages;
@property (nonatomic, strong, readonly) NSMutableArray *chatUsers;
@property (nonatomic, strong, readonly) NSMutableArray *nearUsers;
@end

#define kUNIQUE_DEVICE_ID @"kUNIQUE_DEVICE_ID"
#define kGEO_LOCATION @"kGEO_LOCATION"

@implementation AppEngine

+ (instancetype) engine
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
        _me = [PFUser currentUser];
        _userMessages = [NSMutableDictionary dictionary];
        _chatUsers = [NSMutableArray array];
        _nearUsers = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(doLogInEvent:)
                                                     name:AppUserLoggedInNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(doLogoutEvent:)
                                                     name:AppUserLoggedOutNotification
                                                   object:nil];
    }
    return self;
}

- (void) doLogInEvent:(id)sender
{
    NSLog(@"USER LOGGED IN");
    [self loadUserMessages];
    [self reloadNearUsers];
}

- (void) doLogoutEvent:(id)sender
{
    NSLog(@"USER LOGGED OUT");
}

- (NSArray*) users
{
    return self.chatUsers;
}

- (NSArray *)usersNearMe
{
    return self.nearUsers;
}

- (void) reloadNearUsers
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"location" nearGeoPoint:[self currentLocation]];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR LOADING USERS NEAR ME:%@", error.localizedDescription);
        }
        else {
            [self.nearUsers removeAllObjects];
            [self.nearUsers addObjectsFromArray:objects];
            [[NSNotificationCenter defaultCenter] postNotificationName:AppUsersNearMeReloadedNotification object:nil];
        }
    }];
}

- (void) loadUserMessages
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:   @"fromUser == %@ OR toUser == %@", self.me, self.me];
    PFQuery *queryMessages = [PFQuery queryWithClassName:AppMessagesCollection predicate:predicate];
    
    [queryMessages findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [objects enumerateObjectsUsingBlock:^(PFObject* _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
            PFUser *fromUser = message[@"fromUser"];
            PFUser *toUser = message[@"toUser"];
            PFUser *otherUser = [fromUser.objectId isEqualToString:self.me.objectId] ? toUser : fromUser;
            
            if (!self.userMessages[otherUser.objectId]) {
                [self.userMessages setObject:[NSMutableArray array] forKey:otherUser.objectId];
            }
            [self.userMessages[otherUser.objectId] addObject:message];
        }];
        [self loadChatUsers];
    }];
}

- (void) loadChatUsers
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" containedIn:[self.userMessages allKeys]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            
        }
        else {
            [self.chatUsers removeAllObjects];
            [self.chatUsers addObjectsFromArray:objects];
            [[NSNotificationCenter defaultCenter] postNotificationName:AppUserMessagesReloadedNotification object:nil];
        }
    }];
}

- (PFUser*) userWithUserId:(NSString*)userId;
{
    __block PFUser* result = nil;
    [self.chatUsers enumerateObjectsUsingBlock:^(PFUser*  _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        if( [user.objectId isEqualToString:userId]) {
            result = user;
            *stop = YES;
        }
    }];
    
    return result;
}

- (void) resetUnreadMessagesFromUser:(PFUser *)user notify:(BOOL)notify
{
    NSArray *messages = self.userMessages[user.objectId];
    [messages enumerateObjectsUsingBlock:^(PFObject*  _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        [message setObject:@(YES) forKey:@"isRead"];
    }];
    if (notify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AppUserMessagesReloadedNotification object:nil];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:AppMessagesCollection];
    [query whereKey:@"fromUser" equalTo:user];
    [query whereKey:@"toUser" equalTo:self.me];
    [query whereKey:@"isRead" equalTo:@(NO)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [objects enumerateObjectsUsingBlock:^(PFObject*  _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
            [message setObject:@(YES) forKey:@"isRead"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"SUCCESSFULLY SAVED:%@", message);
                }
                else {
                    NSLog(@"ERROR SAVING:%@ - %@", message, error.localizedDescription );
                }
            }];
        }];
    }];
}

- (void) loadMessage:(NSString*)messageId fromUserId:(NSString*)userId
{
    PFObject *message = [PFObject objectWithClassName:AppMessagesCollection];
    message.objectId = messageId;
    
    PFUser *user = [self userWithUserId:userId];
    if (!user) {
        user = [PFUser user];
        user.objectId = userId;
        [user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [self.chatUsers addObject:user];
            [self loadMessage:message withUser:user];
        }];
    }
    else {
        [self loadMessage:message withUser:user];
    }
}

- (void) loadMessage:(PFObject*)message withUser:(PFUser*)user
{
    [message fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [self addMessage:message withUser:user];
    }];
}

- (void) addMessage:(PFObject *)message
{
    PFUser *fromUser = message[@"fromUser"];
    PFUser *toUser = message[@"toUser"];
    PFUser *otherUser = [fromUser.objectId isEqualToString:self.me.objectId] ? toUser : fromUser;

    [self addMessage:message withUser:otherUser];
}

- (void) addMessage:(PFObject*) message withUser:(PFUser *)user
{
    if (message && user) {
        [user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [self.userMessages[user.objectId] addObject:message];
            [[NSNotificationCenter defaultCenter] postNotificationName:AppUserMessagesReloadedNotification object:nil];
        }];
    }
    else {
        NSLog(@"CRITICAL: user or message null");
    }
}

- (NSArray*) messagesWithUser:(PFUser *)user
{
    return user ? self.userMessages[user.objectId] : nil;
}

- (void) dealloc
{
    // Unregister for keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserLoggedInNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserLoggedInNotification
                                                  object:nil];
}

- (void) initLocationServices
{
    self.locMgr = [[CLLocationManager alloc] init];
    self.locMgr.delegate = self;
    self.locMgr.desiredAccuracy = kCLLocationAccuracyBest;
    self.locMgr.distanceFilter = kCLDistanceFilterNone;
    
    if ([self.locMgr respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        [self.locMgr setAllowsBackgroundLocationUpdates:YES];
    }
    
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
            NSLog(@"1");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"2");
            break;
            
        case kCLAuthorizationStatusNotDetermined:
            [self.locMgr requestAlwaysAuthorization];
            
            NSLog(@"3");
            
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"4");
            
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"5");
            
            break;
            
        default:
            break;
    }
    
    [self.locMgr startMonitoringSignificantLocationChanges];
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"LOCATION SERVICES ENABLED");
    }
    else {
        NSLog(@"LOCATION SERVICES NOT ENABLED XXXXXXX");
    }
}

- (PFGeoPoint*) currentLocation
{
    if (!self.curLoc) {
        self.curLoc = [[CLLocation alloc] init];
    }
    return [PFGeoPoint geoPointWithLocation:self.curLoc];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"LOCATION SAVED");
    CLLocation* location = [locations lastObject];
    self.curLoc = location;

    PFGeoPoint *geo = [PFGeoPoint geoPointWithLocation:location];
    
    [[PFUser currentUser] setObject:geo forKey:@"location"];
    [[PFUser currentUser] setObject:location.timestamp forKey:@"locationUpdated"];
    [[PFUser currentUser] saveInBackground];
}

+ (void) clearUniqueDeviceID
{
    [AppEngine engine];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUNIQUE_DEVICE_ID];
    PFUser *user = [PFUser currentUser];
    if (user.username) {
        [[PFUser currentUser] delete];
        [PFUser logOut];
    }
}

+ (NSString*) uniqueDeviceID
{
    [AppEngine engine];
    NSString *cudid = [[NSUserDefaults standardUserDefaults] objectForKey:kUNIQUE_DEVICE_ID];
    NSString *uid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    if (cudid) {
        return cudid;
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:uid forKey:kUNIQUE_DEVICE_ID];
        return uid;
    }
}


- (void)sendMessage:(PFObject *)message toUser:(PFUser *)user
{
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self sendPush:message toUser:user];
            [self addMessage:message withUser:user];
        }
        else {
            NSLog(@"ERROR SAVING MESSAGE TO PARSE:%@", error.localizedDescription);
        }
    }];
}

- (void)sendPush:(PFObject*)message toUser:(PFUser*) user
{
    [PFCloud callFunctionInBackground:@"sendPushToUser"
                       withParameters:@{
                                        AppPushRecipientIdField: user.objectId,
                                        AppPushSenderIdField :   self.me.objectId,
                                        AppPushMessageField:      message[AppMessageContent],
                                        AppPushObjectIdFieldk:    message.objectId
                                        }
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"MESSAGE SENT SUCCESSFULLY:%@", message[AppMessageContent]);
                                    }
                                    else {
                                        NSLog(@"ERROR SENDING PUSH:%@", error.localizedDescription);
                                    }
                                }];
}

@end



