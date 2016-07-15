//
//  UserMediaLikesCollection.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserMediaLikesCollection.h"
#import "MediaPicker.h"

#define kAddMoreUserMediaCell @"AddMoreUserMediaCell"
#define kUserMediaCell @"UserMediaCell"
#define kUserLikesCell @"UserLikesCell"
#define kUserProfileHeader @"UserProfileHeader"
#define kNearHeader @"NearHeader"

#define kNumCellsPerRow 3
#define kPadding 0


@interface UserMediaLikesCollection()
@property (nonatomic, strong) UICollectionViewFlowLayout *flow;
@property (weak, nonatomic) UIViewController *viewController;
@property (strong, readonly) NSArray *likes;
@property (strong, readonly) NSArray *liked;
@property (strong, readonly) NSArray *media;
@end

@implementation UserMediaLikesCollection

+ (instancetype)UserMediaLikesCollectionOnViewController:(UIViewController *)viewController
{
    return [[UserMediaLikesCollection alloc] initWithViewController:viewController];
}

- (instancetype) initWithViewController:(UIViewController *)viewController
{
    self.flow = [UICollectionViewFlowLayout new];
    self.flow.minimumLineSpacing = 4;
    self.flow.minimumInteritemSpacing = 4;
    self.flow.sectionInset = UIEdgeInsetsMake(3, 4, 3, 4);
    
    self = [super initWithFrame:viewController.view.bounds collectionViewLayout:self.flow];
    if (self) {
        self.viewController = viewController;
        [self initialize];
    }
    return self;
}

#pragma UserMediaCell delegate methods

- (NSArray*) collectionVisibleCells
{
    return self.visibleCells;
}

- (void)userMediaCell:(UserMediaCell *)cell editCommentOnMedia:(UserMedia *)media
{
    __LF
    if ([self.collectionDelegate respondsToSelector:@selector(collectionEditCommentOnMedia:)]) {
        [self.collectionDelegate collectionEditCommentOnMedia:media];
    }
}

-(void)userMediaCell:(UserMediaCell *)cell removeMedia:(UserMedia *)media
{
    __LF
    if ([self.collectionDelegate respondsToSelector:@selector(collectionRemoveMedia:)]) {
        [self.collectionDelegate collectionRemoveMedia:media];
    }
}

#pragma UserLikesCell delegate methods

- (void)userLikesCell:(UserLikesCell *)cell selectUser:(User *)user
{
    __LF
    if (self.userLikeHandler) {
        self.userLikeHandler(user);
    }
}

#pragma AddMoreMedia delegate methods

- (void)addMoreUserMedia
{
    __LF
    if ([self.collectionDelegate respondsToSelector:@selector(collectionAddMedia)]) {
        [self.collectionDelegate collectionAddMedia];
    }
}

#pragma UserMediaLikesCollection delegate methods

- (NSArray *)media
{
    NSArray *returnArray = nil;
    if ([self.collectionDelegate respondsToSelector:@selector(collectionMedia)]) {
        returnArray = [self.collectionDelegate collectionMedia];
    }
    return returnArray;
}

- (NSArray *)likes
{
    NSArray *returnArray = nil;
    if ([self.collectionDelegate respondsToSelector:@selector(collectionLikes)]) {
        returnArray = [self.collectionDelegate collectionLikes];
    }
    return returnArray;
}

- (NSArray *)liked
{
    NSArray *returnArray = nil;
    if ([self.collectionDelegate respondsToSelector:@selector(collectionLiked)]) {
        returnArray = [self.collectionDelegate collectionLiked];
    }
    return returnArray;
}

#pragma UserMediaLikesCollection Methods

- (void) initialize
{
    [self registerNib:[UINib nibWithNibName:kUserMediaCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kUserMediaCell];
    [self registerNib:[UINib nibWithNibName:kUserLikesCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kUserLikesCell];
    [self registerNib:[UINib nibWithNibName:kAddMoreUserMediaCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kAddMoreUserMediaCell];
//    [self registerNib:[UINib nibWithNibName:kUserProfileHeader bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kUserProfileHeader];
    [self registerNib:[UINib nibWithNibName:kNearHeader bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kNearHeader];

    
    self.commentColor = [UIColor darkGrayColor];
    self.commentFont = nil;
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.alwaysBounceVertical = YES;
    self.allowsSelection = YES;
}

- (void) initializeCollectionWithDelegate:(id<UserMediaLikesCollectionDelegate>)delegate
{
    __LF
    self.collectionDelegate = delegate;
    self.delegate = self;
    self.dataSource = self;
    [self reloadData];
}

- (void)collectionMediaAddedAtIndex:(NSInteger)index
{
    [self performBatchUpdates:^{
        [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:kSectionUserMedia]]];
    } completion:^(BOOL finished) {
        [self reloadSections:[NSIndexSet indexSetWithIndex:kSectionUserMedia]];
    }];
}

- (void)collectionMediaRemovedAtIndex:(NSInteger)index
{
    [self performBatchUpdates:^{
        [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:kSectionUserMedia]]];
    } completion:^(BOOL finished) {
        [self reloadSections:[NSIndexSet indexSetWithIndex:kSectionUserMedia]];
    }];
}


- (void)collectionCommentEditedAtIndex:(NSInteger)index
{
    [self performBatchUpdates:^{
        [self reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:kSectionUserMedia]]];
    } completion:nil];
}

- (void)collectionRefreshLikes
{
    [self performBatchUpdates:^{
        [self reloadSections:[NSIndexSet indexSetWithIndex:kSectionUserLikes]];
    } completion:nil];
}

- (void)collectionRefreshLiked
{
    [self performBatchUpdates:^{
        [self reloadSections:[NSIndexSet indexSetWithIndex:kSectionUserLiked]];
    } completion:nil];
}

//- (void)collectionAddMedia:(UserMedia *)media
//{
//    __LF
//    [media fetched:^{
//        [self performBatchUpdates:^{
//            NSUInteger count = self.media.count;
//            [self.media addObject:media];
//            [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:kSectionUserMedia]]];
//        } completion:^(BOOL finished) {
//            [self reloadSections:[NSIndexSet indexSetWithIndex:kSectionUserMedia]];
//        }];
//    }];
//}

//- (void)collectionRemoveMedia:(UserMedia*)media
//{
//    __LF
//    [media fetched:^{
//        [self performBatchUpdates:^{
//            NSUInteger index = [self.media indexOfObject:media];
//            [self.media removeObject:media];
//            [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:kSectionUserMedia]]];
//        } completion:^(BOOL finished) {
//            [self reloadSections:[NSIndexSet indexSetWithIndex:kSectionUserMedia]];
//        }];
//    }];
//}

//- (void)collectionEditCommentOnMedia:(UserMedia *)media
//{
//    __LF
//    [media fetched:^{
//        [self performBatchUpdates:^{
//            NSUInteger index = [self.media indexOfObject:media];
//            [self reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:kSectionUserMedia]]];
//        } completion:^(BOOL finished) {
//        }];
//    }];
//}
//
//- (void)collectionAddLikes:(User *)user
//{
//    [user fetched:^{
//        [self performBatchUpdates:^{
//            NSUInteger count = self.likes.count;
//            [self.likes addObject:user];
//            [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:kSectionUserLikes]]];
//        } completion:^(BOOL finished) {
//            [self reloadSections:[NSIndexSet indexSetWithIndex:kSectionUserLikes]];
//        }];
//    }];
//}
//
//- (void)collectionAddLiked:(User *)user
//{
//    [user fetched:^{
//        [self performBatchUpdates:^{
//            NSUInteger count = self.liked.count;
//            [self.liked addObject:user];
//            [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:kSectionUserLiked]]];
//        } completion:^(BOOL finished) {
//            [self reloadSections:[NSIndexSet indexSetWithIndex:kSectionUserLiked]];
//        }];
//    }];
//}
//
//- (void)collectionRemoveLiked:(User *)user
//{
//    NSLog(@"DELETEING FROM LIKED:%@", self.liked);
//    [user fetched:^{
//        [self performBatchUpdates:^{
//            NSUInteger index = [self.liked indexOfObject:user];
//            [self.liked removeObject:user];
//            [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:kSectionUserLiked]]];
//        } completion:^(BOOL finished) {
//            [self reloadSections:[NSIndexSet indexSetWithIndex:kSectionUserLiked]];
//        }];
//    }];
//}

- (void)setCommentColor:(UIColor *)commentColor
{
    _commentColor = commentColor;
    [self reloadData];
}

- (void)setCommentFont:(UIFont *)commentFont
{
    _commentFont = commentFont;
    [self reloadData];
}

- (void)refreshProfile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch ((UserMediaLikesCollectionSections)section) {
        case kSectionUserMedia:
            return self.media.count + self.editable;
        case kSectionUserLikes:
            return self.likes.count;
        case kSectionUserLiked:
            return self.liked.count;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)collectionViewLayout;
    UserMediaLikesCollectionSections section = indexPath.section;
    switch (section) {
        case kSectionUserMedia: {
            layout.minimumLineSpacing = 2;
            layout.minimumInteritemSpacing = 2;
            layout.sectionInset = UIEdgeInsetsMake(0, 40, 30, 10);
            CGFloat w = widthForNumberOfCells(collectionView, layout, 3);
            return CGSizeMake(w, w+25);
        }
        case kSectionUserLikes:{
            layout.minimumLineSpacing = 4;
            layout.minimumInteritemSpacing = 4;
            layout.sectionInset = UIEdgeInsetsMake(0, 40, 30, 10);
            CGFloat w = widthForNumberOfCells(collectionView, layout, 6);
            return CGSizeMake(w, w);
        }
        case kSectionUserLiked:{
            layout.minimumLineSpacing = 4;
            layout.minimumInteritemSpacing = 4;
            layout.sectionInset = UIEdgeInsetsMake(0, 40, 30, 10);
            CGFloat w = widthForNumberOfCells(collectionView, layout, 6);
            return CGSizeMake(w, w);
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    UserMediaLikesCollectionSections section = indexPath.section;
    switch (section) {
        case kSectionUserMedia:
        {
            if (row == self.media.count) {
                AddMoreUserMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAddMoreUserMediaCell forIndexPath:indexPath];
                cell.backgroundColor = [UIColor darkGrayColor];
                cell.tag = row;
                cell.delegate = self;
                return cell;
            }
            else {
                UserMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserMediaCell forIndexPath:indexPath];
                [cell setMedia:[self.media objectAtIndex:row]];
                [cell setDelegate:self];
                return cell;
            }
        }
        case kSectionUserLikes:
        {
            UserLikesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserLikesCell forIndexPath:indexPath];
            User *user = [self.likes objectAtIndex:row];
            [cell setUser:user];
            [cell setDelegate:self];
            return cell;
        }
        case kSectionUserLiked:
        {
            UserLikesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserLikesCell forIndexPath:indexPath];
            User *user = [self.liked objectAtIndex:row];
            [cell setUser:user];
            [cell setDelegate:self];
            return cell;
        }
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch ((UserMediaLikesCollectionSections) section) {
        case kSectionUserMedia:
            return CGSizeMake(1, 50);
            break;
        case kSectionUserLikes:
            return CGSizeMake(1, 30);
            break;
        case kSectionUserLiked:
            return CGSizeMake(1, 30);
            break;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UserMediaLikesCollectionSections section = indexPath.section;
    if (kind == UICollectionElementKindSectionHeader) {
//        UserProfileHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kUserProfileHeader forIndexPath:indexPath];
        NearHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kNearHeader forIndexPath:indexPath];
        header.title.textColor = self.commentColor;
        header.title.font = self.commentFont ? self.commentFont : header.title.font;
        switch (section) {
            case kSectionUserMedia:
                header.title.text = [NSString stringWithFormat:@"USER PHOTOS (%ld)", self.media.count];
                break;
            case kSectionUserLikes:
                header.title.text = [NSString stringWithFormat:@"LIKES (%ld)", self.likes.count];
                break;
            case kSectionUserLiked:
                header.title.text = [NSString stringWithFormat:@"LIKED BY (%ld)", self.liked.count];
                break;
        }
        return header;
    }
    else {
        return nil;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    UserMediaLikesCollectionSections section = indexPath.section;
    switch (section) {
        case kSectionUserMedia:
            if (indexPath.row == self.media.count) {
                [self addMoreUserMedia];
            }
            break;
        case kSectionUserLikes: {
            if (self.userLikeHandler) {
                self.userLikeHandler([self.likes objectAtIndex:indexPath.row]);
            }
        }
            break;
        case kSectionUserLiked: {
            if (self.userLikeHandler) {
                self.userLikeHandler([self.liked objectAtIndex:indexPath.row]);
            }
        }
            break;
    }
}

@end
