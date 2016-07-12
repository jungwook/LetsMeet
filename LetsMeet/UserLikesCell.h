//
//  UserLikesCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserLikesCell;

@protocol UserLikesCellDelegate <NSObject>
@required
- (void) userLikesCell:(UserLikesCell*)cell selectUser:(User*)user;
- (NSArray*) collectionVisibleCells;
@end

@interface UserLikesCell : UICollectionViewCell
@property (nonatomic, strong) User* user;
@property (nonatomic, weak) id<UserLikesCellDelegate> delegate;
@end
