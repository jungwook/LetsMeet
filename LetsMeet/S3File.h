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
+ (void) getDataFromFile:(id)filename completedBlock:(S3GetBlock)block progressBlock:(S3ProgressBlock)progress;
+ (NSString*) saveData:(NSData*)data named:(id)filename extension:(NSString*)extension group:(id)group completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress;
+ (id)objectForKey:(id)key;

+ (NSString*) saveProfileImageData:(NSData*)data completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress;
+ (NSString*) saveProfileMovieData:(NSData*)data completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress;
+ (NSString*) saveProfileThumbnailData:(NSData*)data completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress;

+ (NSString*) saveImageData:(NSData*)data completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress;
+ (NSString*) saveMovieData:(NSData*)data completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress;

@end