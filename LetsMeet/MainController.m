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
                                    },
                      @"Search" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"Search"],
                                     @"title"   : @"주변",
                                     @"menu"    : @"주변",
                                     @"icon"    : @"488-github",
                                     },
                      @"InBox" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"InBox"],
                                    @"title"   : @"쪽지함",
                                    @"menu"    : @"쪽지",
                                    @"icon"    : @"488-github",
                                    },
                      @"Account" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"Account"],
                                      @"title"   : @"사용자",
                                      @"menu"    : @"사용자 설정",
                                      @"icon"    : @"488-github",
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
    UITableViewController *signup = [[self storyboard] instantiateViewControllerWithIdentifier:@"SignUp"];

    NSString *username = [AppEngine uniqueDeviceID];
    
    PFUser *user = [PFUser currentUser];
    NSLog(@"USER U:%@", user);
    
    if (![user.username isEqualToString:username]) {
        user = [PFUser user];
        user.username = username;
        user.password = username;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [PFUser logInWithUsernameInBackground:user.username password:user.password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                    [[AppEngine engine] initLocationServices];
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
        [[AppEngine engine] initLocationServices];
    }
    [self subscribeToChannelCurrentUser];
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
    if (nav) {
        self.centerViewController = nav;
        [AppDelegate toggleMenu];
    }
}

- (void) initializeMainViewController {
    if ([self initializeViewControllers]) {
        NSLog(@"All systems go...");
        
        self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftMenu"];
        self.centerViewController = self.screens[@"Board"][@"screen"];
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
