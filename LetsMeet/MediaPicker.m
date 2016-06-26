//
//  MediaPicker.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MediaPicker.h"
#import "S3File.h"
@import MobileCoreServices;

@interface MediaPicker ()
@property (nonatomic, strong) MediaPickerBlock completionBlock;
@end

@implementation MediaPicker

+(instancetype)mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType completion:(MediaPickerBlock)block
{
    return [[MediaPicker alloc] initWithSourceType:sourceType completionBlock:block];
}

- (instancetype) initWithSourceType:(UIImagePickerControllerSourceType)sourceType completionBlock:(MediaPickerBlock)block
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.allowsEditing = YES;
        self.videoMaximumDuration = 10;
        self.sourceType = sourceType;
        self.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.completionBlock = block;
    }
    return self;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    NSURL *url = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        [self handlePhoto:info url:url source:picker.sourceType];
    }
    else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)== kCFCompareEqualTo) {
        [self handleVideo:info url:url source:picker.sourceType];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) handlePhoto:(NSDictionary<NSString*, id>*)info url:(NSURL*)url source:(UIImagePickerControllerSourceType)sourceType
{
    UIImage *image = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSData *thumbnailData = compressedImageData(imageData, kThumbnailWidth);
    
    NSString *thumbnailFile = [S3File saveImageData:thumbnailData completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        if (succeeded) {
            
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    } progress:nil];
    
    NSString *mediaFile = [S3File saveImageData:imageData completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        if (succeeded) {
            
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    } progress:nil];
    
    NSLog(@"source type:%ld", sourceType);
    
    Bullet* bullet = [Bullet bulletWithPhoto:mediaFile thumbnail:thumbnailFile mediaSize:image.size realMedia:(sourceType == UIImagePickerControllerSourceTypeCamera)];
    if (self.completionBlock) {
        self.completionBlock(bullet);
    }
}

- (void) handleVideo:(NSDictionary<NSString*, id>*)info url:(NSURL*)url source:(UIImagePickerControllerSourceType)sourceType
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    UIImage *thumbnailImage = [self thumbnailFromVideoAsset:asset source:sourceType];
    NSData *thumbnailData = compressedImageData(UIImageJPEGRepresentation(thumbnailImage, kJPEGCompressionFull), kThumbnailWidth);
    
    NSString *thumbnailFile = [S3File saveImageData:thumbnailData completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"UPLOADED THUMBNAIL TO:%@", file);
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    } progress:nil];
    
    NSString *tempId = randomObjectId();
    NSURL *outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:tempId]];
    
    __block NSString *mediaFile = nil;
    
    [self convertVideoToLowQuailtyWithInputURL:url outputURL:outputURL handler:^(AVAssetExportSession *exportSession) {
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
            
            mediaFile = [S3File saveMovieData:videoData completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"source type:%ld", sourceType);
                    
                    Bullet* bullet = [Bullet bulletWithVideo:mediaFile thumbnail:thumbnailFile mediaSize:thumbnailImage.size realMedia:(sourceType == UIImagePickerControllerSourceTypeCamera)];
                    NSLog(@"UPLOADED VIDEO TO:%@ %@", file, bullet);
                    if (self.completionBlock) {
                        self.completionBlock(bullet);
                    }
//                    [self.system add:bullet for:self.user.objectId];
//                    [self clearTextView];
                }
                else {
                    NSLog(@"ERROR:%@", error.localizedDescription);
                }
                [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
            } progress:nil];
        }
    }];
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL handler:(void (^)(AVAssetExportSession*))handler {
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset1920x1080];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        handler(exportSession);
    }];
}

- (UIImage*) thumbnailFromVideoAsset:(AVAsset*)asset source:(UIImagePickerControllerSourceType)sourceType
{
    __LF
    AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generateImg.appliesPreferredTrackTransform = YES;
    
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:[generateImg copyCGImageAtTime:CMTimeMake(1, 1) actualTime:NULL error:nil]];
    return thumbnail;
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