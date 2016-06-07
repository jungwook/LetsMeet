//
//  CachedFile.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CachedFile.h"


@interface CachedFile()
@property (nonatomic, strong) NSMutableSet* downloadsInProgress;
@end

@implementation CachedFile

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
        _downloadsInProgress = [NSMutableSet set];
    }
    return self;
}

+ (id)objectForKey:(id)key
{
    return [[CachedFile file] objectForKey:key];
}

+ (NSData*) getDataInBackgroundWithBlock:(CachedFileBlock)block name:(NSString*)name andURL:(NSURL*)url
{
    return [[CachedFile file] getDataInBackgroundWithBlock:block name:name andURL:url];
}

- (NSData*) getDataInBackgroundWithBlock:(CachedFileBlock)block name:(NSString*)name andURL:(NSURL*)url
{
    if (!url || !name) {
        if (block) {
            block(nil, nil, YES);
        }
    }
    
    NSData *data = [self objectForKey:name];
    if (data) {
        return data;
    }
    else {
        if (![self.downloadsInProgress containsObject:name]) {
            @synchronized (self.downloadsInProgress) {
                [self.downloadsInProgress addObject:name];
            }
            NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                NSData* data = [NSData dataWithContentsOfURL:location];
                if (!error) {
                    [self setObject:data forKey:name];
                }
                if (block) {
                    block(data, error, NO);
                }
                @synchronized (self.downloadsInProgress) {
                    [self.downloadsInProgress removeObject:name];
                }
            }];
            [downloadPhotoTask resume];
        }
    }
    return nil;
}

+ (void) getDataInBackgroundWithBlock:(CachedFileBlock)block fromFile:(PFFile*)file
{
    [[CachedFile file] getDataInBackgroundWithBlock:block fromFile:file];
}

- (void) getDataInBackgroundWithBlock:(CachedFileBlock)block fromFile:(PFFile*)file
{
    if (!file) {
        if (block) {
            block(nil, nil, YES);
        }
    }
    
    NSData *data = [self objectForKey:file.name];
    if (data) {
        if (block) {
            block(data, nil, YES);
        }
    }
    else {
        [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (!error) {
                [self setObject:data forKey:file.name];
            }
            if (block) {
                block(data, error, NO);
            }
        }];
    }
}

+ (void) saveData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(FileBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock
{
    return [[CachedFile file] saveData:data named:name inBackgroundWithBlock:block progressBlock:progressBlock];
}

- (void) saveData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(FileBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock
{
    if (data) {
        PFFile *file = [PFFile fileWithName:name data:data];
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self setObject:data forKey:file.name];
            if (block) {
                block(file, succeeded, error);
            }
        } progressBlock:progressBlock];
    }
    else {
        if (block) {
            block(nil, YES, nil);
        }
    }
}

- (void) saveVideoData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(FileBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock
{
    if (data) {
        PFFile *file = [PFFile fileWithName:name data:data contentType:@"video/quicktime"];
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self setObject:data forKey:file.name];
            if (block) {
                block(file, succeeded, error);
            }
        } progressBlock:progressBlock];
    }
    else {
        if (block) {
            block(nil, YES, nil);
        }
    }
}


+ (void) saveVideoData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(FileBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock
{
    return [[CachedFile file] saveVideoData:data named:name inBackgroundWithBlock:block progressBlock:progressBlock];
}


@end
