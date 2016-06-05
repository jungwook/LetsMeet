//
//  RefreshControl.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSMutableDictionary+Bullet.h"

@interface RefreshControl : UIRefreshControl

+ (instancetype)initWithCompletionBlock:(RefreshControlBlock) completionBlock;

@end
