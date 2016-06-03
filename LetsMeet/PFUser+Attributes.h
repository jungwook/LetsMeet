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

typedef NS_OPTIONS(NSUInteger, MessageTypes) {
    kMessageTypeNone = 0,
    kMessageTypeText,
    kMessageTypePhoto,
    kMessageTypeVideo,
    kMessageTypeAudio,
    kMessageTypeURL
};


@interface MessageObject : PFObject<PFSubclassing>
+ (NSString *)parseClassName;
@property (retain) PFUser *fromUser;
@property (retain) PFUser *toUser;
@property (retain) PFFile* file;
@property (retain) NSString *message;
@property (retain) NSString *mediaInfo;
@property MessageTypes type;
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

@interface NSMutableDictionary(Message)

@property (nonatomic, assign) NSString* objectId;
@property (nonatomic, assign) NSString* fromUserId;
@property (nonatomic, assign) NSString* toUserId;
@property (nonatomic) MessageTypes type;
@property (nonatomic, assign) NSString* message;
@property (nonatomic, assign) NSString* fileName;
@property (nonatomic, assign) NSString* fileURL;
@property (nonatomic, assign) NSString* mediaInfo;
@property (nonatomic, assign) NSDate* createdAt;
@property (nonatomic, assign) NSDate* updatedAt;
@property (nonatomic) BOOL isSyncFromUser;
@property (nonatomic) BOOL isSyncToUser;
@property (nonatomic) BOOL isRead;
@property (nonatomic, readonly) BOOL isFromMe;
@property (nonatomic, readonly) BOOL isDataAvailable;
@property (nonatomic, assign) NSData* data;

- (BOOL) save;
+ (NSString*) typeStringForType:(MessageTypes)type;
- (NSString*)typeString;

+ (instancetype) messageWithMessage:(NSDictionary*)newDic;
+ (instancetype) messageWithText:(NSString*)text;
+ (instancetype) messageWithPhoto:(PFFile*)file;
+ (instancetype) messageWithVideo:(PFFile*)file;
+ (instancetype) messageWithAudio:(PFFile*)file;
@end