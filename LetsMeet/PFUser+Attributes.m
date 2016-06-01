//
//  PFUser+Attributes.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 27..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PFUser+Attributes.h"
#import "AppEngine.h"

@implementation NSDictionary(Messages)


@end

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


@implementation Message
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
    return [self.msgType isEqualToString:AppMessageTypeMessage];
}

- (BOOL)isPhotoMessage
{
    return [self.msgType isEqualToString:AppMessageTypePhoto];
}

- (BOOL)isAudioMessage
{
    return [self.msgType isEqualToString:AppMessageTypeAudio];
}

-(BOOL)isVideoMessage
{
    return [self.msgType isEqualToString:AppMessageTypeVideo];
}

-(BOOL)isURLMessage
{
    return [self.msgType isEqualToString:AppMessageTypeURL];
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
