//
//  AppDelegate.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 12..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainController *mainMenu;

+ (AppDelegate *)globalDelegate;
+ (void)toggleMenu;
+ (void)toggleMenuWithScreenID:(NSString*) screen;
+ (NSDictionary*) screens;

@end

