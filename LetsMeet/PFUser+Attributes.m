//
// PFUser+Attributes.m
// LetsMeet
//
// Created by 한정욱 on 2016. 5. 27..
// Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PFUser+Attributes.h"
#import "AppEngine.h"

#define ASSERTNOTNULL(__A__) NSAssert(__A__, @"__A__ cannot be nil")


@implementation PFUser(Attributes)

- (void) setNickname:(NSString *)nickname
{
    ASSERTNOTNULL(nickname);
    [self setObject:nickname forKey:AppKeyNicknameKey];
}

- (NSString *)nickname
{
    return [self objectForKey:AppKeyNicknameKey];
}

-(PFGeoPoint *)location
{
    return [self objectForKey:AppKeyLocationKey];
}

- (void)setLocation:(PFGeoPoint *)location
{
    ASSERTNOTNULL(location);
    [self setObject:location forKeyedSubscript:AppKeyLocationKey];
}

-(NSString *)age
{
    return [self objectForKey:AppKeyAgeKey];
}

-(BOOL) sex
{
    return [[self objectForKey:AppKeySexKey] boolValue];
}

- (NSString *)intro
{
    return [self objectForKey:AppKeyIntroKey];
}

- (void)setAge:(NSString *)age
{
    ASSERTNOTNULL(age);
    [self setObject:age forKeyedSubscript:AppKeyAgeKey];
}

-(void)setIntro:(NSString *)intro
{
    ASSERTNOTNULL(intro);
    [self setObject:intro forKey:AppKeyIntroKey];
}

- (void)setSex:(BOOL)sex
{
    [self setObject:@(sex) forKey:AppKeySexKey];
}

- (PFFile *)profilePhoto
{
    return [self objectForKey:AppProfilePhotoField];
}

- (void)setProfilePhoto:(PFFile *)profilePhoto
{
    ASSERTNOTNULL(profilePhoto);
    [self setObject:profilePhoto forKey:AppProfilePhotoField];
}

- (PFFile *)originalPhoto
{
    return [self objectForKey:AppProfileOriginalPhotoField];
}

- (void)setOriginalPhoto:(PFFile *)originalPhoto
{
    ASSERTNOTNULL(originalPhoto);
    [self setObject:originalPhoto forKey:AppProfileOriginalPhotoField];
}

- (CGPoint) coords
{
    int x = [self[@"hive-x"] intValue];
    int y = [self[@"hive-y"] intValue];
    
    return CGPointMake(x, y);
}

- (NSString *)broadcastMessage
{
    return [self objectForKey:AppKeyBroadcastMessageKey];
}

- (void)setBroadcastMessage:(NSString *)broadcastMessage
{
    ASSERTNOTNULL(broadcastMessage);
    [self setObject:broadcastMessage forKey:AppKeyBroadcastMessageKey];
}

- (NSDate *)broadcastMessageAt
{
    return [self objectForKey:AppKeyBroadcastMessageAtKey];
}

- (void)setBroadcastMessageAt:(NSDate *)date
{
    ASSERTNOTNULL(date);
    [self setObject:date forKey:AppKeyBroadcastMessageAtKey];
}

- (void) setCoords:(CGPoint)coords
{
    [self setObject:@(coords.x) forKey:@"hive-x"];
    [self setObject:@(coords.y) forKey:@"hive-y"];
}

- (NSNumber *)broadcastDuration
{
    return [self objectForKey:@"broadcastDuration"];
}

- (void)setBroadcastDuration:(NSNumber *)broadcastDuration
{
    ASSERTNOTNULL(broadcastDuration);
    [self setObject:broadcastDuration forKey:@"broadcastDuration"];
}

- (char*) desc
{
    return (char*) [self.nickname UTF8String];
}
@end

@implementation MessageObject
@dynamic fromUser;
@dynamic toUser;
@dynamic type;
@dynamic message;
@dynamic file;
@dynamic mediaInfo;
@dynamic isSyncToUser, isSyncFromUser, isRead;

+ (NSString *)parseClassName {
    return @"Messages";
}

- (BOOL)isFromMe
{
    return [self.fromUser.objectId isEqualToString:[PFUser currentUser].objectId];
}

- (BOOL)isTextMessage
{
    return (self.type == kMessageTypeText);
}

- (BOOL)isPhotoMessage
{
    return (self.type == kMessageTypePhoto);
}

- (BOOL)isAudioMessage
{
    return (self.type == kMessageTypeAudio);
}

-(BOOL)isVideoMessage
{
    return (self.type == kMessageTypeVideo);
}

-(BOOL)isURLMessage
{
    return (self.type == kMessageTypeURL);
}

- (NSString*) info
{
    NSString* ret = [NSString stringWithFormat:@"ID:%@ CREATED:%@ UPDATED:%@ FROM:%@ TO:%@ TYPE:%@ MESSAGE:%@ HAS DATA:%@",
                     self.objectId,
                     self.createdAt,
                     self.updatedAt,
                     self.fromUser,
                     self.toUser,
                     [Message typeStringForType:self.type],
                     self.message,
                     self.file ? @"YES" : @"NO"];
    
    return ret;
}
@end



@implementation NSMutableDictionary(Message)

+ (instancetype)messageWithText:(NSString *)text
{
    Message* message = [Message new];
    message.type = kMessageTypeText;
    message.message = text;
    return message;
}

+ (instancetype)messageWithPhoto:(PFFile*)file
{
    Message* message = [Message new];
    message.type = kMessageTypePhoto;
    message.fileName = file.name;
    message.fileURL = file.url;
    return message;
}

+ (instancetype)messageWithVideo:(PFFile*)file
{
    Message* message = [Message new];
    message.type = kMessageTypeVideo;
    message.fileName = file.name;
    message.fileURL = file.url;
    return message;
}

+ (instancetype)messageWithAudio:(PFFile*)file
{
    Message* message = [Message new];
    message.type = kMessageTypeAudio;
    message.fileName = file.name;
    message.fileURL = file.url;
    return message;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype) messageWithMessage:(NSDictionary*)newDic
{
    Message* message = [[Message alloc] initWithDictionary:newDic];
    return message;
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

- (MessageTypes)type
{
    return [[self objectForKey:@"type"] integerValue];
}

- (NSString*)typeString
{
    switch (self.type) {
        case kMessageTypeText:
            return @"MSG";
        case kMessageTypePhoto:
            return @"PHOTO";
        case kMessageTypeVideo:
            return @"VIDEO";
        case kMessageTypeAudio:
            return @"AUDIO";
        case kMessageTypeURL:
            return @"URL";
        case kMessageTypeNone:
        default:
            return @"NONE";
    }
}

+ (NSString*)typeStringForType:(MessageTypes)type
{
    switch (type) {
        case kMessageTypeText:
            return @"MSG";
        case kMessageTypePhoto:
            return @"PHOTO";
        case kMessageTypeVideo:
            return @"VIDEO";
        case kMessageTypeAudio:
            return @"AUDIO";
        case kMessageTypeURL:
            return @"URL";
        case kMessageTypeNone:
        default:
            return @"NONE";
    }
}


- (void)setType:(MessageTypes)type
{
    [self setObject:@(type) forKey:@"type"];
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

- (NSString *)mediaInfo
{
    return [self objectForKey:@"mediaInfo"];
}

- (void)setMediaInfo:(NSString *)mediaInfo
{
    ASSERTNOTNULL(mediaInfo);
    [self setObject:mediaInfo forKey:@"mediaInfo"];
}

- (NSString *)fileName
{
    return [self objectForKey:@"fileName"];
}

- (void)setFileName:(NSString *)fileName
{
    ASSERTNOTNULL(fileName);
    [self setObject:fileName forKey:@"fileName"];
}

- (NSString *)fileURL
{
    return [self objectForKey:@"fileURL"];
}

- (void)setFileURL:(NSString *)fileURL
{
    ASSERTNOTNULL(fileURL);
    [self setObject:fileURL forKey:@"fileURL"];
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

- (NSData *)data
{
    return [self objectForKey:@"data"];
}

- (void)setData:(NSData *)data
{
    if (data) {
        data = compressedImageData(data, 230.0f);
        [self setObject:data forKey:@"data"];
    }
    else {
        [self removeObjectForKey:@"data"];
    }
}

- (BOOL)isDataAvailable
{
    return [self objectForKey:@"data"] ? YES : NO;
}

- (BOOL)save
{
    id otherId = [self.fromUserId isEqualToString:[PFUser currentUser].objectId] ? self.toUserId : self.fromUserId;
    return [AppEngine appEngineUpdateFileForUserId:otherId];
}

@end
