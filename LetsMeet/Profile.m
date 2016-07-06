//
//  Profile.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 6..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Profile.h"
#import "SelectionBar.h"
#import "MediaViewer.h"

@interface MediaCell : UICollectionViewCell
@property (weak, nonatomic) UserMedia *media;
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (weak, nonatomic) id userId;
@property (weak, nonatomic) UICollectionView* collectionView;
@end

@implementation MediaCell

- (void)setMedia:(UserMedia *)media
{
    _media = media;
    [self.photo setImage:nil];
    [self.photo loadMediaFromUserMedia:media animated:YES];
}

- (void)setUserId:(id)userId
{
    [self.photo setImage:nil];
    User *user = [User objectWithoutDataWithObjectId:userId];
    [user fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [self.photo loadMediaFromUser:user];
    }];
}

@end


@interface MapCell : UICollectionViewCell
@property (weak, nonatomic) User *user;
@end

@implementation MapCell

- (void)setUser:(User *)user
{
    
}

@end

typedef enum {
    kSectionMedia = 0,
    kSectionLocation,
    kSectionLikes,
    kSectionLiked
} Sections;

@interface Profile ()
@property (weak, nonatomic) IBOutlet SelectionBar *selectionBar;
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UITextField *nickname;
@property (weak, nonatomic) IBOutlet UITextField *intro;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *sex;
@property (weak, nonatomic) IBOutlet UILabel *likesLB;
@property (weak, nonatomic) IBOutlet UILabel *likedLB;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) User *user;
@property (nonatomic, readonly) BOOL editable;
@property (nonatomic) Sections section;

@property (strong, nonatomic) NSArray *liked;
@end

@implementation Profile

- (BOOL)editable
{
    return self.user.isMe;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.liked = nil;
    }
    return self;
}

- (void)awakeFromNib
{
    self.section = kSectionMedia;
}

- (void)setCellSpacingForSelection:(NSInteger)selection
{
    const CGFloat h = self.collectionView.bounds.size.height;
    const CGFloat kCellsPerRow = (selection == kSectionLocation) ? 1 : 3;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    
    flowLayout.minimumLineSpacing = 2;
    flowLayout.minimumInteritemSpacing = 2;
    
    CGFloat availableWidthForCells = CGRectGetWidth(self.collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow - 1);
    
    CGFloat cellWidth = availableWidthForCells / kCellsPerRow;
    CGFloat cellHeight = h-64;
    flowLayout.itemSize = CGSizeMake(cellWidth, (selection == kSectionLocation) ? cellHeight : cellWidth);
}

- (void) countLikesMeInBackground
{
    PFQuery *query = [User query];
    [query whereKey:@"likes" containsString:self.user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.liked = [NSArray arrayWithArray:objects];
    }];
}

- (void)setLiked:(NSArray *)liked
{
    _liked = liked;
    self.likedLB.text = [NSString stringWithFormat:@"%ld", self.liked.count];
    if (self.section == kSectionMedia) {
        [self.collectionView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUser:self.user];
    [self setCellSpacingForSelection:kSectionMedia];
    [self setupSelectionButtons];
    [self countLikesMeInBackground];
}

- (void)setSection:(Sections)section
{
    _section = section;
    [self setCellSpacingForSelection:section];
    [self.collectionView reloadData];
}

- (void)setupSelectionButtons
{
    const CGFloat width = 80.0f;
    
    [self.selectionBar addButtonWithTitle:@"Media" width:width];
    [self.selectionBar addButtonWithTitle:@"Location" width:width];
    [self.selectionBar addButtonWithTitle:@"Likes" width:width];
    [self.selectionBar addButtonWithTitle:@"Liked" width:width];
    [self.selectionBar setIndex:self.section];
    [self.selectionBar setHandler:^(NSInteger index) {
        self.section = (Sections) index;
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUser:(User *)user
{
    _user = user ? user : [User me];
    
    self.nickname.text = self.user.nickname;
    self.intro.text = self.user.intro;
    self.age.text = self.user.age;
    self.sex.text = self.user.sexString;
    [self.photo loadMediaFromUser:self.user];
    [self.photo setIsCircle:YES];
    self.section = kSectionMedia;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (self.section) {
        case kSectionMedia:
            return self.user.media.count;
            
        case kSectionLocation:
            return 1;
            
        case kSectionLikes:
            return self.user.likes.count;
            
        case kSectionLiked:
            return self.liked.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.section) {
        case kSectionLocation:
        {
            MapCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MapCell" forIndexPath:indexPath];
            cell.user = self.user;
            return cell;
        }
        case kSectionMedia:
        {
            MediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCell" forIndexPath:indexPath];
            cell.media = [self.user.media objectAtIndex:indexPath.row];
            cell.collectionView = collectionView;
            return cell;
        }
        case kSectionLikes:
        {
            MediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCell" forIndexPath:indexPath];
            cell.userId = [self.user.likes objectAtIndex:indexPath.row];
            cell.collectionView = collectionView;
            return cell;
        }
        case kSectionLiked:
        {
            MediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCell" forIndexPath:indexPath];
            cell.userId = ((User*)[self.liked objectAtIndex:indexPath.row]).objectId;
            cell.collectionView = collectionView;
            return cell;
        }
    }
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCell" forIndexPath:indexPath];
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
