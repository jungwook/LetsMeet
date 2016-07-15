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
#import "UIColor+LightAndDark.h"
#import "PageSelectionView.h"
#import "UserMap.h"

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
@property (nonatomic, readonly) BOOL editable;
@property (strong, nonatomic, readonly) UIImage* backgroundImage;
@property (strong, nonatomic, readonly) UIColor* backgroundColor;
@property (strong, nonatomic) UserMap *map;
@property (strong, nonatomic) UserMediaLikesCollection* mediaCollection;
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
    __LF
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UserLikeHandler handler = ^(User* user) {
        [self showProfileForUser:user];
    };

    self.mediaCollection = [UserMediaLikesCollection UserMediaLikesCollectionOnViewController:self];
    self.mediaCollection.userLikeHandler = handler;
    
    self.map = [UserMap new];
    self.map.userInteractionEnabled = NO;
    
    [self.page addButtonWithTitle:@"User photos" view:self.mediaCollection];
    [self.page setBarHeight:44];
    [self.page addButtonWithTitle:@"Location" view:self.map];

    [self setAndInitializeWithUser:self.user];
    [self setShadowOnViews];
    [self setupTapGestureRecognizerForExit];
}

- (NSArray *)collectionMedia
{
    return self.user.media;
}

- (NSArray *)collectionLiked
{
    return self.liked;
}

- (NSArray *)collectionLikes
{
    return self.user.likes;
}

- (void) setAndInitializeWithUser:(User *)user
{
    _user = user ? user : [User me];
    
    [self.user fetched:^{
        // Media collection user
        [self.mediaCollection initializeCollectionWithDelegate:self];
        [self processUserLikedForUser:self.user];           
        
        [self.mediaCollection setEditable:self.editable];
        
        // Map information
        [self.map setUser:self.user];
        
        // basic information
        self.nickname.text = self.user.nickname;
        self.intro.text = self.user.intro;
        self.age.text = self.user.age;
        self.sex.text = self.user.sexString;
        
        // setup for likes and liked and like heart
        [self setupLikeBarButtonItem];
        [self setupLikeBarButtonItemState:[[User me].likes containsObject:self.user]];
        
        [self.photo loadMediaFromUser:self.user animated:NO];
        [self.photo setIsCircle:YES];
        [self.photo setShowsBorder:YES];
        
        [self setAmbiantImageAndColorsToUserPreference];
        
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
            [self setAmbiantImageAndColorsToUserPreference];
            [self.user saveInBackground];
        }];
    }];
}

- (void) processUserLikedForUser:(User*)user
{
    [self findAllLikedByUser:user inBackground:^(NSArray<User *> *users) {
        self.liked = users;
        [self.mediaCollection collectionRefreshLiked];
//        [self.mediaCollection collectionRefreshLikes];
    }];
}

- (void)setLiked:(NSArray *)liked
{
    _liked = liked;
    self.likedLB.text = [NSString stringWithFormat:@"%ld", liked.count];
    self.likesLB.text = [NSString stringWithFormat:@"%ld", self.user.likes.count];
}

typedef void(^UsersBlock)(NSArray<User*>* users);
- (void) findAllLikedByUser:(User*)user inBackground:(UsersBlock)block
{
    PFQuery *query = [User query];
    [query whereKey:@"likes" containsAllObjectsInArray:@[user]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (block) {
            block(objects);
        }
    }];
}

- (void) likeUser:(UIButton *)sender {
    User *me = [User me];
    
    if ([me.likes containsObject:self.user]) {
        [me removeObject:self.user forKey:@"likes"];
        sender.selected = NO;
    }
    else {
        [me addUniqueObject:self.user forKey:@"likes"];
        sender.selected = YES;
    }
    [me saved:^{
        [self processUserLikedForUser:self.user];
    }];
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
        
        UIBarButtonItem *likebbi = [[UIBarButtonItem alloc] initWithCustomView:but];
        [likebbi setTintColor:[UIColor blueColor]];
        [self.navigationItem setRightBarButtonItem:likebbi];
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
    [self setAmbiantImageAndColorsToUserPreference];
    [self.mediaCollection reloadData];
}

- (void) setAmbiantImageAndColorsToUserPreference
{
    [self.navigationController.navigationBar setTintColor:self.backgroundColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName:self.backgroundColor,
                                                                      NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightBold]
                                                                      }];
    
    [self setBackgroundViewImage:self.backgroundImage];
    [self.page setTextColor:self.backgroundColor];
    [self.mediaCollection setCommentColor:self.backgroundColor.lighterColor];
    
    [self.view setNeedsDisplay];
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

- (IBAction)editBackgroundMedia:(id)sender {
    __LF
    
}

- (IBAction)editProfileMedia:(id)sender
{
    __LF
    MediaPickerMediaInfoBlock handler = ^(ProfileMediaTypes mediaType,
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
            [self.user saved:^{
                [self.photo loadMediaFromUser:self.user animated:NO];
            }];
        }
        else {
            NSLog(@"ERROR: Cannot change other user profile");
        }
    };
    
    [MediaPicker addMediaOnViewController:self withMediaInfoHandler:handler];
}

- (void)collectionAddMedia
{
    __LF
    MediaPickerUserMediaBlock handler = ^(UserMedia *media) {
        if (self.editable) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"JUST 1 SEC" message:@"enter comment for your media" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:nil];
            [alert addAction:[UIAlertAction actionWithTitle:@"SAVE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                media.userId = self.user.objectId;
                media.comment = [alert.textFields firstObject].text;
                
                NSUInteger index = self.user.media.count;
                [self.user addUniqueObject:media forKey:@"media"];
                [self.user saved:^{
                    [self.mediaCollection collectionMediaAddedAtIndex:index];
                }];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"Add media cancelled");
            }]];
            alert.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            NSLog(@"ERROR: Cannot add on other user media.");
        }
    };
    [MediaPicker addMediaOnViewController:self withUserMediaHandler:handler];
}

- (void)collectionRemoveMedia:(UserMedia *)media
{
    __LF
    
    if (!self.editable) {
        NSLog(@"ERROR: Cannot remove other's media");
    }
    else {
        
        [media deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error && succeeded) {
                NSUInteger index = [self.user.media indexOfObject:media];
                [self.user removeObjectsInArray:@[media] forKey:@"media"];
                [self.user saveInBackground];
                [self.mediaCollection collectionMediaRemovedAtIndex:index];
            }
            else {
                NSLog(@"ERROR:%@", error.localizedDescription);
            }
        }];
    }
}

- (void)collectionEditCommentOnMedia:(UserMedia *)media
{
    __LF
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"JUST 1 SEC" message:@"enter comment for your media" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = media.comment;
        textField.placeholder = @"enter a comment";
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"SAVE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *newcomment = [alert.textFields firstObject].text;
        media.comment = newcomment;
        NSUInteger index = [self.user.media indexOfObject:media];
        [media saved:^{
            [self.mediaCollection collectionCommentEditedAtIndex:index];
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"edit comment cancelled");
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
