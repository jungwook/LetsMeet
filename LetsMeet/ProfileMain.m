//
//  ProfileMain.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 1..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ProfileMain.h"
#import "ProfileMainView.h"
#import "MediaPicker.h"
#import "MediaViewer.h"

@interface ProfileMediaCell :UICollectionViewCell
@property (nonatomic, weak) UICollectionViewController* controller;
@property (nonatomic, weak) NSMutableArray *mediaArray;
@property (weak, nonatomic) IBOutlet MediaView *thumbnail;
@property (weak, nonatomic) UserMedia *media;
@end

@implementation ProfileMediaCell

- (IBAction)actionOnThumbnail:(UIButton *)sender {
    __LF
}

- (NSInteger)rowForMediaItem
{
    __block NSInteger index = 0;
    [self.mediaArray enumerateObjectsUsingBlock:^(UserMedia*  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([item.objectId isEqualToString:self.media.objectId]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (IBAction)deleteMedia:(id)sender {
    __LF
    [self.media deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error && succeeded) {
            [self.controller.collectionView performBatchUpdates:^{
                [self.mediaArray removeObject:self.media];
                [self.controller.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self rowForMediaItem] inSection:0]]];
            } completion:^(BOOL finished) {
//                [self.controller.collectionView reloadData];
            }];
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
        
    }];
}

- (void)setMedia:(UserMedia *)media
{
    _media = media;

    [self.thumbnail loadMediaFromUserMedia:media];
}

@end

@interface AddMediaCell : UICollectionViewCell
@property (nonatomic, weak) UICollectionViewController* controller;
@property (nonatomic, weak) NSMutableArray *media;
@property (nonatomic, weak) User *user;
@end

@implementation AddMediaCell

- (IBAction)addMeda:(UIButton *)sender {
    __LF
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Library"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self selectMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
                                                }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Camera"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self selectMediaFromSource:UIImagePickerControllerSourceTypeCamera];
                                                }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil]];
    [self.controller presentViewController:alert animated:YES completion:nil];
}

- (void) selectMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    MediaPicker *mediaPicker = [MediaPicker mediaPickerWithSourceType:sourceType mediaBlock:^(ProfileMediaTypes mediaType, NSData *thumbnailData, NSString *thumbnailFile, NSString *mediaFile, CGSize mediaSize) {
        UserMedia *media = [UserMedia object];
        media.mediaSize = mediaSize;
        media.mediaFile = mediaFile;
        media.thumbailFile = thumbnailFile;
        media.mediaType = mediaType;
        media.userId = self.user.objectId;
        [media saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error) {
                [self.media addObject:media];
                [self.controller.collectionView reloadData];
            }
            else {
                NSLog(@"ERROR:%@", error.localizedDescription);
            }
        }];
    }];
    [self.controller presentViewController:mediaPicker animated:YES completion:nil];
}

@end

@interface ProfileMain ()
@property (nonatomic, strong) User *me;
@property (nonatomic, strong) NSMutableArray *media;
@end

@implementation ProfileMain

- (void)awakeFromNib
{
    self.me = [User me];
}

- (void)setMe:(User *)user
{
    _me = user;
    [self refreshMedia];
}

- (void)setCellSpacing
{
    const CGFloat kCellsPerRow = 3;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    flowLayout.minimumLineSpacing = 2;
    flowLayout.minimumInteritemSpacing = 2;
    
    CGFloat availableWidthForCells = CGRectGetWidth(self.collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow - 1);
    
    CGFloat cellWidth = availableWidthForCells / kCellsPerRow;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
}

- (void)viewDidLoad
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [super viewDidLoad];
    [self setCellSpacing];
    
    UIImageView *backgroundImageView = [UIImageView new];
    backgroundImageView.frame = self.collectionView.bounds;
    
    backgroundImageView.image = [UIImage imageNamed:@"bg"];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.collectionView.backgroundView = backgroundImageView;
}

- (void) refreshMedia
{
    PFQuery *query = [UserMedia query];
    [query whereKey:@"userId" equalTo:self.me.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            self.media = [NSMutableArray arrayWithArray:objects];
            [self.collectionView reloadData];
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    }];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ProfileMainView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileMain" forIndexPath:indexPath];
    
    if (kind == UICollectionElementKindSectionHeader) {
        [view sayHi];
        return view;
    }
    else {
        return [UICollectionReusableView new];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.media.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = self.media.count;
    
    if (count == indexPath.row) {
        AddMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddMedia" forIndexPath:indexPath];
        cell.controller = self;
        cell.media = self.media;
        cell.user = self.me;
        return cell;
    }
    else {
        ProfileMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileMedia" forIndexPath:indexPath];
        cell.controller = self;
        cell.mediaArray = self.media;
        [cell setMedia:[self.media objectAtIndex:indexPath.row]];
        return cell;
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
