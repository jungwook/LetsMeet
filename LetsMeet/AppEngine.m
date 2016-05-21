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



//////////////////////////////////////////////////

@property (nonatomic, strong, readonly) NSMutableDictionary *appEngineUserMessages;
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
        
        _appEngineUserMessages = [NSMutableDictionary dictionary];
        
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
        [self reloadChatUsers];
    }];
}

- (void) reloadChatUsers
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" containedIn:[self.userMessages allKeys]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            
        }
        else {
            [self.chatUsers removeAllObjects];
            [self.chatUsers addObjectsFromArray:objects];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:AppUserMessagesReloadedNotification object:nil];
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

+ (void) appEngineLoadMyDictionaryOfUsersAndMessagesInBackground:(DictionaryArrayResultBlock)block
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    PFUser *me = [PFUser currentUser];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:   @"fromUser == %@ OR toUser == %@", me, me];
    PFQuery *queryMessages = [PFQuery queryWithClassName:AppMessagesCollection predicate:predicate];
    
    [queryMessages findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [objects enumerateObjectsUsingBlock:^(PFObject* _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
            PFUser *fromUser = message[@"fromUser"];
            PFUser *toUser = message[@"toUser"];
            PFUser *otherUser = [fromUser.objectId isEqualToString:me.objectId] ? toUser : fromUser;
            
            if (!dictionary[otherUser.objectId]) {
                dictionary[otherUser.objectId] = [NSMutableArray array];
            }
            [dictionary[otherUser.objectId] addObject:message];
        }];
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" containedIn:[dictionary allKeys]];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
            if (error) {
                NSLog(@"ERROR:%@", error.localizedDescription);
            }
            else {
                if (block) {
                    block(dictionary, users);
                }
            }
        }];
    }];
}

+ (void) appEngineReloadAllChatUsersInBackground:(ArrayResultBlock)block
{
    PFUser *me = [PFUser currentUser];
    NSMutableSet *chatUsers = [NSMutableSet set];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:   @"fromUser == %@ OR toUser == %@", me, me];
    PFQuery *queryMessages = [PFQuery queryWithClassName:AppMessagesCollection predicate:predicate];
    
    [queryMessages findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [objects enumerateObjectsUsingBlock:^(PFObject* _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
            PFUser *fromUser = message[@"fromUser"];
            PFUser *toUser = message[@"toUser"];
            PFUser *otherUser = [fromUser.objectId isEqualToString:me.objectId] ? toUser : fromUser;
            
            [chatUsers addObject:otherUser.objectId];
        }];
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" containedIn:[chatUsers allObjects]];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error) {
                NSLog(@"ERROR:%@", error.localizedDescription);
            }
            else {
                if (block) {
                    block(objects);
                }
            }
        }];
    }];
}

+ (void) appEngineReloadMessagesWithUser:(PFUser*)user inBackground:(ArrayResultBlock)block
{
    PFUser *me = [PFUser currentUser];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:   @"(fromUser == %@ AND toUser = %@) OR (toUser == %@ AND fromUser == %@)",
                              user, me, user, me];
    PFQuery *queryMessages = [PFQuery queryWithClassName:AppMessagesCollection predicate:predicate];
    
    [queryMessages findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (block) {
            block(objects);
        }
    }];
}

+ (void) appEngineResetUnreadMessages:(NSArray*)messages fromUser:(PFUser *)user completionBlock:(CountResultBlock)block
{
    NSLog(@"MEssages:%ld", messages.count);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:   @"fromUser == %@", user];
    NSArray *recMessages = [messages filteredArrayUsingPredicate:predicate];
    NSLog(@"MEssages:%ld", recMessages.count);
    
    [recMessages enumerateObjectsUsingBlock:^(PFObject*  _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        [message setObject:@(YES) forKey:@"isRead"];
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!succeeded) {
                NSLog(@"ERROR SAVING:%@ - %@", message, error.localizedDescription );
            }
        }];
    }];
    if (block) {
        block([recMessages count]);
    }
}

+ (void) appEngineLoadMessageWithId:(id)messageId fromUserId:(id)userId
{
    PFObject *message = [PFObject objectWithClassName:AppMessagesCollection];
    message.objectId = messageId;
    
    [message fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        SENDNOTIFICATION(AppUserNewMessageReceivedNotification, message);
    }];
}


+ (void) appEngineSendMessage:(PFObject *)message toUser:(PFUser *)user
{
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self appEngineSendPush:message toUser:user];
        }
        else {
            NSLog(@"ERROR SAVING MESSAGE TO PARSE:%@", error.localizedDescription);
        }
    }];
}

+ (void) appEngineSendPush:(PFObject*)message toUser:(PFUser*) user
{
    PFUser *me = [PFUser currentUser];
    
    [PFCloud callFunctionInBackground:@"sendPushToUser"
                       withParameters:@{
                                        AppPushRecipientIdField: user.objectId,
                                        AppPushSenderIdField :   me.objectId,
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
/**/
@end

CALayer* drawImageOnLayer(UIImage *image, CGSize size)
{
    CALayer *layer = [CALayer layer];
    [layer setBounds:CGRectMake(0, 0, size.width, size.height)];
    [layer setContents:(id)image.CGImage];
    [layer setContentsGravity:kCAGravityResizeAspect];
    [layer setMasksToBounds:YES];
    return layer;
}

UIImage* scaleImage(UIImage* image, CGSize size) {
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
    [drawImageOnLayer(image,size) renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
}

void drawImage(UIImage *image, UIView* view)
{
    [view.layer setContents:(id)image.CGImage];
    [view.layer setContentsGravity:kCAGravityResizeAspect];
    [view.layer setMasksToBounds:YES];
}

void circleizeView(UIView* view, CGFloat percent)
{
    view.layer.cornerRadius = view.frame.size.height * percent;
    view.layer.masksToBounds = YES;
}



