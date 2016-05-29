//
//  SquareCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 29..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SquareCell : UICollectionViewCell
- (void)setUser:(PFUser *)user andMessages:(NSArray *)messages collectionView:(UICollectionView*)collectionView;
@end
