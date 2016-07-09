//
//  UserMediaCollection.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserMediaCollection : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) User* user;
- (void) addMedia;
- (void) removeMedia:(UserMedia*)media row:(NSInteger)row;
+ (instancetype) userMediaCollectionOnViewController:(UIViewController*)viewController;
@end
