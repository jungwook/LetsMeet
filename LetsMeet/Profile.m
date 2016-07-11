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
#import "UIImage+AverageColor.h"
#import "PageSelectionView.h"
#import "UserMap.h"
#import "UserMediaCollection.h"

@interface Profile ()
@property (weak, nonatomic) IBOutlet PageSelectionView *page;
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
@property (weak, nonatomic) User *user;
@property (nonatomic, readonly) BOOL editable;
@property (strong, nonatomic, readonly) UIImage* backgroundImage;
@property (strong, nonatomic, readonly) UIColor* backgroundColor;
@property (strong, nonatomic) UserMap *map;
@property (strong, nonatomic) UserMediaCollection* mediaCollection;
@property (strong, nonatomic) NSArray *liked;
@property (strong, nonatomic) NSArray *likes;
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
    __LF
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UserLikeHandler handler = ^(User* user) {
        [self showProfileForUser:user];
    };

    self.mediaCollection = [UserMediaCollection userMediaCollectionOnViewController:self];
    self.mediaCollection.userLikeHandler = handler;
    
    self.map = [UserMap new];
    self.map.userInteractionEnabled = NO;
    
    [self.page addButtonWithTitle:@"User photos" view:self.mediaCollection];
    [self.page setBarHeight:44];
    [self.page addButtonWithTitle:@"Location" view:self.map];

    [self setUser:self.user];
    [self setShadowOnViews];
    [self setupTapGestureRecognizerForExit];
}

- (void) setUser:(User *)user
{
    _user = user ? user : [User me];

    // basic information
    self.nickname.text = self.user.nickname;
    self.intro.text = self.user.intro;
    self.age.text = self.user.age;
    self.sex.text = self.user.sexString;
    
    // setup for likes and liked and like heart
    [self setupLikeBarButtonItem];
    [self setupLikeBarButtonItemState:[[User me].likes containsObject:self.user.objectId]];
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

    [self.mediaCollection setUser:self.user];
    [self.mediaCollection setCommentColor:[UIColor redColor]];
    [self.map setUser:self.user];
}

- (void) setupLikeBarButtonItemState:(BOOL)liked
{
    UIButton *likeButtonWithinBarButtonItem = self.navigationItem.rightBarButtonItem.customView;
    likeButtonWithinBarButtonItem.selected = liked;
}

- (void) setupLikeBarButtonItem
{
    if (!self.user.isMe && !self.navigationItem.rightBarButtonItem) {
        const CGFloat size = 30;
        UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        [but setBackgroundImage:[UIImage imageNamed:@"like grey"] forState:UIControlStateNormal];
        [but setBackgroundImage:[UIImage imageNamed:@"like red"] forState:UIControlStateSelected];
        [but addTarget:self action:@selector(likeUser:) forControlEvents:UIControlEventTouchDown];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:but]];
    }
}

- (UIImage *) backgroundImage
{
    return self.user.sex == kSexMale ? [UIImage imageNamed:@"background"] : [UIImage imageNamed:@"background2"];
}

- (UIColor *) backgroundColor
{
    return self.backgroundImage.averageColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:self.backgroundColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName:self.backgroundColor,
                                                                      NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightBold]
                                                                      }];
}

- (void) setupTapGestureRecognizerForExit
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void) setShadowOnViews
{
    [[self.backgroundView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UITextField class]]) {
            setShadowOnView(view, 2.5f, 0.8f);
        }
    }];
}

- (void) setupLikes
{
    [self loadAllLiked];
    [self loadAllLikes];
}

- (void)loadAllLikes
{
    PFQuery *query = [User query];
    [query whereKey:@"objectId" containedIn:self.user.likes];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.likes = objects;
        [self.mediaCollection setLikes:objects];
        self.likesLB.text = [NSString stringWithFormat:@"%ld", self.likes.count];
    }];
}

- (void) loadAllLiked
{
    PFQuery *query = [User query];
    [query whereKey:@"likes" containsString:self.user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.liked = objects;
        [self.mediaCollection setLiked:objects];
        self.likedLB.text = [NSString stringWithFormat:@"%ld", self.liked.count];
    }];
}

- (void) setBackgroundViewImage:(UIImage*)image
{
    self.backgroundView.layer.contents = (id) image.CGImage;
    self.backgroundView.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.backgroundView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dismissModalPresentation
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void) likeUser:(UIButton *)sender {
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

- (IBAction)editBackgroundMedia:(id)sender {
    __LF
    
}

- (IBAction)editProfileMedia:(id)sender
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

@end
