//
//  AppEngine.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFUser+Attributes.h"

#define SENDNOTIFICATION(NOTIF,OBJECT) [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF object:OBJECT]

#define AppUserNewMessageReceivedNotification @"AppUserNewMessageReceivedNotificaiton"
#define AppUserRefreshBadgeNotificaiton @"AppUserRefreshBadgeNotificaiton"
#define AppUserBroadcastNotification @"AppUserBroadcastNotification"

#define AppMessagesCollection @"Messages"
#define AppEngineTimeKeeperTime 60

#define AppPushRecipientIdField @"recipientId"
#define AppPushSenderIdField @"senderId"
#define AppPushMessageField @"message"
#define AppPushObjectIdField AppKeyMessageIdKey
#define AppPushCloudAppPush @"sendPushToUser"
#define AppPushCloudAppBroadcast @"broadcastMessage"
#define AppPushBroadcastDurationKey @"duration"


#define AppPushType @"pushType"
#define AppPushTypeMessage @"pushTypeMessage"
#define AppPushTypeBroadcast @"pushTypeBroadcast"
#define AppPushBroadcastField @"pushBroadcast"

#define AppFemaleUserColor [UIColor colorWithRed:255.f/255.0f green:111.f/255.0f blue:207.f/255.0f alpha:1]
#define AppMaleUserColor [UIColor colorWithRed:42.f/255.0f green:111.f/255.0f blue:207.f/255.0f alpha:1]
#define AppMaleUser YES
#define AppFemaleUser NO
#define AppMaleUserString @"남자"
#define AppFemaleUserString @"여자"

#define AppProfilePhotoSize CGSizeMake(60, 60)
#define AppProfilePhotoCompression 0.6
#define AppProfilePhotoCompressionLow 0.2

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
#define AppKeyBroadcastMessageKey @"broadcastMessage"
#define AppKeyBroadcastMessageAtKey @"broadcastMessageAt"

#define AppProfilePhotoField @"photo"
#define AppProfileOriginalPhotoField @"originalPhoto"
#define AppEngineDictionaryFile [defUrl(@"dictionary") path]
#define AppEngineUsersFile [defUrl(@"users") path]

typedef NS_OPTIONS(NSUInteger, ImagePickerSourceTypes) {
    kImagePickerSourceNone                  = 0,
    kImagePickerSourceCamera                = 1 << 0,
    kImagePickerSourceLibrary               = 1 << 1,
    kImagePickerSourceVoice                 = 1 << 2,
    kImagePickerSourceURL                   = 1 << 3,
};

typedef NS_OPTIONS(NSUInteger, ImagePickerMediaType) {
    kImagePickerMediaNone                   = 0,
    kImagePickerMediaPhoto                  = 1 << 0,
    kImagePickerMediaMovie                  = 1 << 1,
    kImagePickerMediaVoice                  = 1 << 2,
};

typedef void (^FileBooleanResultBlock)(PFFile *file, BOOL succeeded, NSError * error);
typedef void (^ArrayResultBlock)(NSArray *objects);
typedef void (^DataBlock)(NSData *data);
typedef void (^ArrayIntResultBlock)(NSArray *objects, int levels);
typedef void (^UserResultBlock)(PFUser *user);
typedef void (^voidBlock)(void);
typedef void (^RefreshControlBlock)(UIRefreshControl* refreshControl);
typedef void (^CountResultBlock)(NSUInteger count);
typedef void (^DictionaryResultBlock)(NSDictionary *messages);
typedef void (^DictionaryArrayResultBlock)(NSDictionary *messages, NSArray *users);
typedef void (^CachedFileBlock)(NSData * data, NSError * error, BOOL fromCache);
typedef void (^ImagePickerBlock)(id data, ImagePickerMediaType type, NSString* sizeString, NSURL *url);

CALayer* drawImageOnLayer(UIImage *image, CGSize size);
UIImage* scaleImage(UIImage* image, CGSize size);
void drawImage(UIImage *image, UIView* view);
void circleizeView(UIView* view, CGFloat percent);
float heading(PFGeoPoint* fromLoc, PFGeoPoint* toLoc);
float Heading(PFUser* from, PFUser* to);
CGRect hiveToFrame(CGPoint hive, CGFloat radius, CGFloat inset, CGPoint center);
CGRect rectForString(NSString *string, UIFont *font, CGFloat maxWidth);
NSString* QUADRANT(PFGeoPoint* fromLoc, PFGeoPoint* toLoc);
NSData* compressedImageData(NSData* data, CGFloat width);

@interface AppEngine : NSObject <CLLocationManagerDelegate>
- (void) initLocationServices;
- (PFGeoPoint*) currentLocation;

+ (instancetype) engine;
+ (NSString*) uniqueDeviceID;
+ (void) clearUniqueDeviceID;

////////////////////////// NEW GLOBAL APIS ////////////////////////
//+ (void) appEngineReloadAllMessages;
+ (void) appEngineLoadMessageWithId:(id)messageId fromUserId:(id)userId;
+ (void) appEngineSendMessage:(MessageObject *)message toUser:(PFUser *)user;
+ (void) appEngineBroadcastPush:(NSString*)message duration:(NSNumber*)duration;
+ (void) appEngineUsersFromUserIds:(NSArray*)userIds completed:(ArrayResultBlock)block;
+ (void) appEngineInboxUsers:(ArrayResultBlock)block;
+ (void) appEngineUserFromUserId:(id)userId completed:(UserResultBlock)block;
+ (NSString*) appEngineLastMessageFromUser:(PFUser*)user;
+ (NSString*) appEngineLastMessageFromUserId:(id)userId;
+ (NSArray*) appEngineMessagesWithUserId:(id)userId;
+ (void) appEngineSetReadAllMyMessagesWithUserId:(id)userId;
+ (BOOL) appEngineRemoveAllMessagesFromUserId:(id)userId;
+ (NSUInteger) appEngineUnreadCount;
+ (void) appEngineTreatPushUserInfo:(NSDictionary*)userInfo;
+ (BOOL) appEngineUpdateFileForUserId:(id)userId;
+ (BOOL) appEnginePreAddMessage:(MessageObject *)message;

- (void) startTimeKeeperIfSimulator;
- (void) AppEngineFetchLastObjects;
+ (void) appEngineResetBadge;
@end
