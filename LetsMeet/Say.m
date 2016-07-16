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

#define kCellIdentifier @"SayCell"


@interface Say ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSMutableDictionary *heights;
@property (strong, nonatomic) UIFont *textFont;
@property (strong, nonatomic) UIFont *commentFont;
@property (nonatomic) CGFloat cellWidth;
@end

@implementation Say


CGFloat __widthForNumberOfCells(UICollectionView* cv, SayLayout *flowLayout, CGFloat cpr)
{
    return (CGRectGetWidth(cv.bounds) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (cpr - 1))/cpr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:kCellIdentifier bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kCellIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:SayElementKindSectionHeader withReuseIdentifier:SayElementKindSectionHeader];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:SayElementKindSectionFooter withReuseIdentifier:SayElementKindSectionFooter];
    
    // Do any additional setup after loading the view.
    
    SayLayout* layout = (SayLayout*) self.collectionView.collectionViewLayout;
    layout.columnCount = 2;
    layout.minimumColumnSpacing = 10;
    layout.minimumInteritemSpacing = 10;

    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.headerHeight = 10;
    layout.footerHeight = 10;
    
    layout.headerInset = UIEdgeInsetsMake(10, 0, 10, 0);
    layout.footerInset = UIEdgeInsetsMake(10, 0, 10, 0);
    
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

- (void) loadPosts {

    PFQuery *query = [UserPost query];
    [query orderByAscending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [objects enumerateObjectsUsingBlock:^(UserPost* _Nonnull post, NSUInteger idx, BOOL * _Nonnull stop) {
            [post loaded:^{
                self.posts = [self sortedArrayByAddingAnObject:post toSortedArray:self.posts];
                [self.collectionView reloadData];
            }];
        }];
    }];
}

- (NSArray*)sortedArrayByAddingAnObject:(id)object toSortedArray:(NSArray*)objects
{
    NSMutableArray *temp = [NSMutableArray arrayWithArray:objects];
    [temp addObject:object];
    return [temp sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]];
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
    cell.backgroundColor = [UIColor whiteColor];
    cell.post = [self.posts objectAtIndex:indexPath.item];
    cell.textFont = self.textFont;
    cell.commentFont = self.commentFont;
    cell.titleFont = [UIFont boldSystemFontOfSize:11];
    cell.nicknameFont = [UIFont boldSystemFontOfSize:11];
    cell.dateFont = [UIFont systemFontOfSize:9];
    return cell;
}

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


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    CGFloat height = [[self.posts objectAtIndex:indexPath.row] estimatedViewHeightOnWidth:self.cellWidth usingTextFont:self.textFont andCommentFont:self.commentFont edgeIndest:UIEdgeInsetsMake(67, 8, 0, 8)];
    return CGSizeMake(self.cellWidth, height);
}

@end
