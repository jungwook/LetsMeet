//
//  UserLikesCollection.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageSelectionView.h"

typedef void(^UserLikesCollectionBlock)(User* user);

@interface UserLikesCollection : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PageSelectionViewProtocol>
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) UIColor *titleColor;

+ (instancetype) userLikesCollectionWithHandler:(UserLikesCollectionBlock)handler;
@end
