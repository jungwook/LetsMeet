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

- (instancetype) init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype) file
{
    return [[CachedFile alloc] init];
}

+ (void) getDataInBackgroundWithBlock:(PFDataResultBlock)block fromFile:(PFFile*)file
{
    [[CachedFile file] getDataInBackgroundWithBlock:block fromFile:file];
}

- (void) getDataInBackgroundWithBlock:(PFDataResultBlock)block fromFile:(PFFile*)file
{
    if (!file) {
        NSLog(@"ERROR: CANNOT GET DATA FROM A NULL FILE");
        return;
    }
    
    NSData *data = [self objectForKey:file.name];
    if (data) {
        NSLog(@"CACHED DATA EXISTS");
        if (block) {
            NSLog(@"CALLING BLOCK WITH CACHED DATA");
            block(data, nil);
        }
    }
    else {
        NSLog(@"NO CACHED DATA - LOADING FROM NETWORK");
        [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            NSLog(@"LOADED DATA FROM NETWORK");
            if (!error) {
                NSLog(@"SETTING CACHED DATA:%@", file.name);
                [self setObject:data forKey:file.name];
            }
            if (block) {
                NSLog(@"CALLING BLOCK WITH NETWORK DATA");
                block(data, error);
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
    NSLog(@"SAVING FILE NETWORK DATA:%@", file.name);
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"SAVING TO CACHE:%@", file.name);
        [self setObject:data forKey:file.name];
        if (block) {
            NSLog(@"CALLING BLOCK WITH SAVED NETWORK DATA:%@", file.name);
            block(file, succeeded, error);
        }
    } progressBlock:progressBlock];
}

@end
