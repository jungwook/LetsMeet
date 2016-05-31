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

@interface Message : PFObject<PFSubclassing>
+ (NSString *)parseClassName;
@property (retain) PFUser *fromUser;
@property (retain) PFUser *toUser;
@property (retain) NSString *msgContent;
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
@end