//
//  Profile.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//
#import "AVFoundation/AVFoundation.h"
#import "AVKit/AVKit.h"
#import "Profile.h"
#import "NSMutableDictionary+Bullet.h"
#import "ListPicker.h"
#import "CachedFile.h"
#import "ImagePicker.h"
#import "MediaPlayer.h"

@interface UIImageView(animated)
- (void)setImage:(UIImage *)image animated:(BOOL)animated;
@end

@implementation UIImageView(animated)
- (void)setImage:(UIImage *)image animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self setImage:image];
            [UIView animateWithDuration:0.2 animations:^{
                self.alpha = 1.0f;
            }];
        }];
    }
    else {
        [self setImage:image];
    }
}
@end

@interface Profile ()
@property (weak, nonatomic) IBOutlet UITextField *nicknameTF;
@property (weak, nonatomic) IBOutlet UITextField *introTF;
@property (weak, nonatomic) IBOutlet UITextField *ageTF;
@property (weak, nonatomic) IBOutlet UIImageView *profileView;
@property (weak, nonatomic) IBOutlet UITextField *sexTF;
@property (weak, nonatomic) IBOutlet UILabel *pointsLB;
@property (weak, nonatomic) IBOutlet UIButton *editPhotoBut;
@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (strong, nonatomic) MediaPlayer* player;
@property CGFloat photoHeight;

@property (strong, nonatomic) User *me;
@end


@interface GradientView : UIView

@end

@implementation GradientView
+(Class) layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        ((CAGradientLayer*)self.layer).colors = [NSArray arrayWithObjects:
                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.20f].CGColor,
                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.07f].CGColor,
                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.03f].CGColor,
                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.1f].CGColor,
                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.17f].CGColor,
                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                                                nil];
        ((CAGradientLayer*)self.layer).locations = [NSArray arrayWithObjects:
                                                    [NSNumber numberWithFloat:0.0f],
                                                    [NSNumber numberWithFloat:0.1f],
                                                    [NSNumber numberWithFloat:0.13f],
                                                    [NSNumber numberWithFloat:0.3f],
                                                    [NSNumber numberWithFloat:0.6f],
                                                    [NSNumber numberWithFloat:0.83f],
                                                    [NSNumber numberWithFloat:0.9f],
                                                    [NSNumber numberWithFloat:1.0f],
                                                   nil];
        ((CAGradientLayer*)self.layer).cornerRadius = 2.0f;
        ((CAGradientLayer*)self.layer).masksToBounds = YES;
    }
    return self;
}
@end


@implementation Profile

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.me = [User me];
        self.photoHeight = 320;
    }
    return self;
}

- (void) setShadowOnView:(UIView*)view
{
    view.layer.shadowColor = [UIColor redColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(2 , 2);
    view.layer.shadowRadius = 2.0f;
    view.layer.shadowOpacity = 0.9f;
    view.layer.masksToBounds = NO;
    
    view.clipsToBounds = NO;
}

- (void)setGradient:(UIView*) myImageView;
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = myImageView.layer.bounds;
    
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[UIColor colorWithWhite:0.0f alpha:0.9f].CGColor,
                            (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
                            (id)[UIColor colorWithWhite:0.0f alpha:0.9f].CGColor,
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:0.5f],
                               [NSNumber numberWithFloat:0.7f],
                               nil];
    
    //If you want to have a border for this layer also
    gradientLayer.borderColor = [UIColor colorWithWhite:1.0f alpha:1.0f].CGColor;
    gradientLayer.borderWidth = 1;
    [myImageView.layer addSublayer:gradientLayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setGradient:self.gradientView];
    [self setShadowOnView:self.editPhotoBut];
    
    circleizeView(self.editPhotoBut, 0.1f);
    
    self.nicknameTF.text = self.me.nickname;
    
    self.introTF.text = self.me.intro ? self.me.intro : @"";
    [ListPicker pickerWithArray:@[@"우리 만나요!", @"애인 찾아요", @"함께 드라이브 해요", @"나쁜 친구 찾아요", @"착한 친구 찾아요", @"함께 먹으러 가요", @"술친구 찾아요"] onTextField:self.introTF selection:^(id data) {
        self.me.intro = data;
        [self.me saveInBackground];
    }];
    
    self.ageTF.text = self.me.age;
    [ListPicker pickerWithArray:@[@"고딩", @"20대", @"30대", @"40대", @"비밀"] onTextField:self.ageTF selection:^(id data) {
        self.me.age = data;
        [self.me saveInBackground];
    }];
    
    self.sexTF.text = self.me.sexString;
    [ListPicker pickerWithArray:@[@"여자", @"남자"] onTextField:self.sexTF selection:^(id data) {
        self.me.sex = [data isEqualToString:@"여자"] ? kSexFemale : kSexMale ;
        [self.me saveInBackground];
    }];
    
    [CachedFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        UIImage *image = [UIImage imageWithData:data];
        [self setPhoto:image];
        
        self.player = [MediaPlayer playerWithURL: (self.me.profileMediaType == kProfileMediaVideo) ?[NSURL URLWithString:self.me.profileVideo.url] : nil onView:self.profileView];
    } fromFile:self.me.profilePhoto];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return MIN(self.photoHeight, 400.0f);
    }
    else {
        return 45.0f;
    }
}

- (void)setPhoto:(UIImage*)image
{
    self.photoHeight = image.size.width ? self.profileView.frame.size.width * image.size.height / image.size.width + 20 : 400;
    
    [self.profileView setImage:image animated:YES];
    [self.tableView reloadData];
}

- (void) treatPhotoData:(NSData*)data type:(BulletTypes)type mediaInfo:(NSString*)sizeString url:(NSURL*)url
{
    [self.player setURL:nil];
    [self setPhoto:[UIImage imageWithData:data]];
    
    [CachedFile saveData:data named:@"original.jpg" inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
        self.me.originalPhoto = file;
        self.me.profilePhoto = file;
        self.me.profileMediaType = kProfileMediaPhoto;
        self.me.profileVideo = nil;
        [self.me saveInBackground];
    } progressBlock:nil];
}

UIImage *refit(UIImage *image, UIImageOrientation orientation)
{
    return [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:orientation];
}

- (void) treatVideoData:(NSData*)data type:(BulletTypes)type mediaInfo:(NSString*)sizeString url:(NSURL*)url
{
    UIImage *image = [UIImage imageWithData:data];
    [self setPhoto:image];
    
    [CachedFile saveData:data named:@"profile.jpg" inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
        self.me.profileMediaType = kProfileMediaVideo;
        self.me.originalPhoto = file;
        self.me.profilePhoto = file;
        [self.me saveInBackground];
    } progressBlock:nil];
    
    NSURL *outputURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"profile_video.mov"];
    
    [self convertVideoToLowQuailtyWithInputURL:url outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
    {
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            [self.player setURL:url];
    
            NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
            [CachedFile saveVideoData:videoData named:@"profile_video.mov" inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
                self.me.profileVideo = file;
                self.me.profileMediaType = kProfileMediaVideo;
                [self.me saveInBackground];
            } progressBlock:^(int percentDone) {
                printf("V>>");
            }];
            NSLog(@"ReACHER 1");
        }
    }];
    NSLog(@"ReACHER 2");
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL handler:(void (^)(AVAssetExportSession*))handler {
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset640x480];
    exportSession.outputURL = outputURL;
    exportSession.fileLengthLimit = 3000000;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        handler(exportSession);
    }];
}
 
- (IBAction)editPhoto:(id)sender {
    [ImagePicker proceedWithParentViewController:self photoSelectedBlock:^(id data, BulletTypes type, NSString *sizeString, NSURL *url) {
        if (type == kBulletTypePhoto) {
            [self treatPhotoData:data type:type mediaInfo:sizeString url:url];
        }
        else if (type == kBulletTypeVideo) {
            [self treatVideoData:data type:type mediaInfo:sizeString url:url];
        }
    } cancelBlock:nil];
}

- (IBAction)chargePoints:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
