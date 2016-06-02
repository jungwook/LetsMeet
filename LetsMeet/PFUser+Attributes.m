//
//  PFUser+Attributes.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PFUser+Attributes.h"
#import "AppEngine.h"


@implementation PFUser(Attributes)
- (void) setNickname:(NSString *)nickname
{
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
    [self setObject:age forKeyedSubscript:AppKeyAgeKey];
}

-(void)setIntro:(NSString *)intro
{
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
    [self setObject:profilePhoto forKey:AppProfilePhotoField];
}

- (PFFile *)originalPhoto
{
    return [self objectForKey:AppProfileOriginalPhotoField];
}

- (void)setOriginalPhoto:(PFFile *)originalPhoto
{
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
    [self setObject:broadcastMessage forKey:AppKeyBroadcastMessageKey];
}

- (NSDate *)broadcastMessageAt
{
    return [self objectForKey:AppKeyBroadcastMessageAtKey];
}

- (void)setBroadcastMessageAt:(NSDate *)date
{
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
@dynamic msgType;
@dynamic msgContent;
@dynamic file;
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
    return [self.msgType isEqualToString:@"MSG"];
}

- (BOOL)isPhotoMessage
{
    return [self.msgType isEqualToString:@"PHOTO"];
}

- (BOOL)isAudioMessage
{
    return [self.msgType isEqualToString:@"AUDIO"];
}

-(BOOL)isVideoMessage
{
    return [self.msgType isEqualToString:@"VIDEO"];
}

-(BOOL)isURLMessage
{
    return [self.msgType isEqualToString:@"URL"];
}

- (NSString*) info
{
    NSString* ret = [NSString stringWithFormat:@"ID:%@ CREATED:%@ UPDATED:%@ FROM:%@ TO:%@ TYPE:%@ MESSAGE:%@ HAS DATA:%@",
                     self.objectId,
                     self.createdAt,
                     self.updatedAt,
                     self.fromUser.nickname,
                     self.toUser.nickname,
                     self.msgType,
                     self.msgContent,
                     self.file ? @"YES" : @"NO"];
    
    return ret;
}
@end


@interface Message()

@end

@implementation Message
- (NSString *)fromUserId
{
    return [self objectForKey:@"fromUser"];
}

- (void)setFromUserId:(NSString *)fromUserId
{
    [self setObject:fromUserId forKey:@"fromUser"];
}

- (NSString *)toUserId
{
    return [self objectForKey:@"toUser"];
}

- (void)setToUserId:(NSString *)toUserId
{
    [self setObject:toUserId forKey:@"toUser"];
}

- (MessageTypes)type
{
    if ([[self objectForKey:@"msgType"] isEqualToString:@"MSG"]) {
        return kMessageTypeText;
    }
    else if ([[self objectForKey:@"msgType"] isEqualToString:@"PHOTO"]) {
        return kMessageTypePhoto;
    }
    else if ([[self objectForKey:@"msgType"] isEqualToString:@"VIDEO"]) {
        return kMessageTypeVideo;
    }
    else if ([[self objectForKey:@"msgType"] isEqualToString:@"AUDIO"]) {
        return kMessageTypeAudio;
    }
    else if ([[self objectForKey:@"msgType"] isEqualToString:@"URL"]) {
        return kMessageTypeURL;
    }
    else
        return kMessageTypeNone;
}

- (void)setType:(MessageTypes)type
{
    switch (type) {
        case kMessageTypeText:
            [self setObject:@"MSG" forKey:@"msgType"];
            break;
        case kMessageTypePhoto:
            [self setObject:@"PHOTO" forKey:@"msgType"];
            break;
        case kMessageTypeVideo:
            [self setObject:@"VIDEO" forKey:@"msgType"];
            break;
        case kMessageTypeAudio:
            [self setObject:@"AUDIO" forKey:@"msgType"];
            break;
        case kMessageTypeURL:
            [self setObject:@"URL" forKey:@"msgType"];
            break;
        case kMessageTypeNone:
        default:
            break;
    }
}

-(NSString *)text
{
    return [self objectForKey:@"msgContent"];
}

- (void)setText:(NSString *)text
{
    [self setObject:text forKey:@"msgContent"];
}

- (NSString *)fileName
{
    return [self objectForKey:@"file"][@"name"];
}

- (void)setFileName:(NSString *)fileName
{
    NSMutableDictionary *file = [self objectForKey:@"file"] ? [self objectForKey:@"file"] : [NSMutableDictionary dictionary];
    [file setObject:fileName forKey:@"name"];
    [self setObject:file forKey:@"file"];
}

- (NSString *)fileURL
{
    return [self objectForKey:@"file"][@"url"];
}

- (void)setFileURL:(NSString *)fileURL
{
    NSMutableDictionary *file = [self objectForKey:@"file"] ? [self objectForKey:@"file"] : [NSMutableDictionary dictionary];
    [file setObject:fileURL forKey:@"url"];
    [self setObject:file forKey:@"file"];
}

- (NSDate *)createdAt
{
    return [self objectForKey:@"createdAt"];
}

- (void)setCreatedAt:(NSDate *)createdAt
{
    [self setObject:createdAt forKey:@"createdAt"];
}

- (NSDate *)updatedAt
{
    return [self objectForKey:@"updatedAt"];
}

- (void)setUpdatedAt:(NSDate *)updatedAt
{
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

@end
