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
@end

@implementation Say

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

    layout.headerHeight = 10;
    layout.footerHeight = 10;
    
    layout.headerInset = UIEdgeInsetsMake(10, 0, 10, 0);
    layout.footerInset = UIEdgeInsetsMake(10, 0, 10, 0);
    
    self.heights = [NSMutableDictionary dictionary];
    
    [self loadPosts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadPosts {
    UIFont *textFont = [UIFont systemFontOfSize:10];
    UIFont *commentFont = [UIFont boldSystemFontOfSize:10];
    CGFloat width = 150;

    PFQuery *query = [UserPost query];
    [query orderByAscending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.posts = objects;

        __block NSInteger count = 0;
        
        [self.posts enumerateObjectsUsingBlock:^(UserPost* _Nonnull post, NSUInteger idx, BOOL * _Nonnull stop) {
            [post fetched:^{
                count+= post.posts.count;
            }];
        }];
        
        NSLog(@"POSTS:%@", self.posts);

        [self.posts enumerateObjectsUsingBlock:^(UserPost* _Nonnull post, NSUInteger idx, BOOL * _Nonnull stop) {
            __block CGFloat top = 0;
            [post.posts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger postsidx, BOOL * _Nonnull stop) {
                NSLog(@"ONK:%@", obj);
                if ([obj isKindOfClass:[NSString class]]) {
                    NSString *text = obj;
                    CGRect rect = __rect(text, textFont, width);
                    top += rect.size.height;
                }
                else if ([obj isKindOfClass:[UserMedia class]]) {
                    UserMedia *media = obj;
                    top += 100;
                    NSString *comment = media.comment;
                    CGRect rect = __rect(comment, commentFont, width);
                    top += rect.size.height;
                }
            }];
            [self.heights setObject:@(top) forKey:[NSIndexPath indexPathForItem:idx inSection:0]];
        }];
        [self.collectionView reloadData];
    }];
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
    CGFloat height = [[self.heights objectForKey:indexPath] floatValue];
    NSLog(@"Height :%f", height);
    return CGSizeMake(150, height);
}

@end
