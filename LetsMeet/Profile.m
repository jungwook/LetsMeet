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
#import "MediaView.h"
#import "S3File.h"

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
@property (weak, nonatomic) IBOutlet UITextField *sexTF;
@property (weak, nonatomic) IBOutlet UILabel *pointsLB;
@property (weak, nonatomic) IBOutlet UIButton *editPhotoBut;
@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet MediaView *mediaView;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self setShadowOnView:self.editPhotoBut];
    self.editPhotoBut.exclusiveTouch = YES;
    self.nicknameTF.text = self.me.nickname;
    self.gradientView.hidden = YES;
    
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
    
    [self.mediaView setMediaFromUser:self.me frameBlock:^(CGSize size) {
        NSLog(@"REFRAMING:%@", NSStringFromCGSize(size));
        self.photoHeight = size.width ? self.mediaView.frame.size.width * size.height / size.width + 20 : 400;
        [self.tableView reloadData];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return MIN(self.photoHeight, 500);
    }
    else {
        return 45.0f;
    }
}

UIImage *refit(UIImage *image, UIImageOrientation orientation)
{
    return [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:orientation];
}

- (void) treatVideoOfType:(BulletTypes)type url:(NSURL*)url
{
    
    NSURL *outputURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"profile_video.mov"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"PLAYING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        [self.mediaView setPlayerItemURL:url];
    });
    [self convertVideoToLowQuailtyWithInputURL:url outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
    {
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
            
            [S3File saveData:videoData named:@"profile.mov" completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"SAVED FILENAME:%@", file);
                    self.me.profileMediaType = kProfileMediaVideo;
                    self.me.profileMedia = file;
                    [self.me saveInBackground];
                    
                    // DELETING TEMP FILE AFTER UPLOAD
                    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
                }
                else {
                    NSLog(@"ERROR:%@", error.localizedDescription);
                }
            } progressBlock:^(int percentDone) {
                NSLog(@"Saving Progress:%d", percentDone);
            }];
        }
    }];
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL handler:(void (^)(AVAssetExportSession*))handler {
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset640x480];
    exportSession.outputURL = outputURL;
//    exportSession.fileLengthLimit = 3000000;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        handler(exportSession);
    }];
}
 
- (IBAction)editPhoto:(id)sender {
    [self.mediaView pause];
    
    [ImagePicker proceedWithParentViewController:self photoSelectedBlock:^(id data, BulletTypes type, NSString *sizeString, NSURL *url) {
        if (type == kBulletTypePhoto) {
            [S3File saveData:data named:@"profile.jpg" completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
                if (succeeded) {
                    self.me.profileMedia = file;
                    self.me.profileMediaType = kProfileMediaPhoto;
                    [self.me saveInBackground];
                    [self.mediaView setMediaFromUser:self.me];
                }
                else {
                    NSLog(@"ERROR:%@", error.localizedDescription);
                }
            } progressBlock:^(int percentDone) {
                NSLog(@"Saving Progress:%d", percentDone);
            }];
        }
        else if (type == kBulletTypeVideo) {
            [self treatVideoOfType:type url:url];
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
