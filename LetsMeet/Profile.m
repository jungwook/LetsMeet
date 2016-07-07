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
#import "MediaPicker.h"
#import "ListPicker.h"

@implementation UIImage(AverageColor)

- (UIColor *)averageColor {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}
@end

typedef enum {
    kSectionMedia = 0,
    kSectionLocation,
    kSectionLikes,
    kSectionLiked
} ProfileMediaSections;

@interface AddMoreCell : UICollectionViewCell
@property (weak, nonatomic) Profile* parent;
@end

@implementation AddMoreCell

- (IBAction)addMedia:(id)sender {
    [self.parent addMedia];
}

@end

@interface LikesCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *photo;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (nonatomic) ProfileMediaSections section;
@property (nonatomic) BOOL editable;
@property (weak, nonatomic) Profile* parent;
@property (weak, nonatomic) id userId;
@property (strong, nonatomic, readonly) User* user;
@property (nonatomic) BOOL likes;
@end

@implementation LikesCell

- (void)awakeFromNib
{
    self.nickname.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f].CGColor;
    self.nickname.layer.shadowOffset = CGSizeZero;
    self.nickname.layer.shadowRadius = 2.5f;
    self.nickname.layer.shadowOpacity = 0.8f;
}

- (IBAction)gotoProfile:(id)sender {
    __LF
    
    [self.parent showProfileForUser:self.user];
}

- (void)setUserId:(id)userId
{
    [self.photo setImage:nil forState:UIControlStateNormal];
    _userId = userId;
    _user = [User objectWithoutDataWithObjectId:userId];
    [self.user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.nickname.text = self.user.nickname;
        [S3File getDataFromFile:self.user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            [[self.parent.collectionView visibleCells] enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.tag == self.tag) {
                    *stop = YES;
                    [self.photo setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                }
            }];
        }];
    }];
}

@end


@interface MediaCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *delete;
@property (weak, nonatomic) UserMedia *media;
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (weak, nonatomic) id userId;
@property (weak, nonatomic) Profile *parent;
@property (nonatomic) ProfileMediaSections section;
@property (nonatomic) BOOL editable;
@end

@implementation MediaCell

- (void)setEditable:(BOOL)editable
{
    _editable = editable;
    self.delete.hidden = !editable;
}

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
        [self.photo loadMediaFromUser:user completion:^(NSData *data, NSError *error, BOOL fromCache) {
            [[self.parent.collectionView visibleCells] enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.tag == self.tag) {
                    *stop = YES;
                    [((MediaCell*)obj).photo setImage:[UIImage imageWithData:data]];
                }
            }];
        }];
    }];
}

- (IBAction)removeMedia:(UIButton *)sender {
    [self.parent removeMedia:self.media row:self.tag];
}

@end


@interface MapCell : UICollectionViewCell
@property (weak, nonatomic) User *user;
@property (nonatomic) ProfileMediaSections section;
@end

@implementation MapCell

- (void)setUser:(User *)user
{
    
}

@end

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
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *photoEdit;
@property (weak, nonatomic) IBOutlet UIButton *like;
@property (weak, nonatomic) User *user;
@property (nonatomic, readonly) BOOL editable;
@property (nonatomic) ProfileMediaSections section;
@property (strong, nonatomic, readonly) UIImage* backgroundImage;
@property (strong, nonatomic, readonly) UIColor* backgroundColor;

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

- (void) setUser:(User *)user
{
    _user = user ? user : [User me];

    // basic information
    self.section = kSectionMedia;
    self.nickname.text = self.user.nickname;
    self.intro.text = self.user.intro;
    self.age.text = self.user.age;
    self.sex.text = self.user.sexString;
    
    
    // setup for likes and liked and like heart
    [self.like setSelected:[[User me].likes containsObject:self.user.objectId]];
    [self setShadowOnView:self.like];
    [self setupLikes];
    
    [self.photo loadMediaFromUser:self.user];
    [self.photo setIsCircle:YES];
    [self.photo setShowsBorder:YES];
    
    [self setBackgroundViewImage:self.backgroundImage];

    [self.photoEdit setHidden:!self.user.isMe];
    [self.nickname setUserInteractionEnabled:self.user.isMe];
    [self.intro setUserInteractionEnabled:self.user.isMe];
    [self.age setUserInteractionEnabled:self.user.isMe];
    [self.sex setUserInteractionEnabled:self.user.isMe];
    [self.like setUserInteractionEnabled:!self.user.isMe];
    
    self.intro.text = self.user.intro ? self.user.intro : @"";
    [ListPicker pickerWithArray:@[@"우리 만나요!", @"애인 찾아요", @"함께 드라이브 해요", @"나쁜 친구 찾아요", @"착한 친구 찾아요", @"함께 먹으러 가요", @"술친구 찾아요"] onTextField:self.intro selection:^(id data) {
        self.user.intro = data;
        [self.user saveInBackground];
    }];
    
    self.age.text = self.user.age ? self.user.age : @"";
    [ListPicker pickerWithArray:@[@"고딩", @"20대", @"30대", @"40대", @"비밀"] onTextField:self.age selection:^(id data) {
        self.user.age = data;
        [self.user saveInBackground];
    }];
    
    self.sex.text = self.user.sexString;
    [ListPicker pickerWithArray:@[@"여자", @"남자"] onTextField:self.sex selection:^(id data) {
        self.user.sex = [data isEqualToString:@"여자"] ? kSexFemale : kSexMale ;
        [self.user saveInBackground];
    }];
}

- (void) setupLikes
{
    [self countMyLikes];
    [self countLikesMeInBackground];
}

- (UIImage *)backgroundImage
{
    return self.user.sex == kSexMale ? [UIImage imageNamed:@"background"] : [UIImage imageNamed:@"background2"];
}

- (UIColor *)backgroundColor
{
    return self.backgroundImage.averageColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUser:self.user];
    [self setCellSpacingForSelection:kSectionMedia];
    [self setupSelectionButtons];
    [self setShadowOnViews];
    [self setupTapGestureRecognizerForExit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:self.backgroundColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName:self.backgroundColor,
                                                                      NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightBold]
                                                                      }];
}

- (void) setupTapGestureRecognizerForExit
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)setShadowOnViews
{
    [[self.backgroundView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UITextField class]]) {
            [self setShadowOnView:view];
        }
    }];
}

- (void)setShadowOnView:(UIView*)view
{
    view.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f].CGColor;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.shadowRadius = 2.5f;
    view.layer.shadowOpacity = 0.8f;
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

- (void) countMyLikes
{
    self.likesLB.text = [NSString stringWithFormat:@"%ld", self.user.likes.count];
}

- (void)setLiked:(NSArray *)liked
{
    _liked = liked;
    self.likedLB.text = [NSString stringWithFormat:@"%ld", self.liked.count];
    if (self.section == kSectionLiked || self.section == kSectionLikes) {
        [self.collectionView reloadData];
    }
}

- (void) setBackgroundViewImage:(UIImage*)image
{
    self.backgroundView.layer.contents = (id) image.CGImage;
    self.backgroundView.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.backgroundView.layer.masksToBounds = YES;
}

- (void)setSection:(ProfileMediaSections)section
{
    _section = section;
    [self setCellSpacingForSelection:section];
    [self.collectionView reloadData];
}

- (void)setupSelectionButtons
{
    const CGFloat width = 80.0f;
    
    [self.selectionBar setTextColor:self.backgroundColor];
    [self.selectionBar addButtonWithTitle:@"Media" width:width];
    [self.selectionBar addButtonWithTitle:@"Location" width:width];
    [self.selectionBar addButtonWithTitle:@"Likes" width:width];
    [self.selectionBar addButtonWithTitle:@"Liked" width:width];
    [self.selectionBar setIndex:self.section];
    [self.selectionBar setHandler:^(NSInteger index) {
        self.section = (ProfileMediaSections) index;
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (self.section) {
        case kSectionMedia:
            return self.user.media.count + self.editable;
            
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
            cell.backgroundColor = self.backgroundColor;
            cell.tag = indexPath.row;
            cell.section = self.section;
            cell.user = self.user;
            return cell;
        }
        case kSectionMedia:
        {
            if (self.editable && indexPath.row == self.user.media.count) {
                AddMoreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddMoreCell" forIndexPath:indexPath];
                cell.backgroundColor = self.backgroundColor;
                cell.parent = self;
                return cell;
            }
            else {
                MediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCell" forIndexPath:indexPath];
                cell.backgroundColor = self.backgroundColor;
                cell.media = [self.user.media objectAtIndex:indexPath.row];
                cell.tag = indexPath.row;
                cell.section = self.section;
                cell.parent = self;
                cell.editable = self.editable;
                return cell;
            }
        }
        case kSectionLikes:
        {
            LikesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LikesCell" forIndexPath:indexPath];
            cell.backgroundColor = self.backgroundColor;
            cell.userId = [self.user.likes objectAtIndex:indexPath.row];
            cell.tag = indexPath.row;
            cell.section = self.section;
            cell.parent = self;
            cell.editable = self.editable;
            return cell;
        }
        case kSectionLiked:
        {
            LikesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LikesCell" forIndexPath:indexPath];
            cell.backgroundColor = self.backgroundColor;
            cell.userId = ((User*)[self.liked objectAtIndex:indexPath.row]).objectId;
            cell.tag = indexPath.row;
            cell.section = self.section;
            cell.parent = self;
            cell.editable = self.editable;
            return cell;
        }
    }
}

- (void) dismissKeyboard
{
    [[self.backgroundView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isFirstResponder) {
            [obj resignFirstResponder];
            *stop = YES;
        }
    }];
}

- (void) showProfileForUser:(User*)user
{
    Profile* main = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    [main setUser:user];
    main.navigationItem.leftBarButtonItem = nil;
    main.navigationItem.title = user.nickname;
    [self.navigationController pushViewController:main animated:YES];
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
                [self.user removeObjectsInArray:@[media] forKey:@"media"];
                [self.user saveInBackground];
                [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
            } completion:^(BOOL finished) {
            }];
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    }];
}

- (IBAction)likeUser:(UIButton *)sender {
    User *me = [User me];
    
    NSArray *likes = me.likes;
    if ([likes containsObject:self.user.objectId]) {
        [me removeObject:self.user.objectId forKey:@"likes"];
        sender.selected = NO;
    }
    else {
        [me addUniqueObject:self.user.objectId forKey:@"likes"];
        sender.selected = YES;
    }
    [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self setupLikes];
    }];
}


- (IBAction)editProfileMedia:(id)sender
{
    MediaPickerMediaBlock handler = ^(ProfileMediaTypes mediaType,
                                      NSData *thumbnailData,
                                      NSString *thumbnailFile,
                                      NSString *mediaFile,
                                      CGSize mediaSize,
                                      BOOL isRealMedia)
    {
        if (self.user.isMe) {
            self.user.profileMedia = mediaFile;
            self.user.thumbnail = thumbnailFile;
            self.user.profileMediaType = mediaType;
            self.user.isRealMedia = isRealMedia;
            
            [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!error) {
                    [self.photo loadMediaFromUser:self.user];
                }
                else {
                    NSLog(@"ERROR:%@", error.localizedDescription);
                }
            }];
        }
        else {
            NSLog(@"ERROR: Cannot change other user profile");
        }
    };
    
    [self addMediaWithHandler:handler];
}

- (void) addMedia
{
    MediaPickerMediaBlock handler = ^(ProfileMediaTypes mediaType,
                                      NSData *thumbnailData,
                                      NSString *thumbnailFile,
                                      NSString *mediaFile,
                                      CGSize mediaSize,
                                      BOOL isRealMedia)
    {
        if (self.user.isMe) {
            UserMedia *media = [UserMedia object];
            media.mediaSize = mediaSize;
            media.mediaFile = mediaFile;
            media.thumbailFile = thumbnailFile;
            media.mediaType = mediaType;
            media.userId = self.user.objectId;
            media.isRealMedia = isRealMedia;
            
            [self.user addUniqueObject:media forKey:@"media"];
            [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!error) {
                    [self.collectionView performBatchUpdates:^{
                        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.user.media.count-self.editable inSection:0]]];
                    } completion:nil];
                }
                else {
                    NSLog(@"ERROR:%@", error.localizedDescription);
                }
            }];
        }
        else {
            NSLog(@"ERROR: Cannot add on other user media.");
        }
    };
    [self addMediaWithHandler:handler];
}

- (void) addMediaWithHandler:(MediaPickerMediaBlock)handler
{
    __LF
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Library"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self addUserMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary mediaBlock:handler];
                                                }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Camera"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self addUserMediaFromSource:UIImagePickerControllerSourceTypeCamera mediaBlock:handler];
                                                }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) addUserMediaFromSource:(UIImagePickerControllerSourceType)sourceType mediaBlock:(MediaPickerMediaBlock)handler
{
    MediaPicker *mediaPicker = [MediaPicker mediaPickerWithSourceType:sourceType mediaBlock:handler];
    [self presentViewController:mediaPicker animated:YES completion:nil];
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
