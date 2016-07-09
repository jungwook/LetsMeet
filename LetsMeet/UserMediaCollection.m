//
//  UserMediaCollection.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserMediaCollection.h"
#import "MediaViewer.h"
#import "MediaPicker.h"

#define sUSERMEDIACELL @"UserMediaCell"
#define sADDUSERMEDIACELL @"AddUserMediaCell"
#define kNumCellsPerRow 3

@class UserMediaCollection;

@interface AddUserMediaCell : UICollectionViewCell
@property (weak, nonatomic) UserMediaCollection* parent;
@property (strong, nonatomic) UIButton* add;
@property (strong, nonatomic) UILabel* addMedia;
@end

@implementation AddUserMediaCell


- (instancetype)initWithFrame:(CGRect)frame
{
    __LF
    self = [super initWithFrame:frame];
    if (self) {
        self.add = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.add setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [self.add addTarget:self action:@selector(addMedia:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.add];
        
        self.addMedia = [UILabel new];
        self.addMedia.text = @"add media";
        self.addMedia.textAlignment = NSTextAlignmentCenter;
        self.addMedia.font = [UIFont boldSystemFontOfSize:12];
        self.addMedia.textColor = [UIColor whiteColor];
        [self addSubview:self.addMedia];
        
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 1.0f;
    }
    return self;
}

- (void)layoutSubviews
{
    const CGFloat size = 25, height = 21, w = self.bounds.size.width, h = self.bounds.size.height;
    
    self.add.frame = CGRectMake((w-size)/2, (h-(size+height))/2, size, size);
    self.addMedia.frame = CGRectMake(0, (h-(size+height))/2+size, w, height);
}

- (void)addMedia:(id)sender {
    [self.parent addMedia];
}

@end


@interface UserMediaCell : UICollectionViewCell
@property (strong, nonatomic) UIButton *delete;
@property (strong, nonatomic) MediaView *photo;

@property (strong, nonatomic) UserMedia *media;
@property (strong, nonatomic) id userId;
@property (weak, nonatomic) UserMediaCollection *parent;
@property (nonatomic) BOOL editable;
@end

@implementation UserMediaCell

-(void)awakeFromNib
{
    __LF
}

- (instancetype)initWithFrame:(CGRect)frame
{
    __LF
    self = [super initWithFrame:frame];
    if (self) {
        self.delete = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.delete setImage:[UIImage imageNamed:@"trash"] forState:UIControlStateNormal];
        [self.delete addTarget:self action:@selector(removeMedia:) forControlEvents:UIControlEventTouchUpInside];
        
        self.delete.layer.shadowOffset = CGSizeZero;
        self.delete.layer.shadowColor = [UIColor blackColor].CGColor;
        self.delete.layer.shadowRadius = 2.0f;
        self.delete.layer.shadowOpacity = 0.7f;

        self.photo = [MediaView new];
        [self addSubview:self.photo];
        [self addSubview:self.delete];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 1.0f;
        self.delete.hidden = YES;
        self.delete.alpha = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    const CGFloat offset = 4;
    self.photo.frame = CGRectMake(-offset, -offset, self.bounds.size.width+2*offset, self.bounds.size.height+2*offset);
    self.delete.frame = CGRectMake(4, 4, 20, 20);
}

- (void)setEditable:(BOOL)editable
{
    _editable = editable;
}

- (void)setMedia:(UserMedia *)media
{
    _media = media;
    [self.photo setImage:nil];
    [self.photo loadMediaFromUserMedia:media completion:^(NSData *data, NSError *error, BOOL fromCache) {
        [[self.parent visibleCells] enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UserMediaCell class]]) {
                UserMediaCell *cell = (UserMediaCell*) obj;
                if ([cell.media.objectId isEqualToString:media.objectId]) {
                    *stop = YES;
                    [cell.photo setImage:[UIImage imageWithData:data]];
                    [self showDeleteButton:self.editable];
                }
            }
        }];
    }];
}

- (void) showDeleteButton:(BOOL)show
{
    if (show) {
        self.delete.alpha = 0.0;
        self.delete.hidden = !show;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.delete.alpha = 0.8;
            }];
        });
    }
    else {
        self.delete.hidden = show;
    }
}

- (void)removeMedia:(UIButton *)sender {
    [self.parent removeMedia:self.media row:self.tag];
}

@end

@interface UserMediaCollection()
@property (nonatomic, strong) UICollectionViewFlowLayout *flow;
@property (weak, nonatomic) UIViewController *viewController;
@end

@implementation UserMediaCollection

+ (instancetype)userMediaCollectionOnViewController:(UIViewController *)viewController
{
    return [[UserMediaCollection alloc] initWithViewController:viewController];
}

- (instancetype) initWithViewController:(UIViewController *)viewController
{
    self.flow = [UICollectionViewFlowLayout new];
    self.flow.minimumLineSpacing = 2;
    self.flow.minimumInteritemSpacing = 2;
    self.flow.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    
    self = [super initWithFrame:CGRectMake(0, 0, 1, 1) collectionViewLayout:self.flow];
    if (self) {
        self.viewController = viewController;
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (void) initialize
{
    [self registerClass:[UserMediaCell class] forCellWithReuseIdentifier:sUSERMEDIACELL];
    [self registerClass:[AddUserMediaCell class] forCellWithReuseIdentifier:sADDUSERMEDIACELL];
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.alwaysBounceVertical = YES;
    _user = [User me];
}

- (void) setUser:(User *)user
{
    __LF
    _user = user;
    [self.user allMediaLoaded:^{
        self.delegate = self;
        self.dataSource = self;
        [self reloadData];
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    __LF
    return self.user.media.count + self.user.isMe;
}

CGFloat ___cellWidth(UICollectionView* cv, UICollectionViewFlowLayout *flowLayout, CGFloat cpr)
{
    return (CGRectGetWidth(cv.bounds) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (cpr - 1))/cpr;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    CGFloat cellWidth = 0, cellHeight = 0;
    cellWidth = cellHeight = ___cellWidth(collectionView, (UICollectionViewFlowLayout*) collectionViewLayout, kNumCellsPerRow);
    
    return CGSizeMake( MAX(cellWidth, 10), MAX(cellHeight, 10));
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __LF
    
    NSUInteger row = indexPath.row;
    
    if (row == self.user.media.count) {
        // This can only be the Add More Cell;
        AddUserMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:sADDUSERMEDIACELL forIndexPath:indexPath];
        cell.backgroundColor = [UIColor darkGrayColor];
        cell.tag = row;
        cell.parent = self;
        return cell;
    }
    else {
        UserMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:sUSERMEDIACELL forIndexPath:indexPath];
        cell.parent = self;
        cell.editable = self.user.isMe;
        cell.media = [self.user.media objectAtIndex:row];
        cell.tag = row;
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.user.media.count) {
        // This can only happen to addMoreMedia
        [self addMedia];
    }
}

- (void)addMedia
{
 __LF
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
                    [self performBatchUpdates:^{
                        [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.user.media.count-self.user.isMe inSection:0]]];
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
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

- (void) addUserMediaFromSource:(UIImagePickerControllerSourceType)sourceType mediaBlock:(MediaPickerMediaBlock)handler
{
    MediaPicker *mediaPicker = [MediaPicker mediaPickerWithSourceType:sourceType mediaBlock:handler];
    [self.viewController presentViewController:mediaPicker animated:YES completion:nil];
}

- (void) removeMedia:(UserMedia*)media row:(NSInteger)row
{
    if (!self.user.isMe) {
        NSLog(@"ERROR: Cannot remove other's media");
        return;
    }
    
    [media deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error && succeeded) {
            [self performBatchUpdates:^{
                [self.user removeObjectsInArray:@[media] forKey:@"media"];
                [self.user saveInBackground];
                [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
            } completion:nil];
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
