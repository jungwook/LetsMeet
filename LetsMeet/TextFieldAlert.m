//
//  TextFieldAlert.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "TextFieldAlert.h"

@interface TextFieldAlert ()
@property (nonatomic, strong) StringReturnBlock block;
@end

@implementation TextFieldAlert

+(void)alertWithTitle:(NSString *)title message:(NSString *)message onViewController:(UIViewController *)viewController stringEnteredBlock:(StringReturnBlock)block
{
    TextFieldAlert *me = [TextFieldAlert alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    me.block = block;
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *string = [me.textFields firstObject].text;
        if (me.block) {
            me.block(string);
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [me addTextFieldWithConfigurationHandler:nil];
    [me addAction:action];
    [me addAction:cancel];
    [viewController presentViewController:me animated:YES completion:nil];
}

@end
