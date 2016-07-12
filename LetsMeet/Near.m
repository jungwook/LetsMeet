//
//  Near.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 12..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Near.h"
#import "NearCell.h"
#import "NearHeader.h"
#import "PageSelectionBar.h"
#import "RefreshControl.h"

@interface SectionObject : NSObject
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSString* title;
@property (nonatomic, strong) NSArray* users;
@property (nonatomic) CGFloat from;
@property (nonatomic) CGFloat to;
+ (instancetype) sectionWith:(NSUInteger)index title:(NSString*)title from:(CGFloat)from to:(CGFloat)to;
@end

@implementation SectionObject
+ (instancetype) sectionWith:(NSUInteger)index title:(NSString*)title from:(CGFloat)from to:(CGFloat)to
{
    SectionObject *object = [SectionObject new];
    object.title = title;
    object.index = index;
    object.from = from;
    object.to = to;
    return object;
}

@end

@interface Near ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet PageSelectionBar *bar;
@property (nonatomic, strong) NSArray* sections;
@property (nonatomic, strong) RefreshControl* refresh;
@end

@implementation Near

#define kNearCell @"NearCell"
#define kNearHeader @"NearHeader"


- (void)awakeFromNib
{
    self.refresh = [RefreshControl initWithCompletionBlock:^(UIRefreshControl *refreshControl) {
        [self reloadAllUsersOnCondition:self.bar.index];
    }];
    int index = 0;
    self.sections = @[
                      [SectionObject sectionWith:index++ title:@"next door" from:0 to:1],
                      [SectionObject sectionWith:index++ title:@"hood" from:1 to:2.5],
                      [SectionObject sectionWith:index++ title:@"near" from:2.5 to:5],
                      [SectionObject sectionWith:index++ title:@"suburb" from:5 to:10],
                      [SectionObject sectionWith:index++ title:@"city" from:10 to:25],
                      [SectionObject sectionWith:index++ title:@"county" from:25 to:100],
                      [SectionObject sectionWith:index++ title:@"country" from:100 to:500],
                      [SectionObject sectionWith:index++ title:@"world" from:500 to:FLT_MAX],
                      ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView addSubview:self.refresh];
    
    [self.bar setBarColor:[UIColor whiteColor]];
    [self.bar setBackgroundColor:[UIColor clearColor]];
    [self.bar addButtonWithTitle:@"All"];
    [self.bar addButtonWithTitle:@"Girls"];
    [self.bar addButtonWithTitle:@"Boys"];
    [self.bar addButtonWithTitle:@"People I Like"];
    [self.bar setHandler:^(NSUInteger index) {
        [self reloadAllUsersOnCondition:index];
        [self.refresh beginRefreshing];
    }];
    self.collectionView.contentInset = self.contentInset;
    [self.collectionView registerNib:[UINib nibWithNibName:kNearCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kNearCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kNearHeader bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kNearHeader];
    
    [self.collectionView reloadData];
    [self reloadAllUsersOnCondition:self.bar.index];
}

- (NSArray*) arrayOfUserIds:(NSArray*)users
{
    NSMutableArray *userIds = [NSMutableArray array];
    [users enumerateObjectsUsingBlock:^(User* _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        [userIds addObject:user.objectId];
    }];
    return userIds;
}

- (void)usersNear:(User*)user completionHandler:(UsersArrayBlock)block condition:(NSUInteger)condition
{
    PFQuery *query = [User query];
    switch (condition) {
        case 1:
            [query whereKey:@"sex" equalTo:@(kSexFemale)];
            break;
        case 2:
            [query whereKey:@"sex" equalTo:@(kSexMale)];
            break;
        case 3:
            [query whereKey:@"objectId" containedIn:[self arrayOfUserIds:[User me].likes]];
            break;
        default:
            break;
    }
    
    [query whereKey:@"location" nearGeoPoint:user.location];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (block)
            block([users sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                PFGeoPoint *p1 = ((User*)obj1).location;
                PFGeoPoint *p2 = ((User*)obj2).location;
                
                CGFloat distanceA = [user.location distanceInKilometersTo:p1];
                CGFloat distanceB = [user.location distanceInKilometersTo:p2];
                
                if (distanceA < distanceB) {
                    return NSOrderedAscending;
                } else if (distanceA > distanceB) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }]);
    }];
}

- (void)reloadAllUsersOnCondition:(NSUInteger)condition
{
    User *me = [User me];
    if (![self.refresh isRefreshing]) {
        [self.refresh beginRefreshing];
    }
    [self usersNear:me completionHandler:^(NSArray<User *> *users) {
        [self.sections enumerateObjectsUsingBlock:^(SectionObject* _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
            section.users = [users filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(User* _Nonnull user, NSDictionary<NSString *,id> * _Nullable bindings) {
                CGFloat distance = [me.location distanceInKilometersTo:user.location];
                return (distance<section.to && distance>=section.from);
            }]];
        }];
        
        [self.refresh endRefreshing];
        [self.collectionView reloadData];
    } condition:condition];
}

- (UIEdgeInsets) contentInset
{
    return UIEdgeInsetsMake(-(self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height), 0, 0, 0);
}

- (void)setupSections
{
    self.sections = @[ @(1), @(2.5), @(5), @(10), @(20), @(50), @(100), @(500), @(20000)];
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
    return self.sections.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    SectionObject *sectionObject = [self.sections objectAtIndex:section];
    return sectionObject.users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NearCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kNearCell forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)collectionViewLayout;
    layout.minimumLineSpacing = 4;
    layout.minimumInteritemSpacing = 4;
    layout.sectionInset = UIEdgeInsetsMake(0, 40, 30, 10);
    CGFloat w = widthForNumberOfCells(collectionView, layout, 4);
    return CGSizeMake(w, w);
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(1, 50);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        NearHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kNearHeader forIndexPath:indexPath];
        header.backgroundColor = [UIColor redColor];
        return header;
    }
    else {
        return nil;
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
