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
    bullet.mediaType = kMediaTypeText;
    bullet.message = text;
    return bullet;
}

+ (instancetype)bulletWithPhoto:(NSString*)filename thumbnail:(NSString *)thumbnail mediaSize:(CGSize)size realMedia:(BOOL)realMedia
{
    Bullet* bullet = [Bullet new];
    bullet.mediaType = kMediaTypePhoto;
    bullet.mediaFile = filename;
    bullet.mediaThumbnailFile = thumbnail;
    bullet.message = [[self mediaTypeStringForType:bullet.mediaType] stringByAppendingString:@" 메시지"];
    bullet.mediaSize = size;
    bullet.realMedia = realMedia;
    return bullet;
}

+ (instancetype)bulletWithVideo:(NSString*)filename thumbnail:(NSString *)thumbnail mediaSize:(CGSize)size realMedia:(BOOL)realMedia
{
    Bullet* bullet = [Bullet new];
    bullet.mediaType = kMediaTypeVideo;
    bullet.mediaFile = filename;
    bullet.mediaThumbnailFile = thumbnail;
    bullet.message = [[self mediaTypeStringForType:bullet.mediaType] stringByAppendingString:@" 메시지"];
    bullet.mediaSize = size;
    bullet.realMedia = realMedia;
    return bullet;
}

+ (instancetype)bulletWithAudio:(NSString*)filename thumbnail:(NSString *)thumbnail audioTicks:(CGFloat)length audioSize:(CGFloat)size
{
    Bullet* bullet = [Bullet new];
    bullet.mediaType = kMediaTypeAudio;
    bullet.mediaFile = filename;
    bullet.mediaThumbnailFile = thumbnail;
    bullet.message = [[self mediaTypeStringForType:bullet.mediaType] stringByAppendingString:@" 메시지"];
    bullet.realMedia = YES;
    bullet.mediaSize = CGSizeMake(length, size);
    return bullet;
}

- (CGFloat)audioSize
{
    if (self.mediaType == kMediaTypeAudio) {
        return self.mediaSize.height;
    }
    else
        return 0;
}

- (CGFloat)audioTicks
{
    if (self.mediaType == kMediaTypeAudio) {
        return self.mediaSize.width;
    }
    else
        return 0;
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

- (MediaTypes)mediaType
{
    return [[self objectForKey:@"mediaType"] integerValue];
}

- (NSString*)mediaTypeString
{
    return [Bullet mediaTypeStringForType:self.mediaType];
}

- (NSString*) defaultFileNameForMediaType
{
    switch (self.mediaType) {
        case kMediaTypePhoto:
            return @"photo.jpg";
        case kMediaTypeVideo:
            return @"video.mov";
        case kMediaTypeAudio:
            return @"audio.wav";
        case kMediaTypeURL:
        case kMediaTypeNone:
        case kMediaTypeText:
        default:
            return @"None";
    }
}

+ (NSString*)mediaTypeStringForType:(MediaTypes)mediaType
{
    switch (mediaType) {
        case kMediaTypeText:
            return @"Text";
        case kMediaTypePhoto:
            return @"Photo";
        case kMediaTypeVideo:
            return @"Video";
        case kMediaTypeAudio:
            return @"Audio";
        case kMediaTypeURL:
            return @"URL";
        case kMediaTypeNone:
        default:
            return @"None";
    }
}

- (void)setMediaSize:(CGSize)mediaSize
{
    [self setObject:@(mediaSize.width) forKey:@"mediaWidth"];
    [self setObject:@(mediaSize.height) forKey:@"mediaHeight"];
}

- (CGSize)mediaSize
{
    CGFloat height = [[self objectForKey:@"mediaHeight"] floatValue];
    CGFloat width = [[self objectForKey:@"mediaWidth"] floatValue];
    
    return CGSizeMake(width, height);
}

- (void)setRealMedia:(BOOL)realMedia
{
    [self setObject:@(realMedia) forKey:@"realMedia"];
}

- (BOOL)realMedia
{
    return [[self objectForKey:@"realMedia"] boolValue];
}

- (PFGeoPoint *)fromLocation
{
    CGFloat latitude = [[self objectForKey:@"latitude"] floatValue];
    CGFloat longitude = [[self objectForKey:@"longitude"] floatValue];
    
    return [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
}

- (void)setFromLocation:(PFGeoPoint *)fromLocation
{
    [self setObject:@(fromLocation.latitude) forKey:@"latitude"];
    [self setObject:@(fromLocation.longitude) forKey:@"longitude"];
}

-(void)setMediaType:(MediaTypes)mediaType
{
    [self setObject:@(mediaType) forKey:@"mediaType"];
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

- (MessageObject *)object
{
    MessageObject *object = [MessageObject object];
    
    object.fromUser = [User objectWithoutDataWithObjectId:self.fromUserId];
    object.toUser = [User objectWithoutDataWithObjectId:self.toUserId];
    
    if (self.message) object.message = self.message;
    if (self.mediaFile) object.mediaFile = self.mediaFile;
    if (self.mediaThumbnailFile) object.mediaThumbnailFile = self.mediaThumbnailFile;
    if (self.fromLocation) object.fromLocation = self.fromLocation;
    
    object.mediaType = self.mediaType;
    object.isSyncFromUser = self.isSyncFromUser;
    object.isSyncToUser = self.isSyncToUser;
    object.mediaHeight = self.mediaSize.height;
    object.mediaWidth = self.mediaSize.width;
    object.realMedia = self.realMedia;
    
    return object;
}
@end


@implementation MessageObject
@dynamic fromUser;
@dynamic toUser;
@dynamic fromLocation;
@dynamic mediaType;
@dynamic message;
@dynamic isSyncToUser;
@dynamic isSyncFromUser;
@dynamic mediaThumbnailFile;
@dynamic mediaFile;
@dynamic realMedia;
@dynamic mediaWidth, mediaHeight;

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
    IOTE(fromLocation);
    IOTE(mediaFile);
    IOTE(mediaThumbnailFile);
    IOTE(message);
    bullet.mediaSize = CGSizeMake(self.mediaWidth, self.mediaHeight);
    bullet.realMedia = self.realMedia;
    bullet.isSyncToUser = self.isSyncToUser;
    bullet.isSyncFromUser = self.isSyncFromUser;
    bullet.mediaType = self.mediaType;
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

@end

@implementation User
@dynamic nickname,location,locationUdateAt, sex, age, intro, isSimulated, profileMedia, thumbnail, profileMediaType, isRealMedia, media;

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

- (void)setSexFromString:(NSString *)sex
{
    self.sex = [sex isEqualToString:@"여자"] ? kSexFemale : kSexMale;
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

- (void) setLocation:(PFGeoPoint *)location
{
    [self setObject:location forKey:@"location"];
    [self setObject:[NSDate date] forKey:@"locationUpdatedAt"];
    [self saveInBackground];
}

- (NSString *)sexImageName
{
    return (self.sex == kSexMale) ? @"guy" : @"girl";
}

- (UIColor*) sexColor
{
    return (self.sex == kSexMale) ?
    [UIColor colorWithRed:95/255.f green:167/255.f blue:229/255.f alpha:1.0f] :
    [UIColor colorWithRed:240/255.f green:82/255.f blue:10/255.f alpha:1.0f];
}

@end

@implementation UserMedia
@dynamic userId, mediaType, thumbailFile, mediaFile, mediaSize, isRealMedia;

+ (NSString *)parseClassName {
    return @"UserMedia";
}

- (void)setMediaSize:(CGSize)mediaSize
{
    [self setObject:@(mediaSize.width) forKey:@"mediaWidth"];
    [self setObject:@(mediaSize.height) forKey:@"mediaHeight"];
}

- (CGSize)mediaSize
{
    return CGSizeMake([[self objectForKey:@"mediaWidth"] floatValue], [[self objectForKey:@"mediaHeight"] floatValue]);
}
@end

