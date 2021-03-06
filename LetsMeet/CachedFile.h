//
//  CachedFile.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppEngine.h"

typedef void (^FileBooleanResultBlock)(PFFile *file, BOOL succeeded, NSError * error);

@interface CachedFile : NSCache
+ (void) getDataInBackgroundWithBlock:(CachedFileBlock)block fromFile:(PFFile*)file;
+ (NSData*) getDataInBackgroundWithBlock:(CachedFileBlock)block name:(NSString*)name andURL:(NSURL*)url;
+ (PFFile*) saveData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(FileBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock;
+ (id)objectForKey:(id)key;

@end
