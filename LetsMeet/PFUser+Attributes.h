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
@property (nonatomic, strong) NSString* objectId;
@property (nonatomic, strong) NSString* fromUserId;
@property (nonatomic, strong) NSString* toUserId;
@property (nonatomic) MessageTypes type;
@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, strong) NSString* fileURL;
@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, strong) NSDate* updatedAt;
@property (nonatomic) BOOL isSyncFromUser;
@property (nonatomic) BOOL isSyncToUser;
@property (nonatomic) BOOL isRead;
@property (nonatomic, readonly) BOOL isFromMe;

- (NSString*) typeString;
+ (NSString*) typeStringForType:(MessageTypes)type;

+ (instancetype) messageWithText:(NSString*)text;
+ (instancetype) messageWithPhoto:(PFFile*)file;
+ (instancetype) messageWithVideo:(PFFile*)file;
+ (instancetype) messageWithAudio:(PFFile*)file;
@end