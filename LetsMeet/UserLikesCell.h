//
//  UserLikesCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserLikesCollection.h"

@interface UserLikesCell : UICollectionViewCell
@property (nonatomic, assign) UIColor *titleColor;
- (void) setUser:(User*)user;
@end
