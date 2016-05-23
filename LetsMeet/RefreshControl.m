//
//  RefreshControl.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "RefreshControl.h"

@interface RefreshControl()
@property (nonatomic, strong) RefreshControlBlock completionBlock;
@end

@implementation RefreshControl


+ (instancetype)initWithCompletionBlock:(RefreshControlBlock)completionBlock
{
    return [[RefreshControl alloc] initWithCompletionBlock:completionBlock];
}

- (instancetype)initWithCompletionBlock:(RefreshControlBlock)completionBlock
{
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
        [self addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)refreshPage
{
    if (self.completionBlock) {
        self.completionBlock(self);
    }
}
@end
