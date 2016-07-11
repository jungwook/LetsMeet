//
//  Profile.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 6..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Profile : UIViewController
- (void) setUser:(User*)user;
- (void) showProfileForUser:(User*)user;
- (void) dismissModalPresentation;
@end
