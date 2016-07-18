//
//  Say.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 15..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Say.h"
#import "SayCell.h"
#import "S3File.h"
#import "UserPostView.h"
#import "RefreshControl.h"
#import "SayHeader.h"

#define kCellIdentifier @"SayCell"

@interface PopAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@end

@implementation PopAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end

@interface PushAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic) CGRect originalFrame;
@end

@implementation PushAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [[transitionContext containerView] addSubview:toViewController.view];
    
//    toViewController.view.alpha = 0.0;

    [toViewController.view.subviews firstObject].frame = self.originalFrame;
    NSLog(@"ORIG:%@", NSStringFromCGRect(self.originalFrame));
    [UIView animateWithDuration:0.25 animations:^{
//        toViewController.view.alpha = 1.0;
        [toViewController.view.subviews firstObject].frame = toViewController.view.bounds;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end

@interface Say ()
{
    CGRect originalFrame;
}
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSMutableDictionary *heights;
@property (strong, nonatomic) UIFont *textFont;
@property (strong, nonatomic) UIFont *commentFont;
@property (nonatomic) CGFloat cellWidth;
@property (strong, nonatomic) NSMutableDictionary *viewDic;
@property (nonatomic) NSInteger columnCount;
@property (strong, nonatomic) RefreshControl *refresh;
@property (strong, nonatomic) id properties;
@property (weak, nonatomic) IBOutlet UIView *headerBackView;
@property (strong, nonatomic) SayHeader *headerView;
@end

#define kSayHeader @"SayHeader"

@implementation Say

CGFloat __widthForNumberOfCells(UICollectionView* cv, SayLayout *flowLayout, CGFloat cpr)
{
    return (CGRectGetWidth(cv.bounds) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (cpr - 1))/cpr;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadPosts];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.columnCount = 3;
    self.properties = @{
                      @"titleFont" : [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:11],
                      @"nicknameFont" : [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:12],
                      @"textFont" : [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:10],
                      @"commentFont" : [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:10],
                      @"dateFont" : [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:10],
                      };
    
    self.viewDic = [NSMutableDictionary dictionary];
    self.heights = [NSMutableDictionary dictionary];

    [self initializeCollectionViewAttributes];
    [self initializeHeaderAttributes];
    [self initializeLayoutAttributes];
    
    self.navigationController.delegate = self;
}

- (void)initializeLayoutAttributes
{
    SayLayout* layout = (SayLayout*) self.collectionView.collectionViewLayout;
    layout.columnCount = self.columnCount;
    layout.minimumColumnSpacing = 2;
    layout.minimumInteritemSpacing = 2;
    //    layout.itemRenderDirection = SayLayoutItemRenderDirectionLeftToRight;
    //    layout.headerHeight = 200;
    
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerInset = UIEdgeInsetsZero;
    layout.footerInset = UIEdgeInsetsZero;
    self.cellWidth = __widthForNumberOfCells(self.collectionView, layout, self.columnCount);
}

- (void)initializeHeaderAttributes
{
    self.headerView = [[[NSBundle mainBundle] loadNibNamed:kSayHeader owner:self options:nil] firstObject];
    self.headerView.frame = self.headerBackView.bounds;
    self.headerView.backgroundColor = [self.collectionView.backgroundColor colorWithAlphaComponent:0.95];

    [self.headerBackView addSubview:self.headerView];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.headerView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)initializeCollectionViewAttributes
{
    self.refresh = [RefreshControl initWithCompletionBlock:^(UIRefreshControl *refreshControl) {
        [self loadPosts];
    }];
    
    [self.collectionView setBackgroundView:nil];
    [self.collectionView setContentInset:UIEdgeInsetsMake(200, 0, 0, 0)];
    [self.collectionView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerNib:[UINib nibWithNibName:kCellIdentifier bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kCellIdentifier];
    //    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:SayElementKindSectionFooter withReuseIdentifier:SayElementKindSectionFooter];
    //    [self.collectionView registerNib:[UINib nibWithNibName:kSayHeader bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:SayElementKindSectionHeader withReuseIdentifier:kSayHeader];
    [self.collectionView addSubview:self.refresh];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadPosts
{
    if (![self.refresh isRefreshing]) {
        [self.refresh beginRefreshing];
    }
    
    PFQuery *query = [UserPost query];
    [query orderByAscending:@"updatedAt"];
    [query whereKey:@"location" nearGeoPoint:[User me].location withinKilometers:1];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.refresh endRefreshing];
        [objects enumerateObjectsUsingBlock:^(UserPost* _Nonnull post, NSUInteger idx, BOOL * _Nonnull stop) {
            [post loaded:^{
                if (![self postLoaded:post]) {
                    [self.viewDic setObject:[[UserPostView alloc] initWithWidth:self.cellWidth
                                                                           post:post
                                                                     properties:self.properties]
                                     forKey:post.objectId];
                    [self.collectionView performBatchUpdates:^{
                        self.posts = [self sortedArrayByAddingAnObject:post toSortedArray:self.posts];
                        NSInteger index = [self.posts indexOfObject:post];
                        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
                    } completion:nil];
                }
            }];
        }];
    }];
}

- (BOOL) postLoaded:(UserPost*)thisPost
{
    __block BOOL ret = NO;
    [self.posts enumerateObjectsUsingBlock:^(UserPost* _Nonnull post, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([post.objectId isEqualToString:thisPost.objectId]) {
            ret = YES;
            *stop = YES;
        }
    }];
    return ret;
}

- (NSInteger)insertPost:(UserPost*)postToInsert
{
    __block NSInteger index =0;
    [self.posts enumerateObjectsUsingBlock:^(UserPost* _Nonnull post, NSUInteger idx, BOOL * _Nonnull stop) {
        if (postToInsert.createdAt > post.createdAt) {
            *stop = YES;
        }
        index++;
    }];
    return index;
}


- (NSArray*)sortedArrayByAddingAnObject:(id)object toSortedArray:(NSArray*)objects
{
    NSMutableArray *temp = [NSMutableArray arrayWithArray:objects];
    [temp addObject:object];
    return [temp sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.posts.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section
{
    return self.columnCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.userPostView = [self postViewAtIndexPath:indexPath];
    return cell;
}

- (UserPostView*)postViewAtIndexPath:(NSIndexPath*)indexPath
{
    UserPost *post = [self.posts objectAtIndex:indexPath.row];
    return [self.viewDic objectForKey:post.objectId];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    UserPost *post = [self.posts objectAtIndex:indexPath.row];
    UserPostView* view = [[UserPostView alloc] initWithWidth:self.cellWidth
                                                        post:post
                                                  properties:self.properties];
    
//    SayCell* cell = (SayCell*)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    UserPostView *pv = [self postViewAtIndexPath:indexPath];
    originalFrame = [pv convertRect:pv.frame toView:self.view];
    
    UIViewController *vc = [UIViewController new];
    
    [vc.view addSubview:view];
    view.frame = originalFrame;

    [self.navigationController pushViewController:vc animated:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    if (operation == UINavigationControllerOperationPush) {
        PushAnimator *push = [[PushAnimator alloc] init];
        push.originalFrame = originalFrame;
        return push;
    }
    
    if (operation == UINavigationControllerOperationPop)
        return [[PopAnimator alloc] init];
    
    return nil;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    __LF
//    UICollectionReusableView *reusableView = nil;
//    
//    if ([kind isEqualToString:SayElementKindSectionHeader]) {
//        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
//                                                          withReuseIdentifier:kSayHeader
//                                                                 forIndexPath:indexPath];
//    } else if ([kind isEqualToString:SayElementKindSectionFooter]) {
//        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
//                                                          withReuseIdentifier:SayElementKindSectionFooter
//                                                                 forIndexPath:indexPath];
//        reusableView.backgroundColor = [UIColor blueColor];
//    }
//    
//    return reusableView;
//}

/*
*/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.cellWidth, [self postViewAtIndexPath:indexPath].viewHeight);
}

@end
