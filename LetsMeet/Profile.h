//
//  Profile.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 6..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserMediaLikesCollection.h"

@interface Profile : UIViewController <UserMediaLikesCollectionDelegate>
@property (weak, nonatomic) User *user;

- (void) setAndInitializeWithUser:(User*)user;
- (void) showProfileForUser:(User*)user;
- (void) dismissModalPresentation;
@end
