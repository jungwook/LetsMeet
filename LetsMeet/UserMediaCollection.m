//
//  UserMediaCollection.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserMediaCollection.h"
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


@interface UserMediaCollection()
@property (nonatomic, strong) UICollectionViewFlowLayout *flow;
@property (weak, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) NSArray *likes;
@property (strong, nonatomic) NSArray *liked;
@end

@implementation UserMediaCollection

+ (instancetype)userMediaCollectionOnViewController:(UIViewController *)viewController
{
    return [[UserMediaCollection alloc] initWithViewController:viewController];
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

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
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

- (void) setUser:(User *)user
{
    __LF
    _user = user;
    [self loadAllLikesUsers];
    [self loadAllLikedUsers];
    
    [self.user mediaReady:^{
        self.delegate = self;
        self.dataSource = self;
        [self reloadData];
    }];
}

- (void)refreshProfile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

- (void)loadAllLikesUsers
{
    PFQuery *query = [User query];
    [query whereKey:@"objectId" containedIn:self.user.likes];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.likes = objects;
        [self refreshProfile];
    }];
}

- (void) loadAllLikedUsers
{
    PFQuery *query = [User query];
    [query whereKey:@"likes" containsString:self.user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.liked = objects;
        [self refreshProfile];
    }];
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch ((UserMediaCollectionSections)section) {
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
    UserMediaCollectionSections section = indexPath.section;
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
    UserMediaCollectionSections section = indexPath.section;
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
            cell.user = user;
            return cell;
        }
        case kSectionUserLiked:
        {
            UserLikesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserLikesCell forIndexPath:indexPath];
            User *user = [self.liked objectAtIndex:row];
            cell.user = user;
            return cell;
        }
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch ((UserMediaCollectionSections) section) {
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
    UserMediaCollectionSections section = indexPath.section;
    if (kind == UICollectionElementKindSectionHeader) {
        UserProfileHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kUserProfileHeader forIndexPath:indexPath];
        header.title.textColor = [UIColor darkGrayColor];
        switch (section) {
            case kSectionUserMedia:
                header.title.text = @"USER PHOTOS";
                break;
            case kSectionUserLikes:
                header.title.text = @"FOLLOWING";
                break;
            case kSectionUserLiked:
                header.title.text = @"FOLLOWED BY";
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
    UserMediaCollectionSections section = indexPath.section;
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
    [self addMediaWithHandler:handler];
}

- (void) addMediaWithHandler:(MediaPickerMediaBlock)handler
{
    __LF
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Library"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self addUserMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary mediaBlock:handler];
                                                }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Camera"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self addUserMediaFromSource:UIImagePickerControllerSourceTypeCamera mediaBlock:handler];
                                                }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

- (void) addUserMediaFromSource:(UIImagePickerControllerSourceType)sourceType mediaBlock:(MediaPickerMediaBlock)handler
{
    MediaPicker *mediaPicker = [MediaPicker mediaPickerWithSourceType:sourceType mediaBlock:handler];
    [self.viewController presentViewController:mediaPicker animated:YES completion:nil];
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
