//
//  NSMutableDictionary+Bullet.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 4..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileSystem.h"

typedef NS_OPTIONS(NSUInteger, MediaTypes) {
    kMediaTypeNone = 0,
    kMediaTypeText,
    kMediaTypePhoto,
    kMediaTypeVideo,
    kMediaTypeAudio,
    kMediaTypeURL,
    kMediaTypeMap
};

@class Progress;
@class MessageObject;
@class User;

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
typedef void (^ImageSizePickerBlock)(NSData *data, Progress* progress);
typedef void (^NewUserBlock)(User* me);

#define kJPEGCompressionLow 0.2f
#define kJPEGCompressionMedium 0.4f
#define kJPEGCompressionDefault 0.6f
#define kJPEGCompressionFull 1.0f

#define kAudioThumbnailWidth 300.0f
#define kThumbnailWidth 220.0f
#define kTextMessageWidth 220.0f

typedef NSMutableDictionary Bullet;

@interface NSMutableDictionary(Bullet)
@property (nonatomic, assign) NSString* objectId;
@property (nonatomic, assign) NSString* fromUserId;
@property (nonatomic, assign) NSString* toUserId;
@property (nonatomic, assign) NSString* message;
@property (nonatomic, assign) NSString* mediaFile;
@property (nonatomic, assign) NSString* mediaThumbnailFile;
@property (nonatomic, assign) NSDate* createdAt;
@property (nonatomic, assign) NSDate* updatedAt;
@property (nonatomic, assign) PFGeoPoint* fromLocation;
@property (nonatomic, assign) MediaTypes mediaType;
@property (nonatomic, assign) CGSize mediaSize;
@property (nonatomic, assign) BOOL realMedia;
@property (nonatomic, assign) BOOL isSyncFromUser;
@property (nonatomic, assign) BOOL isSyncToUser;
@property (nonatomic, assign) BOOL isRead;

- (BOOL) isFromMe;
+ (NSString*) mediaTypeStringForType:(MediaTypes)mediaType;
- (NSString*) mediaTypeString;
- (NSString*) defaultFileNameForMediaType;

+ (instancetype) bulletWithBullet:(Bullet*)newDic;
+ (instancetype) bulletWithText:(NSString*)text;
+ (instancetype) bulletWithPhoto:(NSString*)filename thumbnail:(NSString*)thumbnail mediaSize:(CGSize)size realMedia:(BOOL)realMedia;
+ (instancetype) bulletWithVideo:(NSString*)filename thumbnail:(NSString*)thumbnail mediaSize:(CGSize)size realMedia:(BOOL)realMedia;
+ (instancetype) bulletWithAudio:(NSString*)filename thumbnail:(NSString*)thumbnail audioTicks:(CGFloat)length audioSize:(CGFloat)size;

- (MessageObject*) object;
- (CGFloat) audioTicks;
- (CGFloat) audioSize;
@end

@interface MessageObject : PFObject<PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) PFUser *fromUser;
@property (retain) PFUser *toUser;
@property (retain) PFGeoPoint *fromLocation;
@property (retain) NSString *message;
@property (retain) NSString *mediaFile;
@property (retain) NSString *mediaThumbnailFile;
@property CGFloat mediaWidth, mediaHeight;
@property MediaTypes mediaType;
@property BOOL isSyncFromUser;
@property BOOL isSyncToUser;
@property BOOL realMedia;

- (BOOL) isFromMe;
- (Bullet*) bullet;
@end


typedef NS_OPTIONS(BOOL, SexTypes)
{
    kSexMale = 0,
    kSexFemale
};

typedef NS_OPTIONS(BOOL, ProfileMediaTypes)
{
    kProfileMediaPhoto = 0,
    kProfileMediaVideo
};

@interface UserMedia : PFObject <PFSubclassing>
@property (retain) NSString* userId;
@property ProfileMediaTypes mediaType;
@property (retain) NSString* thumbailFile;
@property (retain) NSString* mediaFile;
@property CGSize mediaSize;
@end

@interface User : PFUser<PFSubclassing>
@property (retain) NSString* nickname;
@property (retain) PFGeoPoint* location;
@property (retain) NSDate* locationUdateAt;
@property (retain) NSString* age;
@property (retain) NSString* intro;
@property (retain) NSString* profileMedia;
@property (retain) NSString* thumbnail;
@property (retain) NSMutableArray* media;
@property ProfileMediaTypes profileMediaType;

@property BOOL isSimulated;
@property SexTypes sex;

+ (instancetype) me;
- (void) removeMe;
- (NSString*) sexString;
- (BOOL) profileIsVideo;
- (BOOL) profileIsPhoto;
- (void) setSexFromString:(NSString*)sex;
- (NSString*) sexImageName;
@end

