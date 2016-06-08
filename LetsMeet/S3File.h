//
//  S3File.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^S3GetBlock)(NSData * data, NSError * error, BOOL fromCache);
typedef void (^S3PutBlock)(NSString *file, BOOL succeeded, NSError * error);
typedef void (^S3ProgressBlock)(int percentDone);

@interface S3File : NSCache
+ (void) getDataInBackgroundWithBlock:(S3GetBlock)block fromFile:(NSString*)file;
+ (void) saveData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progressBlock;
+ (id)objectForKey:(id)key;
@end