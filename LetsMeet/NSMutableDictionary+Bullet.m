//
//  NSMutableDictionary+Bullet.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 4..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "NSMutableDictionary+Bullet.h"
#import "CachedFile.h"

#define ASSERTNOTNULL(__A__) NSAssert(__A__, @"__A__ cannot be nil")

@implementation NSMutableDictionary(Bullet)

+ (instancetype)bulletWithText:(NSString *)text
{
    Bullet* bullet = [Bullet new];
    bullet.bulletType = kBulletTypeText;
    bullet.message = text;
    return bullet;
}

+ (instancetype)bulletWithPhoto:(NSString*)filename thumbnail:(NSString *)thumbnail
{
    Bullet* bullet = [Bullet new];
    bullet.bulletType = kBulletTypePhoto;
    bullet.mediaFile = filename;
    bullet.mediaThumbnailFile = thumbnail;
    bullet.message = [[self bulletTypeStringForType:bullet.bulletType] stringByAppendingString:@" 메시지"];
    return bullet;
}

+ (instancetype)bulletWithVideo:(NSString*)filename thumbnail:(NSString *)thumbnail
{
    Bullet* bullet = [Bullet new];
    bullet.bulletType = kBulletTypeVideo;
    bullet.mediaFile = filename;
    bullet.mediaThumbnailFile = thumbnail;
    bullet.message = [[self bulletTypeStringForType:bullet.bulletType] stringByAppendingString:@" 메시지"];
    return bullet;
}

+ (instancetype)bulletWithAudio:(NSString*)filename thumbnail:(NSString *)thumbnail
{
    Bullet* bullet = [Bullet new];
    bullet.bulletType = kBulletTypeAudio;
    bullet.mediaFile = filename;
    bullet.mediaThumbnailFile = thumbnail;
    bullet.message = [[self bulletTypeStringForType:bullet.bulletType] stringByAppendingString:@" 메시지"];
    return bullet;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype) bulletWithBullet:(Bullet*)newDic
{
    Bullet* bullet = [[Bullet alloc] initWithDictionary:newDic];
    return bullet;
}

- (NSString *)objectId
{
    return [self objectForKey:@"objectId"];
}

- (void)setObjectId:(NSString *)objectId
{
    ASSERTNOTNULL(objectId);
    [self setObject:objectId forKey:@"objectId"];
}

- (NSString *)fromUserId
{
    return [self objectForKey:@"fromUser"];
}

- (void)setFromUserId:(NSString *)fromUserId
{
    ASSERTNOTNULL(fromUserId);
    [self setObject:fromUserId forKey:@"fromUser"];
}

- (NSString *)toUserId
{
    return [self objectForKey:@"toUser"];
}

- (void)setToUserId:(NSString *)toUserId
{
    ASSERTNOTNULL(toUserId);
    [self setObject:toUserId forKey:@"toUser"];
}

- (BulletTypes)bulletType
{
    return [[self objectForKey:@"bulletType"] integerValue];
}

- (NSString*)bulletTypeString
{
    return [Bullet bulletTypeStringForType:self.bulletType];
}

- (NSString*) defaultFileNameForBulletType
{
    switch (self.bulletType) {
        case kBulletTypePhoto:
            return @"photo.jpg";
        case kBulletTypeVideo:
            return @"video.mov";
        case kBulletTypeAudio:
            return @"audio.wav";
        case kBulletTypeURL:
        case kBulletTypeNone:
        case kBulletTypeText:
        default:
            return @"None";
    }
}

+ (NSString*)bulletTypeStringForType:(BulletTypes)bulletType
{
    switch (bulletType) {
        case kBulletTypeText:
            return @"Text";
        case kBulletTypePhoto:
            return @"Photo";
        case kBulletTypeVideo:
            return @"Video";
        case kBulletTypeAudio:
            return @"Audio";
        case kBulletTypeURL:
            return @"URL";
        case kBulletTypeNone:
        default:
            return @"None";
    }
}

-(void)setBulletType:(BulletTypes)bulletType
{
    [self setObject:@(bulletType) forKey:@"bulletType"];
}

-(NSString *)message
{
    return [self objectForKey:@"message"];
}

- (void)setMessage:(NSString *)message
{
    ASSERTNOTNULL(message);
    [self setObject:message forKey:@"message"];
}

- (NSString *) mediaFile
{
    return [self objectForKey:@"mediaFile"];
}

-(void)setMediaFile:(NSString *)mediaFile
{
    ASSERTNOTNULL(mediaFile);
    [self setObject:mediaFile forKey:@"mediaFile"];
}

- (NSString *)mediaThumbnailFile
{
    return [self objectForKey:@"mediaThumbnailFile"];
}

- (void)setMediaThumbnailFile:(NSString *)mediaThumbnailFile
{
    ASSERTNOTNULL(mediaThumbnailFile);
    [self setObject:mediaThumbnailFile forKey:@"mediaThumbnailFile"];
}

- (NSDate *)createdAt
{
    return [self objectForKey:@"createdAt"];
}

- (void)setCreatedAt:(NSDate *)createdAt
{
    ASSERTNOTNULL(createdAt);
    [self setObject:createdAt forKey:@"createdAt"];
}

- (NSDate *)updatedAt
{
    return [self objectForKey:@"updatedAt"];
}

- (void)setUpdatedAt:(NSDate *)updatedAt
{
    ASSERTNOTNULL(updatedAt);
    [self setObject:updatedAt forKey:@"updatedAt"];
}

- (BOOL)isSyncToUser
{
    return [[self objectForKey:@"isSyncToUser"] boolValue];
}

- (void)setIsSyncToUser:(BOOL)isSyncToUser
{
    [self setObject:@(isSyncToUser) forKey:@"isSyncToUser"];
}

- (BOOL)isSyncFromUser
{
    return [[self objectForKey:@"isSyncFromUser"] boolValue];
}

- (void)setIsSyncFromUser:(BOOL)isSyncFromUser
{
    [self setObject:@(isSyncFromUser) forKey:@"isSyncFromUser"];
}

- (BOOL)isRead
{
    return [[self objectForKey:@"isRead"] boolValue];
}

- (void)setIsRead:(BOOL)isRead
{
    [self setObject:@(isRead) forKey:@"isRead"];
}

- (BOOL)isFromMe
{
    return [[self fromUserId] isEqualToString:[PFUser currentUser].objectId];
}

- (NSData *)thumbnail
{
    return [self objectForKey:@"thumbnail"];
}

- (void)setThumbnail:(NSData *)thumbnail
{
    if (thumbnail) {
        thumbnail = compressedImageData(thumbnail, kThumbnailWidth);
        [self setObject:thumbnail forKey:@"thumbnail"];
    }
    else {
        [self removeObjectForKey:@"thumbnail"];
    }
}

- (BulletObject *)object
{
    BulletObject *object = [BulletObject object];
    
    object.fromUser = [User objectWithoutDataWithObjectId:self.fromUserId];
    object.toUser = [User objectWithoutDataWithObjectId:self.toUserId];
    
    if (self.message)
        object.message = self.message;
    
    object.bulletType = self.bulletType;
    object.isSyncFromUser = self.isSyncFromUser;
    object.isSyncToUser = self.isSyncToUser;
    object.mediaFile = self.mediaFile;
    object.mediaThumbnailFile = self.mediaThumbnailFile;
    
    //  object.isRead = self.isRead;
    //  NOT USING isRead ON THE PERSISTENCE LAYER
    
    return object;
}
@end


@implementation BulletObject
@dynamic fromUser;
@dynamic toUser;
@dynamic bulletType;
@dynamic message;
@dynamic isSyncToUser;
@dynamic isSyncFromUser;
@dynamic mediaThumbnailFile;
@dynamic mediaFile;

//@dynamic isRead;

#define IOTE(__X__) if (self.__X__) bullet.__X__ = self.__X__
#define IOTU(__X__, __Y__) if (self.__X__) bullet.__Y__ = self.__X__.objectId


- (Bullet *)bullet
{
    Bullet* bullet = [Bullet new];

    IOTE(objectId);
    IOTE(createdAt);
    IOTE(updatedAt);
    IOTU(fromUser, fromUserId);
    IOTU(toUser, toUserId);
    IOTE(mediaFile);
    IOTE(mediaThumbnailFile);
    IOTE(message);
    bullet.isSyncToUser = self.isSyncToUser;
    bullet.isSyncFromUser = self.isSyncFromUser;
    bullet.bulletType = self.bulletType;
    bullet.isRead = NO;
    
    return bullet;
}
 
+ (NSString *)parseClassName {
    return @"Bullets";
}

- (BOOL)isFromMe
{
    return [self.fromUser.objectId isEqualToString:[PFUser currentUser].objectId];
}

- (BOOL)isTextMessage
{
    return (self.bulletType == kBulletTypeText);
}

- (BOOL)isPhotoMessage
{
    return (self.bulletType == kBulletTypePhoto);
}

- (BOOL)isAudioMessage
{
    return (self.bulletType == kBulletTypeAudio);
}

-(BOOL)isVideoMessage
{
    return (self.bulletType == kBulletTypeVideo);
}

-(BOOL)isURLMessage
{
    return (self.bulletType == kBulletTypeURL);
}

@end

@implementation Originals
@dynamic messageId, file;

+ (NSString *)parseClassName {
    return @"Originals";
}

@end


@implementation User
@dynamic nickname,location,locationUdateAt, sex, age, intro, isSimulated, profileMedia, thumbnail, profileMediaType;

+ (instancetype) me
{
    return [User currentUser];
}

- (void) removeMe
{
    __LF
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UNIQUEDEVICEID"];
    if ([User me]) {
        [[User me] delete];
        [User logOut];
    }
}

+ (void) createMe
{
    __LF
    User *user = [User me];
    if ([User me])
        return;
    
    NSString *username = [User uniqueUsername];
    user = [User user];
    user.username = username;
    user.password = username;
    
    BOOL succeeded = [user signUp];
    if (succeeded) {
        [PFUser logInWithUsername:username password:username];
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if (!currentInstallation[@"user"]) {
            currentInstallation[@"user"] = user;
            [currentInstallation saveInBackground];
            NSLog(@"CURRENT INSTALLATION: saving user to Installation");
        }
        else {
            NSLog(@"CURRENT INSTALLATION: Installation already has user. No need to set");
        }
    }
}

+ (NSString*) uniqueUsername
{
    __LF
    NSString *cudid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UNIQUEDEVICEID"];
    NSString *idString;
    if (cudid) {
        idString = cudid;
    }
    else {
        idString = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        [[NSUserDefaults standardUserDefaults] setObject:idString forKey:@"UNIQUEDEVICEID"];
    }
    
    return idString;
}

- (NSString*) sexString
{
    return self.sex == kSexFemale? NSLocalizedString(@"여자", @"여자") : NSLocalizedString(@"남자", @"남자");
}

- (BOOL)profileIsPhoto
{
    return self.profileMediaType == kProfileMediaPhoto ? YES : NO;
}

- (BOOL)profileIsVideo
{
    return self.profileMediaType == kProfileMediaVideo ? YES : NO;
}

@end

