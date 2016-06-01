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
    [[CachedFile file] saveData:data named:name inBackgroundWithBlock:block progressBlock:progressBlock];
}

- (void) saveData:(NSData*)data named:(NSString*)name inBackgroundWithBlock:(FileBooleanResultBlock)block progressBlock:(PFProgressBlock)progressBlock
{
    PFFile *file = [PFFile fileWithName:name data:data];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self setObject:data forKey:file.name];
        if (block) {
            block(file, succeeded, error);
        }
    } progressBlock:progressBlock];
}

@end
