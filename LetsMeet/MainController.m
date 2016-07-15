//
//  MainController.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MainController.h"
#import "FloatingDrawerSpringAnimator.h"
#import "CachedFile.h"
#import "ListPicker.h"
#import "SignUp.h"


#define MAIN_SCREEN_ID @"Profile"
#undef MAIN_SCREEN_ID
#define MAIN_SCREEN_ID @"NearMe"
#undef MAIN_SCREEN_ID
#define MAIN_SCREEN_ID @"Profile"
#undef MAIN_SCREEN_ID
#define MAIN_SCREEN_ID @"Near"
#undef MAIN_SCREEN_ID
#define MAIN_SCREEN_ID @"Say"

@interface MainController ()
@end

@implementation MainController

- (void)viewDidLoad {
    __LF
    [super viewDidLoad];
    self.backgroundImage = [UIImage imageNamed:@"bg"];

}

- (void)checkLoginStatusAndProceed
{
//    [PFUser logOut];
    
    User *user = [User me];
    if (user) {
        [user fetched:^{
            [user saveInBackground];
            [[FileSystem new] initializeSystem];
            [self initializeMainViewControllerToScreenId:MAIN_SCREEN_ID];
        }];
    }
    else {
        [self performSegueWithIdentifier:@"SignUp" sender:^(SignUp* signup, id nickname, id intro, id age, id sex){
            User *user = [User object];
            id usernameAndPassword = [FileSystem objectId];
            user.username = usernameAndPassword;
            user.password = usernameAndPassword;
            user.nickname = nickname;
            user.age = age;
            user.intro = intro;
            user.isSimulated = NO;
            [user setSexFromString:sex];
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    [PFUser logInWithUsernameInBackground:user.username password:user.password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                        if (!error) {
                            [signup dismissViewControllerAnimated:YES completion:nil];
                            [self subscribeToChannelCurrentUser];
                            [[FileSystem new] initializeSystem];
                            [self initializeMainViewControllerToScreenId:MAIN_SCREEN_ID];
                        }
                        else {
                            [signup setInfo:[NSString stringWithFormat:@"Some error occured:%@", error.localizedDescription]];
                        }
                    }];
                }
                else {
                    [signup setInfo:[NSString stringWithFormat:@"Some error occured:%@", error.localizedDescription]];
                }
            }];
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    __LF
    SignUp *vc = segue.destinationViewController;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.completionBlock = sender;
}

- (void) initializeMainViewControllerToScreenId:(id)screenId
{
    if ([self initializeViewControllers]) {
        NSLog(@"All systems go...");
        
        UIViewController *center = self.screens[screenId][@"screen"];
        self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftMenu"];
        self.centerViewController = center ? center : [self.storyboard instantiateViewControllerWithIdentifier:screenId];
        self.animator = [[FloatingDrawerSpringAnimator alloc] init];
        
        [AppDelegate globalDelegate].mainMenu = self;
    }
}

- (BOOL)initializeViewControllers {
    
    
    self.screens = @{
                     @"Profile" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"Profile"],
                                    @"title"   : @"프로필",
                                    @"menu"    : @"프로필",
                                    @"icon"    : @"488-github",
                                    @"badge"   : @(NO)
                                    },
                      @"Search" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"Search"],
                                     @"title"   : @"주변",
                                     @"menu"    : @"주변",
                                     @"icon"    : @"488-github",
                                     @"badge"   : @(NO)
                                     },
                     @"Near" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"Near"],
                                    @"title"   : @"Near",
                                    @"menu"    : @"Near",
                                    @"icon"    : @"488-github",
                                    @"badge"   : @(NO)
                                    },
                      @"NearMe" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"NearMe"],
                                     @"title"   : @"Near...",
                                     @"menu"    : @"Near...",
                                     @"icon"    : @"488-github",
                                     @"badge"   : @(NO)
                                     },
                      @"InBox" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"InBox"],
                                    @"title"   : @"쪽지함",
                                    @"menu"    : @"쪽지",
                                    @"icon"    : @"488-github",
                                    @"badge"   : @(YES)
                                    },
                      @"Profile2" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileNav"],
                                    @"title"   : @"사용자",
                                    @"menu"    : @"사용자 2",
                                    @"icon"    : @"488-github",
                                    @"badge"   : @(YES)
                                    },
                      @"Map" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"Map"],
                                      @"title"   : @"WORLD",
                                      @"menu"    : @"WORLD",
                                      @"icon"    : @"488-github",
                                      @"badge"   : @(YES)
                                      },
//                      @"Account" : @{ @"screen"  : [self.storyboard instantiateViewControllerWithIdentifier:@"Account"],
//                                      @"title"   : @"사용자",
//                                      @"menu"    : @"사용자 설정",
//                                      @"icon"    : @"488-github",
//                                      @"badge"   : @(NO)
//                                      }
                      };
    
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
    [self checkLoginStatusAndProceed];
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
    __LF
    UINavigationController *nav = self.screens[screen][@"screen"];
    NSString* title = self.screens[screen][@"title"];
    if (nav) {
        self.centerViewController = nav;
        [self.centerViewController setTitle:title];
        [AppDelegate toggleMenu];
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
