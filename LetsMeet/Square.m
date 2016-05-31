//
//  Square.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 29..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Square.h"
#import "SquareCell.h"
#import "AppEngine.h"
#import "PFUser+Attributes.h"
#import "RefreshControl.h"
#import "IndentedLabel.h"
#import "CachedFile.h"
#import "Chat.h"

@interface Square ()
@property (nonatomic, strong) PFGeoPoint* location;
@property (nonatomic, strong, readonly) NSArray *users;
@property (nonatomic, weak, readonly) AppEngine *engine;
@end

@implementation Square


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

static NSString * const reuseIdentifier = @"Square";

- (void)setCellSpacing
{
    const CGFloat kCellsPerRow = 3;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    flowLayout.minimumLineSpacing = 1;
    flowLayout.minimumInteritemSpacing = 1;
    
    CGFloat availableWidthForCells = CGRectGetWidth(self.collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - 1.0 * (kCellsPerRow - 1);
    
    CGFloat cellWidth = availableWidthForCells / kCellsPerRow;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCellSpacing];
    self.location = [PFGeoPoint geoPointWithLatitude:37.520884 longitude:127.028360];
    
    RefreshControl *refresh = [RefreshControl initWithCompletionBlock:^(UIRefreshControl *refreshControl) {
        [self loadUsersInBackground:^(NSArray *users) {
            _users = [NSArray arrayWithArray:users];
            [refreshControl endRefreshing];
        }];
    }];
    [self.collectionView addSubview:refresh];
    
    [self loadUsersInBackground:^(NSArray *users) {
        _users = [NSArray arrayWithArray:users];
    }];
}

- (void)loadUsersInBackground:(ArrayResultBlock)block
{
    PFQuery *query = [PFUser query];
    [query whereKey:AppKeyLocationKey nearGeoPoint:self.location];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR LOADING USERS NEAR ME:%@", error.localizedDescription);
        }
        else {
            if (block) {
                block(users);
            }
            [self.collectionView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMessageReceived:)
                                                 name:AppUserNewMessageReceivedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(broadcastMessageReceived:)
                                                 name:AppUserBroadcastNotification
                                               object:nil];
    [self.collectionView reloadData];
    SENDNOTIFICATION(AppUserRefreshBadgeNotificaiton, nil);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserNewMessageReceivedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserBroadcastNotification
                                                  object:nil];
}

- (void) broadcastMessageReceived:(NSNotification*)userInfo
{
    NSLog(@"USERNOTIF:%@", userInfo);
    id notif = userInfo.object;
    
    id senderId = notif[@"senderId"];
    NSString* message = notif[@"message"];
    NSNumber* duration = notif[@"duration"];

    [self updateCellForUserId:senderId block:^(SquareCell *cell) {
        [cell setBroadcastMessage:message duration:duration];
    }];
}

typedef void (^SquareCellBlock)(SquareCell *cell);

- (void)updateCellForUserId:(id)userId block:(SquareCellBlock)block
{
    NSArray *visible = [self.collectionView visibleCells];
    [visible enumerateObjectsUsingBlock:^(SquareCell* cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell.user.objectId isEqualToString:userId]) {
            if (block)
                block(cell);
            *stop = YES;
        }
    }];
}

- (void) newMessageReceived:(NSNotification*)userInfo
{
    PFUser *user = [self userFromUserId:userInfo.object[@"fromUser"]];
    [self updateCellForUserId:user.objectId block:^(SquareCell *cell) {
        [cell setUser:user location:self.location collectionView:self.collectionView];
    }];
}

- (PFUser*)userFromUserId:(id)userId
{
    __block PFUser *ret = nil;
    [self.users enumerateObjectsUsingBlock:^(PFUser* _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([user.objectId isEqualToString:userId]) {
            ret = user;
            *stop = YES;
        }
    }];
    return ret;
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *user = self.users[indexPath.row];
    UIImage *sexImage = [UIImage imageNamed:(user.sex == AppMaleUser) ? @"guy" : @"girl"];

    SquareCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell setUser:user location:self.location collectionView:self.collectionView];
    [cell setProfilePhoto:sexImage];
    [CachedFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error, BOOL fromCache) {
        if (fromCache) {
            [cell setProfilePhoto:data ? [UIImage imageWithData:data] : sexImage];
        }
        else {
            [self updateCellForUserId:user.objectId block:^(SquareCell *cell) {
                [cell setProfilePhoto:[UIImage imageWithData:data]];
            }];
        }
    } fromFile:user.profilePhoto];
    
    return cell;
}

- (IBAction)sendMessage:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"공개 메시지" message:@"공유하고자 하는 메시지를 입력하세요!" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.tag = 0;
    }];
    
    UIAlertAction *message = [UIAlertAction actionWithTitle:@"5초간" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        NSLog(@"%@",[[alert textFields] firstObject].text);
        [AppEngine appEngineBroadcastPush:[[alert textFields] firstObject].text duration:@(5)];
    }];
    UIAlertAction *longer = [UIAlertAction actionWithTitle:@"10초간" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                                  NSLog(@"%@",[[alert textFields] firstObject].text);
                                  [AppEngine appEngineBroadcastPush:[[alert textFields] firstObject].text duration:@(10)];
                              }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:message];
    [alert addAction:longer];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"GotoChat"])
    {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        PFUser *selectedUser = self.users[indexPath.row];
        Chat *vc = [segue destinationViewController];
        [vc setChatUser:selectedUser];
    }
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
