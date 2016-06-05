//
//  NSMutableDictionary+Bullet.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 4..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileSystem.h"

typedef NS_OPTIONS(NSUInteger, BulletTypes) {
    kBulletTypeNone = 0,
    kBulletTypeText,
    kBulletTypePhoto,
    kBulletTypeVideo,
    kBulletTypeAudio,
    kBulletTypeURL
};

#define kJPEGCompressionLow 0.2f
#define kJPEGCompressionMedium 0.4f
#define kJPEGCompressionDefault 0.6f
#define kJPEGCompressionFull 1.0f
#define kThumbnailWidth 230.0f

typedef NSMutableDictionary Bullet;
@class BulletObject;

@interface NSMutableDictionary(Bullet)
@property (nonatomic, assign) NSString* objectId;
@property (nonatomic, assign) NSString* fromUserId;
@property (nonatomic, assign) NSString* toUserId;
@property (nonatomic, assign) NSString* message;
@property (nonatomic, assign) NSString* fileName;
@property (nonatomic, assign) NSString* fileURL;
@property (nonatomic, assign) NSString* mediaInfo;
@property (nonatomic, assign) NSDate* createdAt;
@property (nonatomic, assign) NSDate* updatedAt;
@property (nonatomic) BulletTypes bulletType;
@property (nonatomic) BOOL isSyncFromUser;
@property (nonatomic) BOOL isSyncToUser;
@property (nonatomic) BOOL isRead;
@property (nonatomic, assign) NSData* thumbnail;

- (BOOL) isFromMe;
- (BOOL) isDataAvailable;

+ (NSString*) bulletTypeStringForType:(BulletTypes)bulletType;
- (NSString*) bulletTypeString;
- (NSString*) defaultNameForBulletType;

+ (instancetype) bulletWithBullet:(Bullet*)newDic;
+ (instancetype) bulletWithText:(NSString*)text;
+ (instancetype) bulletWithPhoto:(PFFile*)file;
+ (instancetype) bulletWithVideo:(PFFile*)file;
+ (instancetype) bulletWithAudio:(PFFile*)file;

- (BulletObject*) object;
@end

@interface BulletObject : PFObject<PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) PFUser *fromUser;
@property (retain) PFUser *toUser;
@property (retain) PFFile* file;
@property (retain) NSString *message;
@property (retain) NSString *mediaInfo;
@property BulletTypes bulletType;
@property BOOL isSyncFromUser;
@property BOOL isSyncToUser;
@property BOOL isRead;

- (BOOL) isTextMessage;
- (BOOL) isPhotoMessage;
- (BOOL) isVideoMessage;
- (BOOL) isAudioMessage;
- (BOOL) isURLMessage;
- (BOOL) isFromMe;
- (Bullet*) bullet;
@end

@interface Originals : PFObject<PFSubclassing>
+ (NSString*)parseClassName;

@property (retain) NSString* messageId;
@property (retain) PFFile* file;

@end

typedef NS_OPTIONS(BOOL, SexTypes)
{
    kSexMale = 0,
    kSexFemale
};

@interface User : PFUser<PFSubclassing>
@property (retain) NSString* nickname;
@property (retain) PFGeoPoint* location;
@property (retain) NSDate* locationUdateAt;
@property SexTypes sex;
@property (retain) NSString* age;
@property (retain) NSString* intro;
@property (retain) PFFile* profilePhoto;
@property (retain) PFFile* originalPhoto;

+ (instancetype) me;
@end



