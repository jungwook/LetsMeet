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

+ (void) getDataFromFile:(id)filename completedBlock:(S3GetBlock)block progressBlock:(S3ProgressBlock)progress
{
    [[S3File file] getDataFromFile:filename completedBlock:block progressBlock:progress];
}

- (void) getDataFromFile:(id)file completedBlock:(S3GetBlock)block progressBlock:(S3ProgressBlock)progress
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
        NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSURL URLWithString:file] lastPathComponent]];
        NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
        // If temp file exists then delete
        [[NSFileManager defaultManager] removeItemAtURL:downloadingFileURL error:nil];
        
        AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
        downloadRequest.bucket = @"parsekr";
        downloadRequest.key = file;
        downloadRequest.downloadingFileURL = downloadingFileURL;
        downloadRequest.downloadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            int rate = (int)(totalBytesSent * 100.0 / totalBytesExpectedToSend);
            if (progress) {
                progress(rate);
            }
        };
        
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

            // delete temp download file location.
            [[NSFileManager defaultManager] removeItemAtURL:downloadingFileURL error:nil];
            
            return nil;
        }];
    }
}

+ (void) saveData:(NSData *)data named:(id)filename completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress
{
    [[S3File file] saveData:data named:filename completedBlock:block progressBlock:progress];
}

- (void) saveData:(NSData *)data named:(id)name completedBlock:(S3PutBlock)block progressBlock:(S3ProgressBlock)progress
{
    if (data) {
        NSUUID *uuid = [NSUUID UUID];
        NSString *filename = [@"ParseFiles/" stringByAppendingString:[[uuid UUIDString] stringByAppendingString:name]];
        NSURL *uploadFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSURL URLWithString:filename] lastPathComponent]]];
        
        [[NSFileManager defaultManager] removeItemAtURL:uploadFileURL error:nil];
        BOOL ret = [data writeToURL:uploadFileURL atomically:YES];
        if (ret) {
            NSLog(@"UPLOADING DATA %@(%ld)", filename, data.length);
            AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
            AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
            uploadRequest.bucket = @"parsekr";
            uploadRequest.key = filename;
            uploadRequest.body = uploadFileURL;
            uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
            uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                int rate = (int)(totalBytesSent * 100.0 / totalBytesExpectedToSend);
                if (progress) {
                    progress(rate);
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
@end
