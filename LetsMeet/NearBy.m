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
#import "Chat.h"
#import "Notifications.h"

@interface NearBy ()
@property (nonatomic, weak) User *me;
@property (nonatomic, strong) NSArray* users;
@property (nonatomic, strong) FileSystem *system;
@property (nonatomic, strong) RefreshControl *refresh;
@property (nonatomic, strong) Notifications *notifications;
@end

@implementation NearBy

static NSString * const reuseIdentifier = @"NearByCell";

- (void)awakeFromNib
{
    __LF;
    self.notifications = [Notifications notificationWithMessage:^(id bullet) {
        [self refreshContents];
    } broadcast:^(id senderId, NSString *message, NSTimeInterval duration) {
        
    } refresh:nil];
}

- (void)refreshContents
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    __LF;
    [super viewWillAppear:animated];
    [self.notifications on];
    [self refreshContents];
}

- (void)viewWillDisappear:(BOOL)animated
{
    __LF
    [super viewWillDisappear:animated];
    [self.notifications off];
}

- (void)viewDidLoad {
    __LF
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
    const CGFloat kCellsPerRow = 1.f;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    CGFloat availableWidthForCells = CGRectGetWidth(self.collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow - 1);
    
    CGFloat cellWidth = availableWidthForCells / kCellsPerRow;
    CGFloat cellHeight = 115.f;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
}

- (void)reloadAllUsers
{
    [self.system usersNearMeInBackground:^(NSArray<User *> *users) {
        NSLog(@"Loaded %ld users near me", users.count);
        _users = [NSArray arrayWithArray:users];
        [self.refresh endRefreshing];
        [self refreshContents];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    __LF
    
    if ([[segue identifier] isEqualToString:@"GotoChat"])
    {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        User *selectedUser = self.users[indexPath.row];
        Chat *vc = [segue destinationViewController];
        [vc setUser:selectedUser];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NearByCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    NSUInteger row = indexPath.row;
    
    User*user = [self.users objectAtIndex:row];
    [cell setUser:user collectionView:self.collectionView];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

@end
