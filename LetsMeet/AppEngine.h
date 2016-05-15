//
//  AppEngine.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppEngine : NSObject
+ (id) engine;
- (id) init;
- (BOOL) isLoggedIn;
- (void) logIn;
@end
