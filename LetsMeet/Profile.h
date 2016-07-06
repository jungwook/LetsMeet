//
//  Profile.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 6..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Profile : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
- (void) setUser:(User*)user;
@end
