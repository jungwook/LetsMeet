//
//  UserMediaLikesCollection.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageSelectionView.h"

typedef enum : NSInteger {
    kSectionUserMedia = 0,
    kSectionUserLikes,
    kSectionUserLiked,
} UserMediaLikesCollectionSections;

typedef void(^UserLikeHandler)(User* user);

@interface UserMediaLikesCollection : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PageSelectionViewProtocol>
@property (nonatomic, strong) User* user;
@property (nonatomic, strong) UIColor *commentColor;
@property (nonatomic, strong) UIFont *commentFont;
@property (nonatomic, copy) UserLikeHandler userLikeHandler;

/**
 The only initialization method for UserMediaLikesCollection
 **/
+ (instancetype) UserMediaLikesCollectionOnViewController:(UIViewController*)viewController;


- (void) userSelected:(User*)user;
- (void) addMedia;
- (void) removeMedia:(UserMedia*)media row:(NSInteger)row;
- (void) editMediaComment:(UserMedia*)media row:(NSInteger)row;
- (void) setLikes:(NSArray*)likes;
- (void) setLiked:(NSArray*)liked;

@end
