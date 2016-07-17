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

#define kCellIdentifier @"SayCell"


@interface Say ()
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSMutableDictionary *heights;
@property (strong, nonatomic) UIFont *textFont;
@property (strong, nonatomic) UIFont *commentFont;
@property (nonatomic) CGFloat cellWidth;
@property (strong, nonatomic) NSMutableDictionary *viewDic;

@end

@implementation Say

CGFloat __widthForNumberOfCells(UICollectionView* cv, SayLayout *flowLayout, CGFloat cpr)
{
    return (CGRectGetWidth(cv.bounds) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (cpr - 1))/cpr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewDic = [NSMutableDictionary dictionary];
    [self.collectionView setBackgroundView:nil];
    [self.collectionView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self.collectionView registerNib:[UINib nibWithNibName:kCellIdentifier bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kCellIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:SayElementKindSectionHeader withReuseIdentifier:SayElementKindSectionHeader];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:SayElementKindSectionFooter withReuseIdentifier:SayElementKindSectionFooter];
    
    // Do any additional setup after loading the view.
    
    SayLayout* layout = (SayLayout*) self.collectionView.collectionViewLayout;
    layout.columnCount = 2;
    layout.minimumColumnSpacing = 10;
    layout.minimumInteritemSpacing = 10;

    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
//    layout.headerHeight = 10;
//    layout.footerHeight = 10;
    
    layout.headerInset = UIEdgeInsetsZero;
    layout.footerInset = UIEdgeInsetsZero;
    
    self.heights = [NSMutableDictionary dictionary];
    
    [self loadPosts];
    self.textFont = [UIFont systemFontOfSize:10];
    self.commentFont = [UIFont boldSystemFontOfSize:10];
    self.cellWidth = __widthForNumberOfCells(self.collectionView, layout, 2);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadPosts
{
    PFQuery *query = [UserPost query];
    [query orderByAscending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [objects enumerateObjectsUsingBlock:^(UserPost* _Nonnull post, NSUInteger idx, BOOL * _Nonnull stop) {
            [post loaded:^{
                User *user = [User objectWithoutDataWithObjectId:post.userId];
                [user fetched:^{
                    UserPostView *pv = [[UserPostView alloc] initWithWidth:self.cellWidth properties:nil];
                    [self.viewDic setObject:pv forKey:post.objectId];
                    [pv setLoadedPost:post andUser:user ready:^{
                        [self.collectionView performBatchUpdates:^{
                            self.posts = [self sortedArrayByAddingAnObject:post toSortedArray:self.posts];
                            NSInteger index = [self.posts indexOfObject:post];
                            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
                        } completion:nil];
                    }];
                }];
            }];
        }];
    }];
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
    __LF
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    __LF
    return self.posts.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section
{
    __LF
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    SayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.userPostView = [self postViewAtIndexPath:indexPath];
    return cell;
}

- (UserPostView*)postViewAtIndexPath:(NSIndexPath*)indexPath
{
    UserPost *post = [self.posts objectAtIndex:indexPath.row];
    return [self.viewDic objectForKey:post.objectId];
}

/*
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    __LF
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:SayElementKindSectionHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:SayElementKindSectionHeader
                                                                 forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor redColor];
    } else if ([kind isEqualToString:SayElementKindSectionFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:SayElementKindSectionFooter
                                                                 forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor blueColor];
    }
    
    return reusableView;
}

*/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.cellWidth, [self postViewAtIndexPath:indexPath].viewHeight);
}

@end
