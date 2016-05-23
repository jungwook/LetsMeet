//
//  MainController.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MainController.h"
#import "FloatingDrawerSpringAnimator.h"
#import "AppEngine.h"
#import "CachedFile.h"

@interface MainController ()
@end

@implementation MainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeMainViewController];
}

- (BOOL)initializeViewControllers {
    
    
    self.screens = @{ @"Board" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"Board"],
                                    @"title"   : @"보드",
                                    @"menu"    : @"보드",
                                    @"icon"    : @"488-github",
                                    @"badge"   : @(NO)
                                    },
                      @"Search2" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"SearchV2"],
                                     @"title"   : @"SEARCH",
                                     @"menu"    : @"SEARCH",
                                     @"icon"    : @"488-github",
                                     @"badge"   : @(NO)
                                     },
                      @"Search" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"Search"],
                                     @"title"   : @"주변",
                                     @"menu"    : @"주변",
                                     @"icon"    : @"488-github",
                                     @"badge"   : @(NO)
                                     },
                      @"InBox" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"InBox"],
                                    @"title"   : @"쪽지함",
                                    @"menu"    : @"쪽지",
                                    @"icon"    : @"488-github",
                                    @"badge"   : @(YES)
                                    },
                      @"Account" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"Account"],
                                      @"title"   : @"사용자",
                                      @"menu"    : @"사용자 설정",
                                      @"icon"    : @"488-github",
                                      @"badge"   : @(NO)
                                      }};
    
    static BOOL init = true;
    [self.screens enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (!obj) {
            init = false;
        }
    }];
    
    return init;
}

-(void)viewDidAppear:(BOOL)animated
{
    static bool firstTime = YES;
    
    NSString *username = [AppEngine uniqueDeviceID];
    PFUser *user = [PFUser currentUser];
    
    if (!user || ![user.username isEqualToString:username]) {
        user = [PFUser user];
        user.username = username;
        user.password = username;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [PFUser logInWithUsernameInBackground:user.username password:user.password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                    [[AppEngine engine] initLocationServices];
                    [self subscribeToChannelCurrentUser];
                    UITableViewController *signup = [[self storyboard] instantiateViewControllerWithIdentifier:@"SignUp"];
                    [self presentViewController:signup animated:YES completion:^{
                        NSLog(@"PRESENTING USER:%@", [PFUser currentUser]);
                    }];
                }];
            }
            else {
                NSLog(@"CANNOT SIGNUP NEW USER");
            }
        }];
    }
    else {
        if (firstTime) {
            firstTime = NO;
            // Load all personall pictures into Cache
            [CachedFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            } fromFile:user[AppProfilePhotoField]];
        }
    }
}

- (void) subscribeToChannelCurrentUser
{
    PFUser *me = [PFUser currentUser];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (!currentInstallation[@"user"]) {
        currentInstallation[@"user"] = me;
        [currentInstallation saveInBackground];
        NSLog(@"CURRENT INSTALLATION: saving user to Installation");
    }
    else {
        NSLog(@"CURRENT INSTALLATION: Installation already has user. No need to set");
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"VANISHED");
}

- (void) selectScreenWithID:(NSString *)screen
{
    UINavigationController *nav = self.screens[screen][@"screen"];
    NSString* title = self.screens[screen][@"title"];
    
    NSLog(@"TITLE:%@", title);
    if (nav) {
        self.centerViewController = nav;
        [self.centerViewController setTitle:title];
        [AppDelegate toggleMenu];
    }
}

- (void) initializeMainViewController {
    if ([self initializeViewControllers]) {
        NSLog(@"All systems go...");
        
        self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftMenu"];
//        self.centerViewController = self.screens[@"Board"][@"screen"];
        self.centerViewController = self.screens[@"Search2"][@"screen"];
        self.animator = [[FloatingDrawerSpringAnimator alloc] init];
        self.backgroundImage = [UIImage imageNamed:@"sky"];

        [AppDelegate globalDelegate].mainMenu = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
