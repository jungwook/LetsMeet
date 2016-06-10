//
//  NearBy.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "NearBy.h"
#import "NearByCell.h"
#import "RefreshControl.h"
#import "FileSystem.h"

@interface NearBy ()
@property (nonatomic, weak) User *me;
@property (nonatomic, strong) NSArray* users;
@property (nonatomic, strong) FileSystem *system;
@property (nonatomic, strong) RefreshControl *refresh;
@end

@implementation NearBy

static NSString * const reuseIdentifier = @"NearByCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCellSpacing];
    self.me = [User me];
    self.system = [FileSystem new];
    
    self.refresh = [RefreshControl initWithCompletionBlock:^(UIRefreshControl *refreshControl) {
        [self reloadAllUsers];
    }];
    [self.collectionView addSubview:self.refresh];
    [self.refresh beginRefreshing];
    [self reloadAllUsers];
}

- (void)setCellSpacing
{
    const CGFloat kCellsPerRow = 1;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    
    CGFloat availableWidthForCells = CGRectGetWidth(self.collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - 1.0 * (kCellsPerRow - 1);
    
    CGFloat cellWidth = availableWidthForCells / kCellsPerRow;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth+8);
}

- (void)reloadAllUsers
{
    [self.system usersNearMeInBackground:^(NSArray<User *> *users) {
        NSLog(@"Loaded %ld users near me", users.count);
        _users = [NSArray arrayWithArray:users];
        [self.refresh endRefreshing];
        [self.collectionView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.users.count;
}

typedef void (^NearByCellBlock)(NearByCell *cell);

- (void)updateCellForUserId:(id)userId block:(NearByCellBlock)block
{
    NSArray *visible = [self.collectionView visibleCells];
    [visible enumerateObjectsUsingBlock:^(NearByCell* cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell.user.objectId isEqualToString:userId]) {
            if (block)
                block(cell);
            *stop = YES;
        }
    }];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NearByCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    NSUInteger row = indexPath.row;
    
    User*user = [self.users objectAtIndex:row];
    [cell setUser:user completion:^(User *user, NSData* data) {
        [self updateCellForUserId:user.objectId block:^(NearByCell *cell) {
            [cell setUserProfileImageWithData:data];
        }];
    }];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

@end
