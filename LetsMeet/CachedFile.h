//
//  CachedFile.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Parse/Parse.h>
#import "NSMutableDictionary+Bullet.h"

typedef void (^FileBooleanResultBlock)(PFFile *file, BOOL succeeded, NSError * error);
typedef void (^CachedFileBlock)(NSData * data, NSError * error, BOOL fromCache);

@interface CachedFile : NSCache
+ (void) getDataInBackgroundWithBlock:(CachedFileBlock)block fromFile:(PFFile*)file;
+ (NSData*) getDataInBackgroundWithBlock:(CachedFileBlock)block name:(NSString*)name andURL:(NSURL*)url;
+ (void) saveData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(FileBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock;
+ (id)objectForKey:(id)key;
+ (void) saveVideoData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(FileBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock;

@end

