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
@property (nonatomic, strong) NSTimer* timeKeeper;

//////////////////////////////////////////////////

@property (nonatomic, strong, readonly) NSMutableDictionary *appEngineUserMessages;
@end

#define kUNIQUE_DEVICE_ID @"kUNIQUE_DEVICE_ID"
#define SEQ(XXX,YYY) [XXX isEqualToString:YYY]

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
        
        NSArray *users = [self loadFile:AppEngineUsersFile];
        _appEngineUserMessages = [NSMutableDictionary dictionary];
        [users enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            self.appEngineUserMessages[key] = [NSMutableArray arrayWithArray:[self loadFile:[defUrl([NSString stringWithFormat:AppKeyUserMessagesFileKey, key]) path]]];
            
        }];
        [self initLocationServices];
//        _appEngineUserMessages = [NSMutableDictionary dictionary];

    }
    return self;
}

- (void) startTimeKeeperIfSimulator
{
    [self timeKeep];
}

NSString* otherUserId(MessageObject* message) {
    id fromUserId = message.fromUser.objectId;
    id toUserId = message.toUser.objectId;
    return [fromUserId isEqualToString:[PFUser currentUser].objectId] ? toUserId : fromUserId;
}

NSURL* defUrl(NSString* name)
{
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:name];
}

NSString* fileNamed(id userId)
{
    return [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:userId] path];
}

- (id) loadFile:(NSString*) filename
{
    if([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        NSData *data = [NSData dataWithContentsOfFile:filename];
        id dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return dic;
    }
    else {
        return nil;
    }
}

- (BOOL) updateFile:(NSString*)filename with:(id)content
{
    NSError *error = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        [[NSFileManager defaultManager] removeItemAtPath:filename error:&error];
    }
    if (error) {
        NSLog(@"ERROR%@", [error localizedDescription]);
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:content];
    
    BOOL ret = [data writeToFile:filename atomically:YES] && data.length > 0;
    NSLog(@"Saved to %@ %ssuccessfully [%ld]", filename, ret ? "" : "UN", data.length);
    return ret;
}

- (BOOL) removeFile:(NSString*)filename
{
    NSError *error = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return [[NSFileManager defaultManager] removeItemAtPath:filename error:&error];
    }
    if (error) {
        NSLog(@"ERROR%@", [error localizedDescription]);
    }
    
    return NO;
}


- (BOOL) saveInternals
{
    NSError *error = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:AppEngineDictionaryFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:AppEngineDictionaryFile error:&error];
    }
    if (error) {
        NSLog(@"ERROR%@", [error localizedDescription]);
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.appEngineUserMessages];
   
    BOOL ret = [data writeToFile:AppEngineDictionaryFile atomically:YES] && data.length > 0;
    NSLog(@"Saved to cache %ssuccessfully", ret ? "" : "UN");
    return ret;
}

- (void) timeKeep
{
    static bool virgin = YES;
    
    if (![PFUser currentUser]) {
        virgin = YES;
        NSLog(@"NO USER LOGGED IN SO TRY AGAIN IN 5 SECS");
        self.timeKeeper = [NSTimer scheduledTimerWithTimeInterval:AppEngineTimeKeeperTime
                                                           target:self
                                                         selector:@selector(timeKeep)
                                                         userInfo:nil
                                                          repeats:NO];
        return;
    }
    
    if (virgin) {
        virgin = NO;
    }
    [self AppEngineFetchLastObjects];
    [self logDicStatus];
    self.timeKeeper = [NSTimer scheduledTimerWithTimeInterval:AppEngineTimeKeeperTime
                                                       target:self
                                                     selector:@selector(timeKeep)
                                                     userInfo:nil
                                                      repeats:NO];
}

- (void) logDicStatus
{
    NSLog(@"SYSTEM HAS %ld USERS", self.appEngineUserMessages.count);
    [[self.appEngineUserMessages allKeys] enumerateObjectsUsingBlock:^(NSString*  _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *arr = self.appEngineUserMessages[user];
        NSLog(@"\t%@\tHAS %ld MESSAGES", user, arr.count);
    }];
}

#define KVPAIR(aaa) aaa : message[aaa]

NSDictionary* objectFromMessage(id object)
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if ([object isKindOfClass:[PFACL class]]) {
        PFACL *acl = (PFACL*) object;
        if (acl.publicReadAccess) dic[@"publicReadAccess"] = @(acl.publicReadAccess);
        if (acl.publicWriteAccess) dic[@"publicWriteAccess"] = @(acl.publicWriteAccess);
    }
    else if ([object isKindOfClass:[PFUser class]]) {
        PFUser *obj = (PFUser*)object;
        if (obj.objectId) dic[AppKeyObjectId] = obj.objectId;
    }
    else if ([object isKindOfClass:[PFObject class]]) {
        PFObject *obj = (PFObject*)object;
        if (obj.objectId) dic[AppKeyObjectId] = obj.objectId;
        if (obj.createdAt) dic[AppKeyCreatedAtKey] = obj.createdAt;
        if (obj.updatedAt) dic[AppKeyUpdatedAtKey] = obj.updatedAt;
    }
    else if ([object isKindOfClass:[PFFile class]]) {
        PFFile *file = (PFFile*) object;
        if (file.name) dic[AppKeyNameKey] = file.name;
        if (file.url) dic[AppKeyURLKey] = file.url;
        if (file.isDataAvailable) {
            ///////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////
            
            dic[AppKeyDataKey] = compressedImageData([file getData], 230.0f);
            
            ///////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////
        }
    }
    else if ([object isKindOfClass:[PFGeoPoint class]]) {
        PFGeoPoint *geo = (PFGeoPoint*) object;
        dic[AppKeyLatitudeKey] = @(geo.latitude);
        dic[AppKeyLongitudeKey] = @(geo.longitude);
    }
    
    if ([object respondsToSelector:@selector(allKeys)]) {
        for (NSString *key in [object allKeys]) {
            id o = object[key];
            BOOL isObject = [o isKindOfClass:[PFObject class]] || [o isKindOfClass:[PFFile class]] || [o isKindOfClass:[PFACL class]] || [o isKindOfClass:[PFGeoPoint class]];
            if ([o isKindOfClass:[PFUser class]])
            {
                PFUser *u = o;
                [dic setObject:u.objectId forKey:key];
            }
            else if (isObject) {
                dic[key] = objectFromMessage(o);
            }
            else {
                [dic setObject:o forKey:key];
            }
        }
    }
    return dic;
}

+ (BOOL) appEnginePreAddMessage:(MessageObject *)message
{
    return [[AppEngine engine] appEngineAddMessage:message save:NO];
}

- (BOOL) appEngineAddMessage:(MessageObject *)message save:(BOOL)save
{
    NSString *otherId = otherUserId(message);
    NSMutableDictionary* document = (NSMutableDictionary*) objectFromMessage(message);
    
    if (!self.appEngineUserMessages[otherId]) {
        self.appEngineUserMessages[otherId] = [NSMutableArray array];
    }
    
    NSPredicate *contains = [NSPredicate predicateWithFormat:@"objectId == %@", document.objectId];
    NSArray *duplicates = [self.appEngineUserMessages[otherId] filteredArrayUsingPredicate:contains];
    
    NSUInteger c = duplicates.count;
    if (c<1) {
        [self.appEngineUserMessages[otherId] addObject:document];
    } else {
        NSLog(@"ALREADY CONTAINS MESSAGE.... SO REPLACING TO NEW ONE");
        NSPredicate *doesNotContain = [NSPredicate predicateWithFormat:@"objectId != %@", document.objectId];
        NSArray *exclusives = [self.appEngineUserMessages[otherId] filteredArrayUsingPredicate:doesNotContain];
        self.appEngineUserMessages[otherId] = [NSMutableArray arrayWithArray:exclusives];
        [self.appEngineUserMessages[otherId] addObject:message];
    }
    
    // SORT ARRAY AND INTO MUTABLE ARRAY
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:AppKeyCreatedAtKey ascending:YES];
    self.appEngineUserMessages[otherId] = [NSMutableArray arrayWithArray:[self.appEngineUserMessages[otherId] sortedArrayUsingDescriptors:@[sort]]];
    
    SENDNOTIFICATION(AppUserNewMessageReceivedNotification, document);

    NSLog(@"UPDATING FILESYSTEM");
    if (save) {
        [AppEngine appEngineResetBadge];
        BOOL ret = [self updateFile:AppEngineUsersFile with:[self.appEngineUserMessages allKeys]];
        ret = ret | [self appEngineUpdateFileForUserId:otherId];
        return ret;
    } else {
        return save;
    }
}

- (BOOL) appEngineRemoveFileForUserId:(id)userId
{
    return [self removeFile:[defUrl([NSString stringWithFormat:AppKeyUserMessagesFileKey, userId]) path]];
}

+ (BOOL) appEngineUpdateFileForUserId:(id)userId
{
    return [[AppEngine engine] appEngineUpdateFileForUserId:userId];
}

- (BOOL) appEngineUpdateFileForUserId:(id)userId
{
    NSArray *userMessages = self.appEngineUserMessages[userId];
    return [self updateFile:[defUrl([NSString stringWithFormat:AppKeyUserMessagesFileKey, userId]) path] with:userMessages];
}


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

+ (void) appEngineLoadMessageWithId:(id)messageId fromUserId:(id)userId
{
    MessageObject *message = [MessageObject new];
    message.objectId = messageId;
    [message fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSLog(@"MESSAGE LOADED:%@", message);
        PFUser *toUser = message.toUser;
        PFUser *me = [PFUser currentUser];
        if ([toUser.objectId isEqualToString:me.objectId]) {
            message.isSyncToUser = YES;
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    [[AppEngine engine] appEngineAddMessage:message save:YES];
                }
            }];
        }
    }];
}

///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

- (void) AppEngineFetchLastObjects
{
    NSLog(@"APPENGINEFETCHLASTOBJECTS");
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"( fromUser == %@ AND isSyncFromUser != true) OR (toUser == %@ AND isSyncToUser != true)",
                              self.me,
                              self.me];
    
    PFQuery *query = [PFQuery queryWithClassName:AppMessagesCollection predicate:predicate];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable messages, NSError * _Nullable error) {
        [messages enumerateObjectsUsingBlock:^(MessageObject*  _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self appEngineAddMessage:message save:YES]) {
                PFUser *fromUser = message.fromUser;
                PFUser *toUser = message.toUser;
                
                BOOL conditionMet = NO;
                if (SEQ(fromUser.objectId, self.me.objectId)) {
                    message.isSyncFromUser = YES;
                    conditionMet = YES;
                }
                if (SEQ(toUser.objectId, self.me.objectId)) {
                    message.isSyncToUser = YES;
                    conditionMet = YES;
                }
                
                if (conditionMet) {
                    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (!succeeded) {
                            NSLog(@"ERROR:%@", error.localizedDescription);
                        }
                    }];
                }
            }
        }];
    }];
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

//    PFGeoPoint *geo = [PFGeoPoint geoPointWithLocation:location];
    
//    [[PFUser currentUser] setObject:geo forKey:AppKeyLocationKey];
//    [[PFUser currentUser] setObject:location.timestamp forKey:AppKeyLocationUpdatedKey];
//    [[PFUser currentUser] saveInBackground];
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

+ (void) appEngineSendMessage:(MessageObject *)message toUser:(PFUser *)user
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


+ (void) appEngineBroadcastPush:(NSString*)message duration:(NSNumber*)duration
{
    PFUser *me = [PFUser currentUser];
    
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

///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
// FROM APPLICATION DELEGATE (PUSH CAME IN)
///////////////////////////////////////////////////////////

+ (void)appEngineTreatPushUserInfo:(NSDictionary *)userInfo
{
    if ([userInfo[AppPushType] isEqualToString:AppPushTypeMessage]) {
        NSLog(@"userInfo:%@", userInfo);
        [AppEngine appEngineLoadMessageWithId:userInfo[AppKeyMessageIdKey] fromUserId:userInfo[AppKeySenderId]];
    }
    else if ([userInfo[AppPushType] isEqualToString:AppPushTypeBroadcast]) {
        NSLog(@"userInfo:%@", userInfo);
        SENDNOTIFICATION(AppUserBroadcastNotification, userInfo);
    }
}

///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

+ (void) appEngineSendPush:(NSMutableDictionary *)message toUser:(PFUser*) user
{
    PFUser *me = [PFUser currentUser];
    
    [PFCloud callFunctionInBackground:AppPushCloudAppPush
                       withParameters:@{
                                        AppPushRecipientIdField: user.objectId,
                                        AppPushSenderIdField: me.objectId,
                                        AppPushMessageField: message.text,
                                        AppPushObjectIdField: message.objectId,
                                        AppPushType: AppPushTypeMessage
                                        }
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        [[AppEngine engine] appEngineAddMessage:message2 save:YES];
                                    }
                                    else {
                                        NSLog(@"ERROR SENDING PUSH:%@", error.localizedDescription);
                                    }
                                }];
}

+ (void)appEngineInboxUsers:(ArrayResultBlock)block
{
    [AppEngine appEngineUsersFromUserIds:[[AppEngine engine].appEngineUserMessages allKeys] completed:block];
}

+ (BOOL)appEngineRemoveAllMessagesFromUserId:(id)userId
{
    AppEngine *engine = [AppEngine engine];

    [self appEngineResetBadge];
    
    BOOL ret = [engine appEngineRemoveFileForUserId:userId];
    if (ret) {
        NSLog(@"INBOX USERS BEFORe DELETE:%@", [engine.appEngineUserMessages allKeys]);
        [engine.appEngineUserMessages removeObjectForKey:userId];
        NSLog(@"INBOX USERS AFTER DELETE:%@", [engine.appEngineUserMessages allKeys]);
        ret = ret | [engine updateFile:AppEngineUsersFile with:[engine.appEngineUserMessages allKeys]];
    }
    
    return ret;
}

+ (void)appEngineUsersFromUserIds:(NSArray *)userIds completed:(ArrayResultBlock)block
{
    PFQuery *query = [PFUser query];
    [query whereKey:AppKeyObjectId containedIn:userIds];
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
}

+ (void)appEngineUserFromUserId:(id)userId completed:(UserResultBlock)block
{
    PFUser *user = [PFUser user];
    user.objectId = userId;
    
    [user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"CANNOT LOAD USER:%@", error.localizedDescription);
        }
        else {
            if (block)
                block(user);
        }
    }];
}

+ (void) appEngineSetReadAllMyMessagesWithUserId:(id)userId
{
    [[AppEngine engine] appEngineSetReadAllMyMessagesWithUserId:userId];
}

- (void) appEngineSetReadAllMyMessagesWithUserId:(id)userId
{
    __block NSUInteger count = 0;
    [self.appEngineUserMessages[userId] enumerateObjectsUsingBlock:^(NSMutableDictionary* _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([message.toUserId isEqualToString:self.me.objectId] && !message.isRead) {
            message.isRead = YES;
            count++;
        }
    }];
    NSLog(@">>> %ld MESSAGES RESET", (unsigned long)count);
    
    if ([self appEngineUpdateFileForUserId:userId]) {
        [self appEngineResetBadge];
    }
}

- (NSUInteger) appEngineUnreadCount
{
    __block NSUInteger count = 0;
    [[self.appEngineUserMessages allKeys] enumerateObjectsUsingBlock:^(id  _Nonnull userId, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.appEngineUserMessages[userId] enumerateObjectsUsingBlock:^(NSMutableDictionary* _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([message.toUserId isEqualToString:self.me.objectId] && message.isRead == NO) {
                count++;
            }
        }];
    }];
    return count;
}

+ (NSUInteger) appEngineUnreadCount
{
    return [AppEngine engine].appEngineUnreadCount;
}

- (void) appEngineResetBadge
{
    NSUInteger count = [self appEngineUnreadCount];
    PFInstallation *install = [PFInstallation currentInstallation];
    if (install.badge != count) {
        NSLog(@"RESET BADGE COUNT TO %ld", (unsigned long)count);
        [install setBadge:count];
        [install saveInBackground];
    }
}

+ (void) appEngineResetBadge
{
    [[AppEngine engine] appEngineResetBadge];
}

+ (NSArray *) appEngineMessagesWithUserId:(id)userId
{
    return userId ? [AppEngine engine].appEngineUserMessages[userId] : nil;
}

+ (NSString*) appEngineLastMessageFromUserId:(id)userId
{
    return userId ? [[AppEngine engine].appEngineUserMessages[userId] lastObject] : nil;
}

+ (NSString*) appEngineLastMessageFromUser:(PFUser*)user
{
    return [AppEngine appEngineLastMessageFromUserId:user.objectId];
}

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
    [view.layer setContentsGravity:kCAGravityResizeAspectFill];
    [view.layer setMasksToBounds:YES];
}

void circleizeView(UIView* view, CGFloat percent)
{
    view.layer.cornerRadius = view.frame.size.height * percent;
    view.layer.masksToBounds = YES;
}

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

float Heading(PFUser* from, PFUser* to)
{
    PFGeoPoint *fromLoc = from.location;
    PFGeoPoint *toLoc = to.location;
    if (from != to && (fromLoc.latitude == toLoc.latitude && fromLoc.longitude == toLoc.longitude)) {
        printf("SAME LOCATION FOR:%s - %s\n", [from.nickname UTF8String], [to.nickname UTF8String]);
    }
    return heading(fromLoc, toLoc);
}

CGRect hiveToFrame(CGPoint hive, CGFloat radius, CGFloat inset, CGPoint center)
{
    const int offx[] = { 1, -1, -2, -1, 1, 2};
    const int offy[] = { 1, 1, 0, -1, -1, 0};
    
    int level = hive.x;
    int quad = hive.y;
    
    int sx = level, sy = -level;
    
    for (int i=0; i<quad; i++) {
        int side = (int) i / (level);
        int ox = offx[side];
        int oy = offy[side];
        
        sx += ox;
        sy += oy;
    }
    
    const CGFloat f = 2-inset/radius;
    const CGFloat f2 = f*1.154;
    
    CGFloat x = center.x+(sx-0.5f)*radius;
    CGFloat y = center.y+(sy-0.5f)*radius*1.5*1.154;
    
    return CGRectMake(x, y, f*radius, f2*radius);
}


float heading(PFGeoPoint* fromLoc, PFGeoPoint* toLoc)
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

NSData* compressedImageData(NSData* data, CGFloat width)
{
    NSLog(@"Loaded data of size:%ld", [data length]);
    UIImage *image = [UIImage imageWithData:data];
    const CGFloat thumbnailWidth = width;
    CGFloat thumbnailHeight = image.size.width ? thumbnailWidth * image.size.height / image.size.width : 200;
    image = scaleImage(image, CGSizeMake(thumbnailWidth, thumbnailHeight));
    return UIImageJPEGRepresentation(image, AppProfilePhotoCompressionLow);
}

CGRect rectForString(NSString *string, UIFont *font, CGFloat maxWidth)
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    CGRect rect = CGRectIntegral([string boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{
                                                                  NSFontAttributeName: font,
                                                                  } context:nil]);
    return rect;
}
