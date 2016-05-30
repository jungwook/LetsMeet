//
//  CachedFile.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "CachedFile.h"


@interface CachedFile()
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
        
    }
    return self;
}

+ (id)objectForKey:(id)key
{
    return [[CachedFile file] objectForKey:key];
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
//        NSLog(@"CACHED DATA EXISTS");
        if (block) {
//            NSLog(@"CALLING BLOCK WITH CACHED DATA");
            block(data, nil, YES);
        }
    }
    else {
//        NSLog(@"NO CACHED DATA - LOADING FROM NETWORK");
        [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
//            NSLog(@"LOADED DATA FROM NETWORK");
            if (!error) {
//                NSLog(@"SETTING CACHED DATA:%@", file.name);
                [self setObject:data forKey:file.name];
            }
            if (block) {
//                NSLog(@"CALLING BLOCK WITH NETWORK DATA");
                block(data, error, NO);
            }
        }];
    }
}

+ (void) saveData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(FileBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock
{
    [[CachedFile file] saveData:data named:name inBackgroundWithBlock:block progressBlock:progressBlock];
}

- (void) saveData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(FileBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock
{
    PFFile *file = [PFFile fileWithName:name data:data];
//    NSLog(@"SAVING FILE NETWORK DATA:%@", file.name);
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        NSLog(@"SAVING TO CACHE:%@", file.name);
        [self setObject:data forKey:file.name];
        if (block) {
//            NSLog(@"CALLING BLOCK WITH SAVED NETWORK DATA:%@", file.name);
            block(file, succeeded, error);
        }
    } progressBlock:progressBlock];
}

@end
