//
//  UserProfileCollection.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kCollectionSectionMedia = 0,
    kCollectionSectionMap,
    kCollectionSectionLikes,
    kCollectionSectionLiked
} CollectionSection;

@interface UserProfileCollection : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) User *user;
@end
