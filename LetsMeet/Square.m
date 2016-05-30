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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    const CGFloat kCellsPerRow = 3;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    flowLayout.minimumLineSpacing = 1;
    flowLayout.minimumInteritemSpacing = 1;
    
    CGFloat availableWidthForCells = CGRectGetWidth(self.collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - 1.0 * (kCellsPerRow - 1);
    
    CGFloat cellWidth = availableWidthForCells / kCellsPerRow;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);

    self.location = [PFGeoPoint geoPointWithLatitude:37.520884 longitude:127.028360];
    
    RefreshControl *refresh = [RefreshControl initWithCompletionBlock:^(UIRefreshControl *refreshControl) {
        [self loadUsersInBackground:^(NSArray *users) {
            _users = [NSArray arrayWithArray:users];
            [refreshControl endRefreshing];
            [self.collectionView reloadData];
        }];
    }];
    [self.collectionView addSubview:refresh];
    
    [self loadUsersInBackground:^(NSArray *users) {
        _users = [NSArray arrayWithArray:users];
        [self.collectionView reloadData];
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
    NSString*message = notif[@"message"];

    [self.users enumerateObjectsUsingBlock:^(PFUser* _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([user.objectId isEqualToString:senderId]) {
            user.broadcastMessage = message;
            user.broadcastMessageAt = [NSDate date];
            *stop = YES;
        }
    }];
    /*
    NSArray *visible = [self.collectionView visibleCells];
    [visible enumerateObjectsUsingBlock:^(SquareCell* cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell.user.objectId isEqualToString:senderId]) {
            [cell setBroadcastMessage:message];
            *stop = YES;
        }
    }];
     */
}

- (void) newMessageReceived:(id)sender
{
    [self.collectionView reloadData];
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
    SquareCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell setUser:user andMessages:[AppEngine appEngineMessagesWithUserId:user.objectId] location:self.location collectionView:self.collectionView];

    [CachedFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error, BOOL fromCache) {
        if (fromCache) {
            [cell setProfilePhoto:data ? [UIImage imageWithData:data] : [UIImage imageNamed:(user.sex == AppMaleUser) ? @"guy" : @"girl"]];
        }
        else {
            NSArray *visible = [self.collectionView visibleCells];
            [visible enumerateObjectsUsingBlock:^(SquareCell* cell, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([cell.user.objectId isEqualToString:user.objectId]) {
                    [cell setProfilePhoto:[UIImage imageWithData:data]];
                    *stop = YES;
                }
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
    
    UIAlertAction *message = [UIAlertAction actionWithTitle:@"등록" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        NSLog(@"%@",[[alert textFields] firstObject].text);
        [AppEngine appEngineBroadcastPush:[[alert textFields] firstObject].text];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:message];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
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
