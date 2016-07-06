//
//  ProfileMain.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 1..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ProfileMain.h"
#import "MediaPicker.h"
#import "MediaViewer.h"
#import "ListPicker.h"

@interface ProfileMainView : UICollectionReusableView
@property (nonatomic, weak) ProfileMain *parent;
@end

@interface ProfileMainView()
@property (weak, nonatomic) IBOutlet MediaView *mainPhoto;
@property (weak, nonatomic) IBOutlet UITextField *nickname;
@property (weak, nonatomic) IBOutlet UITextField *intro;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *sex;
@property (weak, nonatomic) IBOutlet UIButton *gps;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UIButton *edit;
@property (weak, nonatomic) IBOutlet UIButton *addMedia;
@property (weak, nonatomic) IBOutlet UIButton *inbox;
@property (weak, nonatomic) IBOutlet UILabel *ilike;
@property (weak, nonatomic) IBOutlet UILabel *likesme;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;
@property (strong, nonatomic) UIView *band;
@property (strong, nonatomic) NSString* currentLocationAddress;
@property (weak, nonatomic) User *me;
@end

@implementation ProfileMainView

- (void)awakeFromNib
{
    __LF
    self.currentLocationAddress = nil;
    self.backgroundColor = [UIColor clearColor];
    [self.mainPhoto setIsCircle:YES];
    [self setupWhiteEditBand];
}

- (void) setupWhiteEditBand
{
    self.band = [UIView new];
    
    const CGFloat w = self.mainPhoto.bounds.size.width, h = self.mainPhoto.bounds.size.height;
    const CGFloat H = 25;
    self.band.frame = CGRectMake(0, h-H, w, H);
    self.band.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    [self.mainPhoto.imageView addSubview:self.band];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        __LF
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat xs = self.intro.frame.origin.x,
            xe = self.likesme.frame.origin.x + self.likesme.frame.size.width,
            ys = self.intro.frame.origin.y,
            ye = self.intro.frame.origin.y + self.intro.frame.size.height,
            x1 = self.age.frame.origin.x,
            x2 = self.sex.frame.origin.x,
            x3 = self.ilike.frame.origin.x,
            x4 = self.likesme.frame.origin.x;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(xs, ys)];
    [path addLineToPoint:CGPointMake(xe, ys)];
    [path moveToPoint:CGPointMake(x1, ys)];
    [path addLineToPoint:CGPointMake(x1, ye)];
    [path moveToPoint:CGPointMake(x2, ys)];
    [path addLineToPoint:CGPointMake(x2, ye)];
    [path moveToPoint:CGPointMake(x3, ys)];
    [path addLineToPoint:CGPointMake(x3, ye)];
    [path moveToPoint:CGPointMake(x4, ys)];
    [path addLineToPoint:CGPointMake(x4, ye)];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextAddPath(context, path.CGPath);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)sayHiFromUser:(User*)user parent:(ProfileMain*)parent
{
    __LF
    
    self.me = user;
    
    self.parent = parent;
    [self.mainPhoto loadMediaFromUser:user animated:YES];
    self.nickname.text = self.me.nickname;
    
    self.intro.text = self.me.intro ? self.me.intro : @"";
    [ListPicker pickerWithArray:@[@"우리 만나요!", @"애인 찾아요", @"함께 드라이브 해요", @"나쁜 친구 찾아요", @"착한 친구 찾아요", @"함께 먹으러 가요", @"술친구 찾아요"] onTextField:self.intro selection:^(id data) {
        self.me.intro = data;
        [self.me saveInBackground];
    }];
    
    self.age.text = self.me.age ? self.me.age : @"";
    [ListPicker pickerWithArray:@[@"고딩", @"20대", @"30대", @"40대", @"비밀"] onTextField:self.age selection:^(id data) {
        self.me.age = data;
        [self.me saveInBackground];
    }];
    
    self.sex.text = self.me.sexString;
    [ListPicker pickerWithArray:@[@"여자", @"남자"] onTextField:self.sex selection:^(id data) {
        self.me.sex = [data isEqualToString:@"여자"] ? kSexFemale : kSexMale ;
        [self.me saveInBackground];
    }];
    
    if (!self.currentLocationAddress) {
        self.currentLocationAddress = @"Locating...";
        [self getCurrentGeoLocationForUser:self.me];
    }
    
    self.ilike.text = [NSString stringWithFormat:@"%ld", self.me.likes.count];
    [self countLikesMe];
    
    
    // EDITABLE PROPERTIES
    
    BOOL editable = self.me.isMe;
    self.edit.hidden = !editable;
    self.band.hidden = !editable;
    self.nickname.userInteractionEnabled = editable;
    self.intro.userInteractionEnabled = editable;
    self.age.userInteractionEnabled = editable;
    self.sex.userInteractionEnabled = editable;
    self.gps.hidden = !editable;
    self.inbox.hidden = !editable;
    self.addMedia.hidden = !editable;
    self.mainPhoto.showsShadow = editable;
    
    self.topMargin.constant = editable ? 42 : 72;
}

- (void) countLikesMe
{
    PFQuery *query = [User query];
    [query whereKey:@"likes" containsString:self.me.objectId];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        self.likesme.text = [NSString stringWithFormat:@"%d", number];
    }];
}

- (IBAction)editProfileMedia:(id)sender
{
    __LF
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Library"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self selectProfileMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
                                                }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Camera"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self selectProfileMediaFromSource:UIImagePickerControllerSourceTypeCamera];
                                                }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil]];
    [self.parent presentViewController:alert animated:YES completion:nil];
}

- (void) selectProfileMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    MediaPicker *mediaPicker = [MediaPicker mediaPickerWithSourceType:sourceType mediaBlock:^(ProfileMediaTypes mediaType, NSData *thumbnailData, NSString *thumbnailFile, NSString *mediaFile, CGSize mediaSize, BOOL isRealMedia) {
        
        NSLog(@"I'M :%@ sAVING:%@ %@ %d %d", self.me, mediaFile, thumbnailFile, mediaType, isRealMedia);
        
        self.me.profileMedia = mediaFile;
        self.me.thumbnail = thumbnailFile;
        self.me.profileMediaType = mediaType;
        self.me.isRealMedia = isRealMedia;
        
        [self.me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error) {
                [self.mainPhoto loadMediaFromUser:self.me];
            }
            else {
                NSLog(@"ERROR:%@", error.localizedDescription);
            }
        }];
    }];
    [self.parent presentViewController:mediaPicker animated:YES completion:nil];
}

- (void)setCurrentLocationAddress:(NSString *)currentLocationAddress
{
    self.location.text = currentLocationAddress;
    _currentLocationAddress = currentLocationAddress;
}

- (void) getCurrentGeoLocationForUser:(User *)user
{
    CLGeocoder *geocoder = [CLGeocoder new];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:user.location.latitude longitude:user.location.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        __LF
         if (error) {
             NSLog(@"failed with error: %@", error);
             return;
         }
        
         if (placemarks.count > 0)
         {
             NSString *address = @"";
             
             CLPlacemark* placemark = [placemarks firstObject];
             id dic = placemark.addressDictionary;
             
             if([placemark.addressDictionary objectForKey:@"FormattedAddressLines"] != NULL)
                 address = [[dic objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             else
                 address = @"Address Not founded";
             
             self.currentLocationAddress = address;
         }
         else {
             self.currentLocationAddress = @"Not Found";
         }
     }];
}

- (IBAction)addMedia:(id)sender {
    __LF
    if ([self.parent respondsToSelector:@selector(addMedia)]) {
        [self.parent addMedia];
    }
}

- (IBAction)gotoInbox:(id)sender {
    [AppDelegate toggleMenu];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AppDelegate toggleMenuWithScreenID:@"InBox"];
    });
}

@end


@interface ProfileMediaCell :UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *delete;
@property (weak, nonatomic) IBOutlet MediaView *thumbnail;
@property (weak, nonatomic) ProfileMain* parent;
@property (weak, nonatomic) UserMedia *media;
@property (nonatomic) BOOL editable;
@end

@implementation ProfileMediaCell

- (IBAction)actionOnThumbnail:(UIButton *)sender {
    __LF
}

- (void)awakeFromNib
{
    __LF
}

- (void)setEditable:(BOOL)editable
{
    _editable = editable;
    self.delete.hidden = !editable;
}

- (IBAction)deleteMedia:(id)sender {
    __LF
    [self.parent removeMedia:self.media row:self.tag];
}

- (void)setMedia:(UserMedia *)media
{
    _media = media;

    [self.thumbnail loadMediaFromUserMedia:media animated:YES];
}

@end

@interface AddMediaCell : UICollectionViewCell
@property (nonatomic, weak) ProfileMain* parent;
@property (nonatomic, weak) User *user;
@end

@implementation AddMediaCell

- (IBAction)addMedia:(UIButton *)sender {
    __LF
    [self.parent addMedia];
}

@end


#pragma ProfileMain


@interface ProfileMain ()
@property (nonatomic, strong) User *me;
@property (nonatomic) BOOL editable;
@end

@implementation ProfileMain

- (void)awakeFromNib
{
    self.me = [User me];
    if (!self.me.media) {
        self.me.media = [NSMutableArray array];
        [self.me saveInBackground];
    }
}

- (void)setMe:(User *)user
{
    _me = user;
    self.editable = user.isMe;
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
    [super viewDidLoad];
    [self setupTransparentNavigationBar];
    [self setCellSpacing];
    [self setupBackgroundImageView];
    [self setupTapGestureRecognizerForExit];
}

- (void) setupTapGestureRecognizerForExit
{
    if (self.editable)
        return;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmissProfile)];
    [self.view addGestureRecognizer:tap];
}

- (void) dissmissProfile
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) setupTransparentNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

- (void) setupBackgroundImageView
{
    UIImageView *backgroundImageView = [UIImageView new];
    backgroundImageView.frame = self.collectionView.bounds;
    
    backgroundImageView.image = [UIImage imageNamed:@"bg"];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.collectionView.backgroundView = backgroundImageView;
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
        [view sayHiFromUser:self.me parent:self];
        return view;
    }
    else {
        return [UICollectionReusableView new];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.me.media.count + self.editable;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = self.me.media.count;
    
    if (count == indexPath.row && self.editable) {
        AddMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddMedia" forIndexPath:indexPath];
        cell.parent = self;
        cell.user = self.me;
        return cell;
    }
    else {
        ProfileMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileMedia" forIndexPath:indexPath];
        cell.parent = self;
        cell.tag = indexPath.row;
        cell.media = [self.me.media objectAtIndex:indexPath.row];
        cell.editable = self.editable;
        return cell;
    }
}

- (void) removeMedia:(UserMedia*)media row:(NSInteger)row
{
    if (!self.editable) {
        NSLog(@"ERROR: Cannot remove other's media");
        return;
    }
    
    [media deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error && succeeded) {
            [self.collectionView performBatchUpdates:^{
                [self.me removeObjectsInArray:@[media] forKey:@"media"];
                [self.me saveInBackground];
                [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
            } completion:^(BOOL finished) {
            }];
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    }];
}

- (void) addMedia {
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
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) selectMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    MediaPicker *mediaPicker = [MediaPicker mediaPickerWithSourceType:sourceType mediaBlock:^(ProfileMediaTypes mediaType, NSData *thumbnailData, NSString *thumbnailFile, NSString *mediaFile, CGSize mediaSize, BOOL isRealMedia) {
        UserMedia *media = [UserMedia object];
        media.mediaSize = mediaSize;
        media.mediaFile = mediaFile;
        media.thumbailFile = thumbnailFile;
        media.mediaType = mediaType;
        media.userId = self.me.objectId;
        media.isRealMedia = isRealMedia;
        
        [self.me addUniqueObject:media forKey:@"media"];
        [self.me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error) {
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.me.media.count-self.editable inSection:0]]];
                } completion:nil];
            }
            else {
                NSLog(@"ERROR:%@", error.localizedDescription);
            }
        }];
    }];
    [self presentViewController:mediaPicker animated:YES completion:nil];
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


