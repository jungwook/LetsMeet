//
//  AppEngine.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SENDNOTIFICATION(NOTIF,OBJECT) [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF object:OBJECT]

#define AppUserNewMessageReceivedNotification @"AppUserNewMessageReceivedNotificaiton"
#define AppUserRefreshBadgeNotificaiton @"AppUserRefreshBadgeNotificaiton"

#define AppMessagesCollection @"Messages"
#define AppEngineTimeKeeperTime 60
#define AppMessageType @"msgType"
#define AppMessageContent @"msgContent"
#define AppMessageTypeMessage @"MSG"
#define AppMessageTypePhoto @"PHOTO"
#define AppMessageTypeVideo @"VIDEO"
#define AppMessageTypeAudio @"AUDIO"
#define AppMessageTypeURL AppKeyURLKey

#define AppPushRecipientIdField @"recipientId"
#define AppPushSenderIdField AppKeySenderId
#define AppPushMessageField @"message"
#define AppPushObjectIdFieldk AppKeyMessageIdKey
#define AppPushCloudAppPush @"sendPushToUser"

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

#define AppKeyIsSyncToUserField @"isSyncToUser"
#define AppKeyIsSyncFromUserField @"isSyncFromUser"
#define AppKeyToUserField @"toUser"
#define AppKeyFromUserField @"fromUser"
#define AppKeyObjectId @"objectId"
#define AppKeyUserMessagesFileKey @"userMessages-%@"
#define AppKeyCreatedAtKey @"createdAt"
#define AppKeyLocationKey @"location"
#define AppKeyLocationUpdatedKey @"locationUpdated"
#define AppKeyIsReadKey @"isRead"
#define AppKeySexKey @"sex"
#define AppKeyNicknameKey @"nickname"
#define AppKeyIntroKey @"intro"
#define AppKeyAgeKey @"age"
#define AppKeyMessageIdKey @"messageId"
#define AppKeySenderId @"senderId"
#define AppKeyNameKey @"name"
#define AppKeyUpdatedAtKey @"updatedAt"
#define AppKeyURLKey @"url"
#define AppKeyDataKey @"data"
#define AppKeyLatitudeKey @"latitude"
#define AppKeyLongitudeKey @"longitude"

#define AppProfilePhotoField @"photo"
#define AppProfileOriginalPhotoField @"originalPhoto"
#define AppEngineDictionaryFile [defUrl(@"dictionary") path]
#define AppEngineUsersFile [defUrl(@"users") path]

typedef void (^FileBooleanResultBlock)(PFFile *file, BOOL succeeded, NSError * error);
typedef void (^ArrayResultBlock)(NSArray *objects);
typedef void (^UserResultBlock)(PFUser *user);
typedef void (^voidBlock)(void);
typedef void (^RefreshControlBlock)(UIRefreshControl* refreshControl);
typedef void (^CountResultBlock)(NSUInteger count);
typedef void (^DictionaryResultBlock)(NSDictionary *messages);
typedef void (^DictionaryArrayResultBlock)(NSDictionary *messages, NSArray *users);


CALayer* drawImageOnLayer(UIImage *image, CGSize size);
UIImage* scaleImage(UIImage* image, CGSize size);
void drawImage(UIImage *image, UIView* view);
void circleizeView(UIView* view, CGFloat percent);


@interface AppEngine : NSObject <CLLocationManagerDelegate>
- (void) initLocationServices;
- (PFGeoPoint*) currentLocation;

+ (instancetype) engine;
+ (NSString*) uniqueDeviceID;
+ (void) clearUniqueDeviceID;

////////////////////////// NEW GLOBAL APIS ////////////////////////
//+ (void) appEngineReloadAllMessages;
+ (void) appEngineLoadMessageWithId:(id)messageId fromUserId:(id)userId;
+ (void) appEngineSendMessage:(PFObject *)message toUser:(PFUser *)user;
+ (void) appEngineUsersFromUserIds:(NSArray*)userIds completed:(ArrayResultBlock)block;
+ (void) appEngineInboxUsers:(ArrayResultBlock)block;
+ (void) appEngineUserFromUserId:(id)userId completed:(UserResultBlock)block;
+ (NSString*) appEngineLastMessageFromUser:(PFUser*)user;
+ (NSString*) appEngineLastMessageFromUserId:(id)userId;
+ (NSArray*) appEngineMessagesWithUserId:(id)userId;
+ (void) appEngineSetReadAllMyMessagesWithUserId:(id)userId;
+ (BOOL) appEngineRemoveAllMessagesFromUserId:(id)userId;
+ (NSUInteger) appEngineUnreadCount;

- (void) startTimeKeeperIfSimulator;
- (void) AppEngineFetchLastObjects;
+ (void) appEngineResetBadge;
@end
