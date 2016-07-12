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
#import "UIColor+LightAndDark.h"

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
@property (nonatomic, strong) NSArray* timeSections;
@property (nonatomic, strong) NSArray* distanceSections;
@property (nonatomic, strong) NSArray* users;
@property (nonatomic, strong) RefreshControl* refresh;
@property (weak, nonatomic) IBOutlet UISwitch *searchSwitch;
@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) NSArray *otherSections;
@end

@implementation Near

#define kNearCell @"NearCell"
#define kNearHeader @"NearHeader"


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.refresh = [RefreshControl initWithCompletionBlock:^(UIRefreshControl *refreshControl) {
        [self reloadAllUsersOnCondition:self.bar.index];
    }];
    int index = 0;
    self.distanceSections = @[
                      [SectionObject sectionWith:index++ title:@"next door" from:0 to:1],
                      [SectionObject sectionWith:index++ title:@"hood" from:1 to:2.5],
                      [SectionObject sectionWith:index++ title:@"near" from:2.5 to:5],
                      [SectionObject sectionWith:index++ title:@"suburb" from:5 to:10],
                      [SectionObject sectionWith:index++ title:@"city" from:10 to:25],
                      [SectionObject sectionWith:index++ title:@"county" from:25 to:100],
                      [SectionObject sectionWith:index++ title:@"country" from:100 to:500],
                      [SectionObject sectionWith:index++ title:@"world" from:500 to:FLT_MAX],
                      ];
    index = 0;
    self.timeSections = @[
                          [SectionObject sectionWith:index++ title:@"just now" from:0 to:1],
                          [SectionObject sectionWith:index++ title:@"recent" from:1 to:10],
                          [SectionObject sectionWith:index++ title:@"1 hour ago" from:10 to:60],
                          [SectionObject sectionWith:index++ title:@"within 24 hours" from:60 to:(60*24)],
                          [SectionObject sectionWith:index++ title:@"long time ago" from:(60*24) to:FLT_MAX],
                          ];
    [self setPageTitle];
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
    
    [self reloadAllUsersOnCondition:self.bar.index];
}

- (void)setPageTitle
{
    self.navigationItem.title = [(self.searchSwitch.on ? @"Near by time" : @"Near by distance") uppercaseString];
}

- (IBAction)toggleSection:(UISwitch *)sender
{
    [self setPageTitle];
    if (self.users.count) {
        [self sortSectionUsers:self.users andMe:[User me] toggle:YES];
    }
    else {
        [self reloadAllUsersOnCondition:self.bar.index];
    }
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
            block(users);
    }];
}

- (NSArray*) sections
{
    return self.searchSwitch.on ? self.timeSections : self.distanceSections;
}

- (NSArray*) otherSections
{
    return self.searchSwitch.on ? self.distanceSections : self.timeSections;
}

- (void)reloadAllUsersOnCondition:(NSUInteger)condition
{
    User *me = [User me];
    if (![self.refresh isRefreshing]) {
        [self.refresh beginRefreshing];
    }
    [self usersNear:me completionHandler:^(NSArray<User *> *users) {
        self.users = users;
        [self sortSectionUsers:users andMe:me toggle:NO];
    } condition:condition];
}

- (void) sortSectionUsers:(NSArray*)users andMe:(User*)me toggle:(BOOL)toggle
{
    [self.sections enumerateObjectsUsingBlock:^(SectionObject* _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        NSPredicate *distancePredicate = [NSPredicate predicateWithBlock:^BOOL(User* _Nonnull user, NSDictionary<NSString *,id> * _Nullable bindings) {
            CGFloat distance = [me.location distanceInKilometersTo:user.location];
            return (distance<section.to && distance>=section.from);
        }];
        NSPredicate *timePredicate = [NSPredicate predicateWithBlock:^BOOL(User* _Nonnull user, NSDictionary<NSString *,id> * _Nullable bindings) {
            CGFloat timeInMinutes = fabs([user.updatedAt timeIntervalSinceNow])/60.0f;
            return (timeInMinutes<section.to && timeInMinutes>=section.from);
        }];
        
        section.users = [[users filteredArrayUsingPredicate:self.searchSwitch.on ? timePredicate : distancePredicate] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            PFGeoPoint *p1 = ((User*)obj1).location;
            PFGeoPoint *p2 = ((User*)obj2).location;
            
            CGFloat distanceA = [me.location distanceInKilometersTo:p1];
            CGFloat distanceB = [me.location distanceInKilometersTo:p2];
            
            if (distanceA < distanceB) {
                return NSOrderedAscending;
            } else if (distanceA > distanceB) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
    }];
    
    if (users.count>0) {
        [self.collectionView performBatchUpdates:^{
            [(toggle ? self.otherSections : self.sections) enumerateObjectsUsingBlock:^(SectionObject* _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:idx]];
            }];
            [self.sections enumerateObjectsUsingBlock:^(SectionObject* _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:idx]];
            }];
        } completion:nil];
    }
    else {
        [self.collectionView reloadData];
    }
    [self.refresh endRefreshing];
}

- (UIEdgeInsets) contentInset
{
    return UIEdgeInsetsMake(-(self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height), 0, 0, 0);
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
    SectionObject *section = [self.sections objectAtIndex:indexPath.section];
    cell.user = [section.users objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)collectionViewLayout;
    layout.minimumLineSpacing = 4;
    layout.minimumInteritemSpacing = 4;
    layout.sectionInset = UIEdgeInsetsMake(0, 40, 0, 10);
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
        
        
        
        SectionObject *section = [self.sections objectAtIndex:indexPath.section];
//        header.title.text = [[section.title uppercaseString] stringByAppendingString:[NSString stringWithFormat:@" (%ld)", section.users.count]];

        UIFont *normalFont = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:14];
        UIFont *countFont = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:12];
        
        UIColor *normalColor = [UIColor darkGrayColor];
        UIColor *countColor = normalColor.lighterColor;
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowColor : [UIColor colorWithWhite:1.0 alpha:0.8]];
        [shadow setShadowOffset : CGSizeMake (1.0, 1.0)];
        [shadow setShadowBlurRadius : 1];
        
        NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString : [section.title uppercaseString]
                                                                        attributes : @{
                                                                                       NSKernAttributeName : @2.0,
                                                                                       NSFontAttributeName : normalFont,
                                                                                       NSForegroundColorAttributeName : normalColor,
                                                                                       NSShadowAttributeName : shadow }];
        NSAttributedString *countText = [[NSAttributedString alloc] initWithString : [NSString stringWithFormat:@" (%ld)", section.users.count]
                                                                        attributes : @{
                                                                                       NSKernAttributeName : @2.0,
                                                                                       NSFontAttributeName : countFont,
                                                                                       NSForegroundColorAttributeName : countColor,
                                                                                       NSShadowAttributeName : shadow }];
        [labelText appendAttributedString:countText];
        header.title.attributedText = labelText;
        
        return header;
    }
    else {
        return nil;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"SELECTED");
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
