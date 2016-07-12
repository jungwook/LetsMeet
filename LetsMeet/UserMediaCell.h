//
//  UserMediaCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserMediaCell;

@protocol UserMediaCellDelegate <NSObject>
@required
- (void) userMediaCell:(UserMediaCell*)cell removeMedia:(UserMedia*)media;
- (void) userMediaCell:(UserMediaCell*)cell editCommentOnMedia:(UserMedia*)media;
- (NSArray*) collectionVisibleCells;
@end

@interface UserMediaCell : UICollectionViewCell
@property (strong, nonatomic) UserMedia* media;
@property (nonatomic, weak) id <UserMediaCellDelegate> delegate;
@end
