//
//  UserMediaLikesCollection.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageSelectionView.h"
#import "AddMoreUserMediaCell.h"
#import "UserMediaCell.h"
#import "UserLikesCell.h"
#import "UserProfileHeader.h"
#import "NearHeader.h"

typedef enum : NSInteger {
    kSectionUserMedia = 0,
    kSectionUserLikes,
    kSectionUserLiked,
} UserMediaLikesCollectionSections;

typedef void(^UserLikeHandler)(User* user);


@class UserMediaLikesCollection;

@protocol UserMediaLikesCollectionDelegate <NSObject>
@required
- (void) collectionAddMedia;
- (void) collectionRemoveMedia:(UserMedia*)media;
- (void) collectionEditCommentOnMedia:(UserMedia*)media;
- (NSArray*) collectionMedia;
- (NSArray*) collectionLikes;
- (NSArray*) collectionLiked;
@end

@interface UserMediaLikesCollection : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PageSelectionViewProtocol, UserMediaCellDelegate, UserLikesCellDelegate, AddMoreUserMediaCellDelegate>

//@property (nonatomic, strong) User* user;
@property (nonatomic, weak) id <UserMediaLikesCollectionDelegate> collectionDelegate;
@property (nonatomic, strong) UIColor *commentColor;
@property (nonatomic, strong) UIFont *commentFont;
@property (nonatomic, copy) UserLikeHandler userLikeHandler;
@property (nonatomic) BOOL editable;

/**
 The only initialization method for UserMediaLikesCollection
 **/

+ (instancetype) UserMediaLikesCollectionOnViewController:(UIViewController*)viewController;
- (void) initializeCollectionWithDelegate:(id <UserMediaLikesCollectionDelegate>)delegate;
- (void) collectionMediaAddedAtIndex:(NSInteger)index;
- (void) collectionMediaRemovedAtIndex:(NSInteger)index;
- (void) collectionCommentEditedAtIndex:(NSInteger)index;
- (void) collectionRefreshLikes;
- (void) collectionRefreshLiked;

//- (void) collectionAddMedia:(UserMedia*)media;
//- (void) collectionRemoveMedia:(UserMedia*)media;
//- (void) collectionEditCommentOnMedia:(UserMedia*)media;
//- (void) collectionAddLikes:(User*)user;
//- (void) collectionAddLiked:(User*)user;
//- (void) collectionRemoveLiked:(User*)user;
@end
