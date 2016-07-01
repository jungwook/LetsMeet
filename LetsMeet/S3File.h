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

@interface S3File : NSObject
+ (void) synchronize;
+ (void) getDataFromFile:(id)filename completedBlock:(S3GetBlock)block progressBlock:(S3ProgressBlock)progress;
+ (void) getDataFromFile:(id)filename completedBlock:(S3GetBlock)block;
+ (id) objectForKey:(id)key;
/*
+ (NSString*) saveData:(NSData*)data
                 named:(id)filename
             extension:(NSString*)extension
                 group:(id)group
        completedBlock:(S3PutBlock)block
         progressBlock:(S3ProgressBlock)progress;

+ (NSString*) saveData:(NSData*)data
                 named:(id)filename
             extension:(NSString*)extension
                 group:(id)group
        completedBlock:(S3PutBlock)block
              progress:(UIProgressView*)progress;
*/
+ (NSString*) saveImageData:(NSData*)data;
+ (NSString*) saveMovieData:(NSData*)data;
+ (NSString*) saveAudioData:(NSData*)data;

+ (NSString*) saveImageData:(NSData*)data completedBlock:(S3PutBlock)block;
+ (NSString*) saveMovieData:(NSData*)data completedBlock:(S3PutBlock)block;
+ (NSString*) saveAudioData:(NSData*)data completedBlock:(S3PutBlock)block;

+ (NSString*) saveImageData:(NSData*)data completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress;
+ (NSString*) saveMovieData:(NSData*)data completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress;
+ (NSString*) saveAudioData:(NSData*)data completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress;
+ (NSString*) saveImageData:(NSData*)data completedBlock:(S3PutBlock)block progress:(UIProgressView*)progress;
+ (NSString*) saveMovieData:(NSData*)data completedBlock:(S3PutBlock)block progress:(UIProgressView*)progress;
+ (NSString*) saveAudioData:(NSData*)data completedBlock:(S3PutBlock)block progress:(UIProgressView*)progress;


@end