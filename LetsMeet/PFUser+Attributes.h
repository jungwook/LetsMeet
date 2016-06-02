//
//  PFUser+Attributes.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFUser(Attributes)
@property (nonatomic, strong) NSString* nickname;
@property (nonatomic, strong) PFGeoPoint* location;

@property (nonatomic) BOOL sex;
@property (nonatomic) CGPoint coords;
@property (nonatomic, strong) NSString* broadcastMessage;
@property (nonatomic, strong) NSDate* broadcastMessageAt;
@property (nonatomic, strong) NSNumber* broadcastDuration;
@property (nonatomic, strong) NSString* age;
@property (nonatomic, strong) NSString* intro;
@property (nonatomic, strong) PFFile* profilePhoto;
@property (nonatomic, strong) PFFile* originalPhoto;

- (char*) desc;
@end

@interface MessageObject : PFObject<PFSubclassing>
+ (NSString *)parseClassName;
@property (retain) PFUser *fromUser;
@property (retain) PFUser *toUser;
@property (retain) NSString *msgContent;
@property (retain) PFFile* file;
@property (retain) NSString *mediaInfo;
@property (retain) NSString *msgType;
@property BOOL isSyncFromUser;
@property BOOL isSyncToUser;
@property BOOL isRead;

- (BOOL) isTextMessage;
- (BOOL) isPhotoMessage;
- (BOOL) isVideoMessage;
- (BOOL) isAudioMessage;
- (BOOL) isURLMessage;
- (BOOL) isFromMe;
- (NSString*) info;
@end

typedef NS_OPTIONS(NSUInteger, MessageTypes) {
    kMessageTypeNone = 0,
    kMessageTypeText,
    kMessageTypePhoto,
    kMessageTypeVideo,
    kMessageTypeAudio,
    kMessageTypeURL
};

@interface NSMutableDictionary (Message)
@property (nonatomic, weak) NSString* objectId;
@property (nonatomic, weak) NSString* fromUserId;
@property (nonatomic, weak) NSString* toUserId;
@property (nonatomic) MessageTypes type;
@property (nonatomic, weak) NSString* text;
@property (nonatomic, weak) NSString* fileName;
@property (nonatomic, weak) NSString* fileURL;
@property (nonatomic, weak) NSString* mediaInfo;
@property (nonatomic, weak) NSDate* createdAt;
@property (nonatomic, weak) NSDate* updatedAt;
@property (nonatomic) BOOL isSyncFromUser;
@property (nonatomic) BOOL isSyncToUser;
@property (nonatomic) BOOL isRead;
@property (nonatomic, readonly) BOOL isFromMe;
@property (nonatomic, readonly) BOOL isDataAvailable;
@property (nonatomic, weak) NSData* data;

- (BOOL) save;
- (NSString*) typeString;
+ (NSString*) typeStringForType:(MessageTypes)type;

+ (instancetype) messageWithText:(NSString*)text;
+ (instancetype) messageWithPhoto:(PFFile*)file;
+ (instancetype) messageWithVideo:(PFFile*)file;
+ (instancetype) messageWithAudio:(PFFile*)file;
@end