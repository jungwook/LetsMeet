//
//  SquareCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 29..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SquareCell : UICollectionViewCell
- (void)setUser:(PFUser *)user location:(PFGeoPoint*)location collectionView:(UICollectionView*)collectionView
;
- (void)setProfilePhoto:(UIImage*)photo;
- (void)setBroadcastMessage:(NSString*)message duration:(NSNumber*)duration;
- (void)openBroadcastMessage;
- (void)closeBroadcastMessage;
@property (weak, nonatomic) PFUser* user;
@end
