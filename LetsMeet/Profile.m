//
//  Profile.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 5..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

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
@property (weak, nonatomic) IBOutlet UIView *photoView;
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
    NSLog(@"Image to set:%@, %ld", image, image.imageOrientation);
    self.photoHeight = 320.0f * image.size.height / image.size.width;
    
//    UIImage *scaledImage = scaleImage(image, CGSizeMake(320.0f, self.photoHeight));
    
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.imageView setImage:image];
    [self.tableView reloadData];
}

- (IBAction)editPhoto:(id)sender {
    [ImagePicker proceedWithParentViewController:self photoSelectedBlock:^(id data, BulletTypes type, NSString *sizeString, NSURL *url) {
        if (type == kBulletTypePhoto) {
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
        else if (type == kBulletTypeVideo) {
            self.me.profileMediaType = kProfileMediaVideo;

            [self setPhoto:[UIImage imageWithData:data]];
            
            [CachedFile saveData:data named:@"profile.jpg" inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
                self.me.originalPhoto = file;
                self.me.profilePhoto = file;
                [self.me saveInBackground];
            } progressBlock:nil];
            
            AVURLAsset *asset = [AVURLAsset assetWithURL:url];
            NSURL *fileURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"profile.mp4"];
            
            __block NSData *assetData = nil;
            
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset640x480];
            exportSession.shouldOptimizeForNetworkUse = YES;
            exportSession.outputURL = fileURL;
            exportSession.outputFileType = AVFileTypeMPEG4;
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                assetData = [NSData dataWithContentsOfURL:fileURL];
                [CachedFile saveData:assetData named:@"profile.mp4" inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
                    self.me.profileVideo = file;
                    [self.me saveInBackground];
                } progressBlock:^(int percentDone) {
                    printf("V>>");
                }];
            }];
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
