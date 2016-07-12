//
//  UserMediaLikesCollection.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserMediaLikesCollection.h"
#import "MediaPicker.h"

#import "AddMoreUserMediaCell.h"
#import "UserMediaCell.h"
#import "UserLikesCell.h"
#import "UserProfileHeader.h"

#define kAddMoreUserMediaCell @"AddMoreUserMediaCell"
#define kUserMediaCell @"UserMediaCell"
#define kUserLikesCell @"UserLikesCell"
#define kUserProfileHeader @"UserProfileHeader"

#define kNumCellsPerRow 3
#define kPadding 0


@interface UserMediaLikesCollection()
@property (nonatomic, strong) UICollectionViewFlowLayout *flow;
@property (weak, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) NSArray *likes;
@property (strong, nonatomic) NSArray *liked;
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

- (void)setLiked:(NSArray *)liked
{
    [self performBatchUpdates:^{
        [self deleteItemsAtIndexPaths:[self indexPathsForRows:self.liked.count section:kSectionUserLiked]];
        _liked = liked;
        [self insertItemsAtIndexPaths:[self indexPathsForRows:liked.count section:kSectionUserLiked]];
    } completion:^(BOOL finished) {
        [self reloadData];
    }];
}

- (void)setLikes:(NSArray *)likes
{
    [self performBatchUpdates:^{
        [self deleteItemsAtIndexPaths:[self indexPathsForRows:self.likes.count section:kSectionUserLikes]];
        _likes = likes;
        [self insertItemsAtIndexPaths:[self indexPathsForRows:likes.count section:kSectionUserLikes]];
    } completion:^(BOOL finished) {
        [self reloadData];
    }];
}

- (NSArray*) indexPathsForRows:(NSInteger)count section:(NSInteger)section
{
    NSMutableArray* ip = [NSMutableArray array];
    for (int i=0; i<count; i++) {
        [ip addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    return ip;
}

- (void) initialize
{
    [self registerNib:[UINib nibWithNibName:kUserMediaCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kUserMediaCell];
    [self registerNib:[UINib nibWithNibName:kUserLikesCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kUserLikesCell];
    [self registerNib:[UINib nibWithNibName:kAddMoreUserMediaCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kAddMoreUserMediaCell];
    [self registerNib:[UINib nibWithNibName:kUserProfileHeader bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kUserProfileHeader];

    
    self.commentColor = [UIColor darkGrayColor];
    self.commentFont = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:11];
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.alwaysBounceVertical = YES;
    _user = [User me];
}

- (void) setUser:(User *)user
{
    __LF
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        _user = user;
        [self.user mediaReady:^{
            self.delegate = self;
            self.dataSource = self;
            [self reloadData];
        }];
    }];
}

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
            return self.user.media.count + self.user.isMe;
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
            if (row == self.user.media.count) {
                AddMoreUserMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAddMoreUserMediaCell forIndexPath:indexPath];
                cell.backgroundColor = [UIColor darkGrayColor];
                cell.tag = row;
                cell.parent = self;
                return cell;
            }
            else {
                UserMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserMediaCell forIndexPath:indexPath];
                [cell setUserMedia:[self.user.media objectAtIndex:row] parent:self row:indexPath.row];
                return cell;
            }
        }
        case kSectionUserLikes:
        {
            UserLikesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserLikesCell forIndexPath:indexPath];
            User *user = [self.likes objectAtIndex:row];
            [cell setUser:user parent:self];
            return cell;
        }
        case kSectionUserLiked:
        {
            UserLikesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserLikesCell forIndexPath:indexPath];
            User *user = [self.liked objectAtIndex:row];
            [cell setUser:user parent:self];
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
        UserProfileHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kUserProfileHeader forIndexPath:indexPath];
        header.title.textColor = [UIColor darkGrayColor];
        switch (section) {
            case kSectionUserMedia:
                header.title.text = [NSString stringWithFormat:@"USER PHOTOS (%ld)", self.user.media.count];
                break;
            case kSectionUserLikes:
                header.title.text = [NSString stringWithFormat:@"FOLLOWING (%ld)", self.likes.count];
                break;
            case kSectionUserLiked:
                header.title.text = [NSString stringWithFormat:@"FOLLOWED BY (%ld)", self.liked.count];
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
    UserMediaLikesCollectionSections section = indexPath.section;
    switch (section) {
        case kSectionUserMedia:
            if (indexPath.row == self.user.media.count) {
                [self addMedia];
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

- (void)addMedia
{
 __LF
    MediaPickerMediaBlock handler = ^(ProfileMediaTypes mediaType,
                                      NSData *thumbnailData,
                                      NSString *thumbnailFile,
                                      NSString *mediaFile,
                                      CGSize mediaSize,
                                      BOOL isRealMedia)
    {
        if (self.user.isMe) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"JUST 1 SEC" message:@"enter comment for your media" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:nil];
            [alert addAction:[UIAlertAction actionWithTitle:@"SAVE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UserMedia *media = [UserMedia object];
                media.mediaSize = mediaSize;
                media.mediaFile = mediaFile;
                media.thumbailFile = thumbnailFile;
                media.mediaType = mediaType;
                media.userId = self.user.objectId;
                media.isRealMedia = isRealMedia;
                media.comment = [alert.textFields firstObject].text;
                
                [self.user addUniqueObject:media forKey:@"media"];
                [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (!error) {
                        [self performBatchUpdates:^{
                            [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.user.media.count-self.user.isMe inSection:0]]];
                        } completion:nil];
                    }
                    else {
                        NSLog(@"ERROR:%@", error.localizedDescription);
                    }
                }];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"Add media cancelled");
            }]];
            alert.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self.viewController presentViewController:alert animated:YES completion:nil];
        }
        else {
            NSLog(@"ERROR: Cannot add on other user media.");
        }
    };
    [MediaPicker addMediaOnViewController:self.viewController withMediaHandler:handler];
}

- (void) userSelected:(User *)user
{
    if (self.userLikeHandler) {
        self.userLikeHandler(user);
    }
}

- (void) removeMedia:(UserMedia*)media row:(NSInteger)row
{
    if (!self.user.isMe) {
        NSLog(@"ERROR: Cannot remove other's media");
        return;
    }
    
    [media deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error && succeeded) {
            [self performBatchUpdates:^{
                [self.user removeObjectsInArray:@[media] forKey:@"media"];
                [self.user saveInBackground];
                [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
            } completion:nil];
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    }];
}

- (void)editMediaComment:(UserMedia *)media row:(NSInteger)row
{
    __LF
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"JUST 1 SEC" message:@"enter comment for your media" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = media.comment;
        textField.placeholder = @"enter a comment";
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"SAVE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *newcomment = [alert.textFields firstObject].text;
        media.comment = newcomment;
        [media saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"edit comment cancelled");
    }]];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}


@end
