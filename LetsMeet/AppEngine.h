//
//  AppEngine.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AppUserLoggedInNotification @"AppUserLoggedInNotification"
#define AppUserLoggedOutNotification @"AppUserLoggedOutNotification"
#define AppUserChannelsLoadedNotification @"AppUserChannelsLoadedNotification"

@interface AppEngine : NSObject <CLLocationManagerDelegate>

- (PFUser*) otherUserInChannel:(PFObject*) channel;
+ (id) engine;
- (void) initLocationServices;
+ (NSString*) uniqueDeviceID;
+ (void) clearUniqueDeviceID;
- (PFGeoPoint*) currentLocation;
- (NSArray*) allChannels;
@end
