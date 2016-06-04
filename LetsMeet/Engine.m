//
//  Engine.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 4..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Engine.h"
@interface Engine()
@property (nonatomic, strong) PFUser* me;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableDictionary *userMessages;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (nonatomic, strong) NSObject *systemLock;
@end

@implementation Engine
+ (instancetype) engine
{
    static id sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[self alloc] init];
    });
    return sharedFile;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _me = [PFUser currentUser];
        _users = [NSMutableArray new];
        _userMessages = [NSMutableDictionary new];
        _systemLock = [NSObject new];
        
        [self loadInternalDatabase];
        [self initLocationServices];
    }
    return self;
}

- (void) loadInternalDatabase
{
    @synchronized (self.systemLock) {
        self.users = [NSMutableArray arrayWithArray:[self loadUsersFile]];
        self.userMessages = [NSMutableDictionary dictionaryWithDictionary:[self loadUserMessagesFile]];
    }
}

- (NSArray*) loadUsersFile
{
    // TODO LOAD FROM USERS FILE
    return nil;
}

- (NSMutableDictionary*) loadUserMessagesFile
{
    
}

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
    [[PFUser currentUser] setObject:geo forKey:@"location"];
    [[PFUser currentUser] setObject:location.timestamp forKey:@"locationUpdatedAt"];
    [[PFUser currentUser] saveInBackground];
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
