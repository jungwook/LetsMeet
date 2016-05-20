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
#define AppUserMessagesReloadedNotification @"AppUserMessagesReloadedNotification"
#define AppUsersNearMeReloadedNotification @"AppUsersNearMeReloadedNotification"

#define AppMessagesCollection @"Messages"

#define AppMessageType @"msgType"
#define AppMessageContent @"msgContent"
#define AppMessageTypeMessage @"MSG"
#define AppMessageTypePhoto @"PHOTO"
#define AppMessageTypeVideo @"VIDEO"
#define AppMessageTypeAudio @"AUDIO"
#define AppMessageTypeURL @"URL"

#define AppPushRecipientIdField @"recipientId"
#define AppPushSenderIdField @"senderId"
#define AppPushMessageField @"message"
#define AppPushObjectIdFieldk @"messageId"

#define AppFemaleUserColor [UIColor colorWithRed:255.f/255.0f green:111.f/255.0f blue:207.f/255.0f alpha:1]
#define AppMaleUserColor [UIColor colorWithRed:42.f/255.0f green:111.f/255.0f blue:207.f/255.0f alpha:1]
#define AppMaleUser YES
#define AppFemaleUser NO
#define AppMaleUserString @"남자"
#define AppFemaleUserString @"여자"


@interface AppEngine : NSObject <CLLocationManagerDelegate>
- (void) resetUnreadMessagesFromUser:(PFUser*)user notify:(BOOL)notify;
- (NSArray*) users;
- (NSArray*) usersNearMe;
- (NSArray*) messagesWithUser:(PFUser*)user;

- (void) sendMessage:(PFObject*)message toUser:(PFUser*) user;
- (void) loadMessage:(NSString*)messageId fromUserId:(NSString*)userId;
- (void) addMessage:(PFObject*)message withUser:(PFUser *)user;
- (void) addMessage:(PFObject*)message;
- (void) initLocationServices;
- (void) reloadNearUsers;
- (PFGeoPoint*) currentLocation;

+ (instancetype) engine;
+ (NSString*) uniqueDeviceID;
+ (void) clearUniqueDeviceID;
+ (void) drawImage:(UIImage *)image onView:(UIView*) view;
@end
