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

@interface Profile ()
@property (weak, nonatomic) IBOutlet UITextField *nicknameTF;
@property (weak, nonatomic) IBOutlet UITextField *introTF;
@property (weak, nonatomic) IBOutlet UITextField *ageTF;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *sexTF;
@property (weak, nonatomic) IBOutlet UILabel *pointsLB;
@property (weak, nonatomic) IBOutlet UIButton *editPhotoBut;
@property CGFloat photoHeight;

@property (strong, nonatomic) User *me;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    circleizeView(self.editPhotoBut, 0.1f);
    
    self.nicknameTF.text = self.me.nickname;
    self.introTF.text = self.me.intro ? self.me.intro : @"";
    self.introTF.inputView = [ListPicker pickerWithArray:@[@"우리 만나요!", @"애인 찾아요", @"함께 드라이브 해요", @"나쁜 친구 찾아요", @"착한 친구 찾아요", @"맛난거 먹으러 가요", @"술친구 찾아요"] withPhotoSelectedBlock:^(id data) {
        self.introTF.text = data;
        [self.introTF resignFirstResponder];
        self.me.intro = data;
        [self.me saveInBackground];
    }];
    self.ageTF.text = self.me.age;
    self.ageTF.inputView = [ListPicker pickerWithArray:@[@"고딩", @"20대", @"30대", @"40대", @"비밀"] withPhotoSelectedBlock:^(id data) {
        self.ageTF.text = data;
        [self.ageTF resignFirstResponder];
        self.me.age = data;
        [self.me saveInBackground];
    }];
    
    self.sexTF.text = self.me.sexString;
    self.sexTF.inputView = [ListPicker pickerWithArray:@[@"여자", @"남자"] withPhotoSelectedBlock:^(id data) {
        self.sexTF.text = data;
        [self.sexTF resignFirstResponder];
        self.me.sex = [data isEqualToString:@"여자"] ? kSexFemale : kSexMale ;
        [self.me saveInBackground];
    }];
    
    [CachedFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        UIImage *image = [UIImage imageWithData:data];

        NSLog(@"IMAGE PICKED OF SIZE:%@", NSStringFromCGSize(image.size));

        [self setPhoto:image];
    } fromFile:self.me.profilePhoto];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return self.photoHeight;
    }
    else {
        return 45.0f;
    }
}

- (void)setPhoto:(UIImage*)image
{
    self.photoHeight = self.imageView.frame.size.width * image.size.height / image.size.width;
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView setImage:image];
    [self.tableView reloadData];
}

- (void) treatPhotoData:(NSData*)data type:(BulletTypes)type mediaInfo:(NSString*)sizeString url:(NSURL*)url
{
    self.me.profileMediaType = kProfileMediaPhoto;
    
    NSData *originalData = compressedImageData(data, 1024);
    NSData *profileData = compressedImageData(data, 320);
    
    [self setPhoto:[UIImage imageWithData:data]];
    
    [CachedFile saveData:originalData named:@"original.jpg" inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
        self.me.originalPhoto = file;
        [self.me saveInBackground];
    } progressBlock:nil];
    [CachedFile saveData:profileData named:@"profile.jpg" inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
        self.me.profilePhoto = file;
        [self.me saveInBackground];
    } progressBlock:nil];
}

UIImage *refit(UIImage *image, UIImageOrientation orientation)
{
    return [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:orientation];
}

- (void) treatVideoData:(NSData*)data type:(BulletTypes)type mediaInfo:(NSString*)sizeString url:(NSURL*)url
{
    self.me.profileMediaType = kProfileMediaVideo;
    
    UIImage *image = [UIImage imageWithData:data];
    NSLog(@"IMAGE:%@", image);
    data = UIImageJPEGRepresentation(image, kJPEGCompressionFull);
    [self setPhoto:image];
    
    [CachedFile saveData:data named:@"profile.jpg" inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
        self.me.originalPhoto = file;
        self.me.profilePhoto = file;
        [self.me saveInBackground];
    } progressBlock:nil];
    
    NSURL *outputURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"profile.mov"];
    
    [self convertVideoToLowQuailtyWithInputURL:url outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
    {
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
    
            NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
            NSLog(@"VIDEO SIZE:%ld", videoData.length);
            [CachedFile saveData:videoData named:@"profile.mov" inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
                self.me.profileVideo = file;
                [self.me saveInBackground];
                NSLog(@"URL:%@", file.url);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:file.url]];
                    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
                    layer.frame = self.imageView.bounds;
                    layer.masksToBounds = YES;
                    [self.imageView.layer addSublayer:layer];
                    [player play];
                });

            } progressBlock:^(int percentDone) {
                printf("V>>");
            }];
        } 
    }];
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
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
