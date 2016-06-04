//
//  FileSystem.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 4..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableDictionary+Bullet.h"

typedef NSMutableDictionary Bullet;

/**
 The `FileSystem` class is the new engine singleton.
 **/
@interface FileSystem : NSObject <CLLocationManagerDelegate>
/**
 The 'loadUserMessages' method loads all
 */

typedef void (^FileManagerLoadUserMessagesBlock)(Bullet* userMessages, BOOL succeeded);
+ (instancetype) new;
- (void) load;
- (BOOL) save; 
- (BOOL) saveUser:(id)userId;
- (BOOL) removeUser:(id)userId;
- (NSMutableArray*) bulletsWith:(id)userId;
- (NSArray*) usersInTheSystem;

/**
 The 'add:(NSMutableDictionary*)message for:(id)userId mine:(BOOL)mine' method adds a new message to the system to user with userId. Saves the internal file and sends a push notification depending on whether it's mine (BOOL).
 **/

- (void) add:(Bullet*)message for:(id)userId thumbnail:(NSData*)thumbnail originalData:(NSData*)originalData;

- (void) addMessageFromObjectId:(id)objectId;


/**
 The 'update:(NSMutableDictionary*)message for:(id)userId mine:(BOOL)mine' method updates an existing message in the system to user with userId based on the message's objectId. This method is intended to be used for lazy updates of photos or thumbnail images loaded from the network.
 **/
- (void) update:(Bullet*)message for:(id)userId;

- (NSUInteger) unreadMessages;
- (void) readUnreadBulletsWithUserId:(id)userId;
+ (void) treatPushNotificationWith:(NSDictionary *)userInfo;
@end
