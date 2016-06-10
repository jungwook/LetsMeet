//
//  Signup.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileSystem.h"

@interface Signup : NSObject
@property (nonatomic, strong) UIAlertController *alert;
+ (void) startWithSystem:(FileSystem*)system;
@end
