//
//  Signup.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Signup.h"
#import "NSMutableDictionary+Bullet.h"
@interface Signup()
@property (nonatomic, weak) FileSystem* system;
@property (nonatomic, weak) UIViewController* rootViewController;
@end

@implementation Signup

+ (void)startWithSystem:(FileSystem *)system
{
    Signup *su = [Signup new];
    su.system = system;
    su.rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [su loginOrSignupWithMessage:@"사용할 사용자명을 입력하세요!"];
}

- (void)loginOrSignupWithMessage:(NSString*)message
{
    self.alert = [UIAlertController alertControllerWithTitle:@"사용자" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionStart = [UIAlertAction actionWithTitle:@"시작" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __LF
        NSString *username = [self.alert.textFields firstObject].text;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            PFUser* loggedIn = [PFUser logInWithUsername:username password:username];
            if (!loggedIn) {
                NSLog(@"Not Logged in so attempting to create a user");
                User *me = [User object];
                me.username = username; me.password = username;
                [me signUp];
                [PFUser logInWithUsername:username password:username];
                [self restartWithMain];
            }
            else {
                User *me = [User me];
                [me fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    NSLog(@"Logged in as user with username:%@", username);
                    [self restartWithMain];
                }];
            }
        });
    }];
    
    [self.alert addTextFieldWithConfigurationHandler:nil];
    [self.alert addAction:actionStart];
    [self.rootViewController presentViewController:self.alert animated:YES completion:nil];
}

- (void) restartWithMain
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.system initializeSystem];
        self.rootViewController = [self.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"Start"];
        
        NSLog(@"VC:%@", self.rootViewController);
        [AppDelegate toggleMenu];
    });
}

@end
