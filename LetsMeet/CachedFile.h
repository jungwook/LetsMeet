//
//  CachedFile.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Parse/Parse.h>

typedef void (^FileBooleanResultBlock)(PFFile *file, BOOL succeeded, NSError * error);

@interface CachedFile : NSCache
+ (void) getDataInBackgroundWithBlock:(PFDataResultBlock)block fromFile:(PFFile*)file;
+ (void) saveData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(FileBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock;
@end
