//
//  AppEngine.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppEngine : NSObject <CLLocationManagerDelegate>
+ (id) engine;
- (void) initLocationServices;
+ (NSString*) uniqueDeviceID;
+ (void) clearUniqueDeviceID;
- (PFGeoPoint*) currentLocation;
@end
