//
//  TextFieldAlert.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^StringReturnBlock)(NSString* string);

@interface TextFieldAlert : UIAlertController
+ (void) alertWithTitle:(NSString *)title message:(NSString *)message onViewController:(UIViewController*)viewController stringEnteredBlock:(StringReturnBlock)block;

@end
