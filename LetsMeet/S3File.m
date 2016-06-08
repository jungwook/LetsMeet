//
//  S3File.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 9..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "S3File.h"

@implementation S3File

+ (instancetype) file
{
    static id sharedFile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFile = [[self alloc] init];
    });
    return sharedFile;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (id)objectForKey:(id)key
{
    return [[S3File file] objectForKey:key];
}

+ (void) getDataInBackgroundWithBlock:(S3GetBlock)block fromFile:(NSString*)file
{
    [[S3File file] getDataInBackgroundWithBlock:block fromFile:file];
}

- (void) getDataInBackgroundWithBlock:(S3GetBlock)block fromFile:(NSString*)file
{
    if (!file) {
        if (block) {
            block(nil, nil, YES);
        }
    }

    NSData *data = [self objectForKey:file];
    if (data) {
        if (block) {
            block(data, nil, YES);
        }
    }
    else {
        NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:file];
        NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
        [[NSFileManager defaultManager] removeItemAtURL:downloadingFileURL error:nil];
        
        AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
        downloadRequest.bucket = @"parsekr";
        downloadRequest.key = file;
        downloadRequest.downloadingFileURL = downloadingFileURL;
        
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        NSLog(@"Download started, please wait...");
        
        [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task){
            if (task.error != nil) {
                NSLog(@"%s %@","Error downloading :", downloadRequest.key);
                if (block) {
                    block(nil, task.error, NO);
                }
            }
            else {
                NSLog(@"download completed");
                NSData *downloadedData = [NSData dataWithContentsOfURL:downloadingFileURL];
                [self setObject:downloadedData forKey:file];
                if (block) {
                    block(downloadedData, task.error, NO);
                }
            }
            [[NSFileManager defaultManager] removeItemAtURL:downloadingFileURL error:nil];
            return nil;
        }];
    }
}

- (void) saveData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progressBlock
{
    if (data) {
        NSUUID *uuid = [NSUUID UUID];
        NSString *filename = [[uuid UUIDString] stringByAppendingString:name];
        
        NSURL *uploadFileURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:filename];
        BOOL ret = [data writeToURL:uploadFileURL atomically:YES];
        if (ret) {
            NSLog(@"UPLOADING DATA %@(%ld)", filename, data.length);
            AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
            AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
            uploadRequest.bucket = @"parsekr";
            uploadRequest.key = filename;
            uploadRequest.body = uploadFileURL;
            uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                int progress = (int)(totalBytesSent * 100.0 / totalBytesExpectedToSend);
                if (progressBlock) {
                    progressBlock(progress);
                }
            };
            
            [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
                if (task.error != nil) {
                    NSLog(@"%s %@","Error uploading :", uploadRequest.key);
                    if (block) {
                        block(nil, NO, task.error);
                    }
                }
                else {
                    NSLog(@"Upload completed");
                    [self setObject:data forKey:filename];
                    if (block) {
                        block(filename, YES, nil);
                    }
                }
                [[NSFileManager defaultManager] removeItemAtURL:uploadFileURL error:nil];
                return nil;
            }];
        }
    }
    else {
        if (block) {
            block(nil, YES, nil);
        }
    }
}

+(void)saveData:(NSData *)data named:(NSString *)name inBackgroundWithBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progressBlock
{
    return [[S3File file] saveData:data named:name inBackgroundWithBlock:block progressBlock:progressBlock];
}

@end
