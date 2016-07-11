//
//  UserLikesCollection.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserLikesCollection.h"
#import "UserLikesCell.h"
#import "UserLikesHeader.h"

#define kCellIdentifier @"UserLikesCell"
#define kHeaderIdentifier @"UserLikesHeader"

@interface UserLikesCollection()
@property (nonatomic, strong) UICollectionViewFlowLayout *flow;
@property (nonatomic, copy) UserLikesCollectionBlock handler;
@property (nonatomic, strong) NSArray* likes;
@property (nonatomic, strong) NSArray* liked;
@end

@implementation UserLikesCollection

+ (instancetype)userLikesCollectionWithHandler:(UserLikesCollectionBlock)handler
{
    return [[UserLikesCollection alloc] initWithHandler:handler];
}

- (instancetype)initWithHandler:(UserLikesCollectionBlock)handler;
{
    self.flow = [UICollectionViewFlowLayout new];
    self.flow.minimumLineSpacing = 0;
    self.flow.minimumInteritemSpacing = 10;
    self.flow.sectionInset = UIEdgeInsetsMake(10, 40, 10, 10);
    
    self = [super initWithFrame:CGRectMake(0, 0, 1, 1) collectionViewLayout:self.flow];
    if (self) {
        self.handler = handler;
        self.titleColor = [UIColor darkGrayColor];
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self registerNib:[UINib nibWithNibName:kCellIdentifier bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kCellIdentifier];
        [self registerNib:[UINib nibWithNibName:kHeaderIdentifier bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderIdentifier];
    }
    return self;
}

- (void)viewDidLoad
{
    __LF
    self.user = [User me];
    self.delegate = self;
    self.dataSource = self;
    [self loadAllLikesUsers];
    [self loadAllLikedUsers];
}

- (void)loadAllLikesUsers
{
    PFQuery *query = [User query];
    [query whereKey:@"objectId" containedIn:self.user.likes];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.likes = objects;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }];
}

- (void) loadAllLikedUsers
{
    PFQuery *query = [User query];
    [query whereKey:@"likes" containsString:self.user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.liked = objects;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }];
}

- (void)setUser:(User *)user
{
    _user = user;
    
}

CGFloat __widthForNumberOfCells(UICollectionView* cv, UICollectionViewFlowLayout *flowLayout, CGFloat cpr)
{
    return (CGRectGetWidth(cv.bounds) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (cpr - 1))/cpr;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    const CGFloat numCellsPerRow = 6;
    const CGFloat w = __widthForNumberOfCells(collectionView, (UICollectionViewFlowLayout*) collectionViewLayout, numCellsPerRow), h = w + 25;
    
    return CGSizeMake(w, h);
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(200, section == 0 ? 50 : 25);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return section == 0 ? self.likes.count : self.liked.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserLikesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    NSUInteger row = indexPath.row;
    cell.user = (indexPath.section == 0) ? self.likes[row] : self.liked[row];
    cell.titleColor = self.titleColor;

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        UserLikesHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderIdentifier forIndexPath:indexPath];
        header.titleLabel.text = indexPath.section == 0 ? @"Users I like" : @"Users who like me";
        header.titleLabel.textColor = self.titleColor;
        return header;
    }
    else {
        return nil;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    NSUInteger row = indexPath.row;
    User *user = (indexPath.section == 0) ? self.likes[row] : self.liked[row];
    if (self.handler) {
        self.handler(user);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
