//
//  UserProfileCollection.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserProfileCollection.h"
#import "UserMediaCell.h"
#import "UserMapCell.h"
#import "UserLikesCell.h"
#import "UserMap.h"

#define kUserMediaCell @"UserMediaCell"
#define kUserMapCell @"UserMapCell"
#define kUserLikesCell @"UserLikesCell"
#define kUserProfileHeader @"UserProfileHeader"

@interface UserProfileCollection()
@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (strong, nonatomic) NSArray *likes;
@property (strong, nonatomic) NSArray *liked;
@property (strong, nonatomic) UserMap *map;
@end

@implementation UserProfileCollection

+ (instancetype) new
{
    return [[UserProfileCollection alloc] init];
}

- (instancetype)init
{
    self.layout = [UICollectionViewFlowLayout new];
    self.layout.minimumLineSpacing = 0;
    self.layout.minimumInteritemSpacing = 10;
    self.layout.sectionInset = UIEdgeInsetsMake(10, 40, 10, 10);
    
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds collectionViewLayout:self.layout];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        __LF
    }
    return self;
}

- (void) initialize
{
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self registerNib:[UINib nibWithNibName:kUserMediaCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kUserMediaCell];
    [self registerNib:[UINib nibWithNibName:kUserMapCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kUserMapCell];
    [self registerNib:[UINib nibWithNibName:kUserLikesCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kUserLikesCell];
    [self registerNib:[UINib nibWithNibName:kUserProfileHeader bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kUserProfileHeader];
    
    self.map = [UserMap new];
    self.user = [User me];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    __LF
    [self initialize];
}

- (void)setUser:(User *)user
{
    _user = user;
    
    self.delegate = self;
    self.dataSource = self;
    [self.map setUser:user];
    [self loadAllLikesUsers];
    [self loadAllLikedUsers];
    [self refreshProfile];
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
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    switch ((CollectionSection) section) {
        case kCollectionSectionMedia:
            numRows = self.user.media.count;
            break;
            
        case kCollectionSectionMap:
            numRows = 1;
            break;

        case kCollectionSectionLikes:
            numRows = self.likes.count;
            break;

        case kCollectionSectionLiked:
            numRows = self.liked.count;
            break;
    }
    return numRows;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    CollectionSection section = indexPath.section;
    switch (section) {
        case kCollectionSectionMedia:
        {
            UserMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserMediaCell forIndexPath:indexPath];
            UserMedia* media = [self.user.media objectAtIndex:row];
            [cell setUserMedia:media parent:nil row:row];
            cell.backgroundColor = [UIColor darkGrayColor];
            return cell;
        }
        case kCollectionSectionMap:
        {
            UserMapCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserMapCell forIndexPath:indexPath];
            cell.user = self.user;
            cell.backgroundColor = [UIColor darkGrayColor];
            return cell;
        }
        case kCollectionSectionLikes:
        {
            UserLikesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserLikesCell forIndexPath:indexPath];
            User *user = [self.likes objectAtIndex:row];
            cell.user = user;
            cell.backgroundColor = [UIColor darkGrayColor];
            return cell;
        }
        case kCollectionSectionLiked:
        {
            UserLikesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserLikesCell forIndexPath:indexPath];
            User *user = [self.liked objectAtIndex:row];
            cell.user = user;
            cell.backgroundColor = [UIColor darkGrayColor];
            return cell;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)collectionViewLayout;
    CollectionSection section = indexPath.section;
    switch (section) {
        case kCollectionSectionMedia: {
            layout.minimumLineSpacing = 2;
            layout.minimumInteritemSpacing = 2;
            layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
            CGFloat w = widthForNumberOfCells(collectionView, layout, 3);
            return CGSizeMake(w, w+25);
        }
            break;
            
        case kCollectionSectionMap:{
            layout.minimumLineSpacing = 2;
            layout.minimumInteritemSpacing = 2;
            layout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4);
            CGFloat w = widthForNumberOfCells(collectionView, layout, 1);
            return CGSizeMake(w, 250);
        }
            break;
            
        case kCollectionSectionLikes:{
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 4;
            layout.sectionInset = UIEdgeInsetsMake(10, 40, 10, 10);
            CGFloat w = widthForNumberOfCells(collectionView, layout, 6);
            return CGSizeMake(w, w+25);
        }
            break;
            
        case kCollectionSectionLiked:{
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 10;
            layout.sectionInset = UIEdgeInsetsMake(10, 40, 10, 10);
            CGFloat w = widthForNumberOfCells(collectionView, layout, 6);
            return CGSizeMake(w, w+25);
        }
            break;
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(1, 30);
}



@end
