//
//  AppEngine.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SENDNOTIFICATION(NOTIF,OBJECT) [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF object:OBJECT]
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

#define AppProfilePhotoSize CGSizeMake(60, 60)
#define AppProfilePhotoCompression 0.6
#define AppProfilePhotoFileName @"profile.jpg"
#define AppProfileOriginalPhotoFileName @"original.jpg"

#define AppProfileIntroductions @[@"우리 만나요!", @"애인 찾아요", @"함께 드라이브"]
#define AppProfileSexSelections @[@"남자", @"여자"]
#define AppProfileAgeSelections @[@"20대", @"30대", @"40대", @"50대"]

#define AppProfilePhotoField @"photo"
#define AppProfileOriginalPhotoField @"originalPhoto"

typedef void (^FileBooleanResultBlock)(PFFile *file, BOOL succeeded, NSError * error);
typedef void (^ArrayResultBlock)(NSArray *objects);


CALayer* drawImageOnLayer(UIImage *image, CGSize size);
UIImage* scaleImage(UIImage* image, CGSize size);
void drawImage(UIImage *image, UIView* view);
void circleizeView(UIView* view, CGFloat percent);


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
- (void) reloadChatUsers;
- (PFGeoPoint*) currentLocation;

+ (instancetype) engine;
+ (NSString*) uniqueDeviceID;
+ (void) clearUniqueDeviceID;
+ (void) drawImage:(UIImage *)image onView:(UIView*) view;


////////////////////////// NEW GLOBAL APIS ////////////////////////
+ (void) appEngineReloadAllMessages;
+ (void) appEngineReloadAllChatUsersInBackground:(ArrayResultBlock)block;
+ (void) appEngineReloadUsersOfId:(NSArray*)userIds inBackgroundWithBlock:(void(^)(NSArray *users))block;
@end
