//
//  NearByCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSMutableDictionary+Bullet.h"

@interface NearByCell : UICollectionViewCell
@property (nonatomic, strong) User* user;
- (void)setUser:(User*)user collectionView:(UICollectionView*)collectionView;
@end
