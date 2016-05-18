//
//  AppEngine.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AppEngine.h"
@interface AppEngine()
@property (nonatomic, strong, readonly) NSMutableArray *channels;
@property (nonatomic, strong) CLLocationManager *locMgr;
@property (nonatomic, strong) CLLocation* curLoc;
@property (nonatomic, strong, readonly) PFUser *me;
@end

#define kUNIQUE_DEVICE_ID @"kUNIQUE_DEVICE_ID"
#define kGEO_LOCATION @"kGEO_LOCATION"

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
        _me = [PFUser currentUser];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(doLogInEvent:)
                                                     name:AppUserLoggedInNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(doLogoutEvent:)
                                                     name:AppUserLoggedInNotification
                                                   object:nil];
    }
    return self;
}

- (void) doLogInEvent:(id)sender
{
    NSLog(@"USER LOGGED IN");
    [self loadMyChatRooms];
}

- (NSArray*) allChannels
{
    return self.channels;
}

- (void) doLogoutEvent:(id)sender
{
    NSLog(@"USER LOGGED OUT");
    [self.channels removeAllObjects];
    _channels = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:AppUserChannelsLoadedNotification object:nil];
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

- (void) arrayOfOtherUserIdFromArray:(NSArray*) channels
{
    __block NSMutableArray *userIds = [NSMutableArray array];
    
    [channels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *members = obj[@"members"];
        
        [members enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PFUser *user = obj;
            if (![user.objectId isEqualToString:self.me.objectId]) {
                [userIds addObject:user.objectId];
            }
        }];
    }];
    
    
}

- (void) loadMyChatRooms
{
    PFQuery *query = [PFQuery queryWithClassName:@"Channel"];
    [query whereKey:@"members" containsAllObjectsInArray:@[self.me]];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR LOADING CHATROOMS: %@", error.localizedDescription);
        }
        else {
            _channels = [NSMutableArray arrayWithArray:objects];
            NSLog(@"FOUND:%ld CHATROOMS", [self.channels count]);
            [self.channels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PFObject *channel = obj;
                PFUser* user = [self otherUserInChannel:channel];
                [user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    
                }];
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:AppUserChannelsLoadedNotification object:nil];
        }
    }];
}

- (PFUser*) otherUserInChannel:(PFObject*) channel
{
    __block PFUser* otherUser = nil;
    NSArray *members = channel[@"members"];
    
    [members enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PFUser *user = obj;
        if (![user.objectId isEqualToString:self.me.objectId]) {
            otherUser = user;
            *stop = YES;
        }
    }];
    
    return otherUser;
}

- (NSString*) channelNameFrom:(PFUser*)user
{
    NSArray *names = [[NSArray arrayWithObjects:self.me.objectId, user.objectId, nil] sortedArrayUsingSelector:@selector(localizedCompare:)];
    
    return [[[names firstObject] stringByAppendingString:@"--"] stringByAppendingString:[names lastObject]];
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

@end



