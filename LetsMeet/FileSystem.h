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
@class User;
/**
 The `FileSystem` class is the new engine singleton.
 **/
typedef void (^FileManagerLoadUserMessagesBlock)(Bullet* userMessages, BOOL succeeded);
typedef void (^UsersArrayBlock)(NSArray<User*>*users);

@interface FileSystem : NSObject <CLLocationManagerDelegate>
@property (nonatomic) BOOL isSimulator;

/**
 Creates and returns a new objectId, checked for local uniqueness within the system.
 **/
+ (NSString *) objectId;

/**
 Creates a singleton instance of the FileSystem.
 */
+ (instancetype) new;
- (void) load;
- (BOOL) save; 
- (BOOL) saveUser:(id)userId;
- (BOOL) removeUser:(id)userId;
- (NSArray*) messagesWith:(id)userId;
- (NSArray*) usersInTheSystem;

/**
 The 'add:(NSMutableDictionary*)message for:(id)userId mine:(BOOL)mine' method adds a new message to the system to user with userId. Saves the internal file and sends a push notification depending on whether it's mine (BOOL).
 **/

- (void) add:(Bullet*)message for:(id)userId thumbnail:(NSData*)thumbnail originalData:(NSData*)originalData;

/**
 Looks for users near the currentUser's location through the UsersArrayBlock block.
 **/
- (void) usersNearMeInBackground:(UsersArrayBlock)block;

/**
 The 'update:(NSMutableDictionary*)message for:(id)userId mine:(BOOL)mine' method updates an existing message in the system to user with userId based on the message's objectId. This method is intended to be used for lazy updates of photos or thumbnail images loaded from the network.
 **/
- (void) update:(Bullet*)message for:(id)userId;
- (NSUInteger) unreadMessages;
- (void) readUnreadBulletsWithUserId:(id)userId;
- (void) fetchOutstandingBullets;
- (void) treatPushNotificationWith:(NSDictionary *)userInfo;
- (void) initializeSystem;

@end
