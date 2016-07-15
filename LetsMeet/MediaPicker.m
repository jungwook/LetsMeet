//
//  MediaPicker.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MediaPicker.h"
#import "S3File.h"
#import "ActivityView.h"

@import MobileCoreServices;

@interface MediaPicker ()
@property (nonatomic, copy) MediaPickerBulletBlock bulletBlock;
@property (nonatomic, copy) MediaPickerMediaInfoBlock userMediaInfoBlock;
@property (nonatomic, copy) MediaPickerUserMediaBlock userMediaBlock;
@end

@implementation MediaPicker

typedef void(^ActionHandlers)(UIAlertAction * _Nonnull action);

+ (void) addMediaOnViewController:(UIViewController*)viewController withMediaInfoHandler:(MediaPickerMediaInfoBlock)handler
{
    [MediaPicker handleAlertOnViewController:viewController
                              libraryHandler:^(UIAlertAction * _Nonnull action) {
        [viewController presentViewController:[MediaPicker mediaPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary
                                                                  userMediaInfoBlock:handler]
                                     animated:YES
                                   completion:nil];
    }
                               cameraHandler:^(UIAlertAction * _Nonnull action) {
        [viewController presentViewController:[MediaPicker mediaPickerWithSourceType:UIImagePickerControllerSourceTypeCamera
                                                                  userMediaInfoBlock:handler]
                                     animated:YES
                                   completion:nil];
    }];
}

+ (void) addMediaOnViewController:(UIViewController *)viewController withUserMediaHandler:(MediaPickerUserMediaBlock)handler
{
    [MediaPicker handleAlertOnViewController:viewController
                              libraryHandler:^(UIAlertAction * _Nonnull action) {
                                  [viewController presentViewController:[MediaPicker mediaPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary userMediaBlock:handler]
                                                               animated:YES
                                                             completion:nil];
                              }
                               cameraHandler:^(UIAlertAction * _Nonnull action) {
                                   [viewController presentViewController:[MediaPicker mediaPickerWithSourceType:UIImagePickerControllerSourceTypeCamera userMediaBlock:handler]
                                                                animated:YES
                                                              completion:nil];
                               }];
}

+ (instancetype) mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType bulletBlock:(MediaPickerBulletBlock)block
{
    return [[MediaPicker alloc] initWithSourceType:sourceType completionBlock:block];
}

+ (instancetype) mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType userMediaInfoBlock:(MediaPickerMediaInfoBlock)block
{
    return [[MediaPicker alloc] initWithSourceType:sourceType userMediaInfoBlock:block];
}

+ (instancetype) mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType userMediaBlock:(MediaPickerUserMediaBlock)block
{
    return [[MediaPicker alloc] initWithSourceType:sourceType userMediaBlock:block];
}


- (instancetype) initWithSourceType:(UIImagePickerControllerSourceType)sourceType completionBlock:(MediaPickerBulletBlock)block
{
    self = [super init];
    if (self) {
        [self selfInitializersWithSourceType:sourceType bulletBlock:block userMediaInfoBlock:nil userMediaBlock:nil];
    }
    return self;
}

- (instancetype) initWithSourceType:(UIImagePickerControllerSourceType)sourceType userMediaInfoBlock:(MediaPickerMediaInfoBlock)block
{
    self = [super init];
    if (self) {
        [self selfInitializersWithSourceType:sourceType bulletBlock:nil userMediaInfoBlock:block userMediaBlock:nil];
    }
    return self;
}

- (instancetype) initWithSourceType:(UIImagePickerControllerSourceType)sourceType userMediaBlock:(MediaPickerUserMediaBlock)block
{
    self = [super init];
    if (self) {
        [self selfInitializersWithSourceType:sourceType bulletBlock:nil userMediaInfoBlock:nil userMediaBlock:block];
    }
    return self;
}

- (void) selfInitializersWithSourceType:(UIImagePickerControllerSourceType)sourceType
                            bulletBlock:(MediaPickerBulletBlock)bulletBlock
                     userMediaInfoBlock:(MediaPickerMediaInfoBlock)userMediaInfoBlock
                         userMediaBlock:(MediaPickerUserMediaBlock)userMediaBlock
{
    self.delegate = self;
    self.allowsEditing = YES;
    self.videoMaximumDuration = 10;
    self.sourceType = sourceType;
    self.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.bulletBlock = bulletBlock;
    self.userMediaInfoBlock = userMediaInfoBlock;
    self.userMediaBlock = userMediaBlock;
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
    // Original image
    UIImage *image = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    
    // Original image data
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    // Thumbnail data
    NSData *thumbnailData = compressedImageData(imageData, kThumbnailWidth);
    
//    ActivityView *activity = [ActivityView activityView];
    [S3File saveImageData:thumbnailData completedBlock:^(NSString *thumbnailFile, BOOL succeeded, NSError *error)
    {
        if (succeeded && !error) {
            [S3File saveImageData:imageData completedBlock:^(NSString *mediaFile, BOOL succeeded, NSError *error) {
//                [activity stopAndDie];

                if (succeeded && !error) {
                    if (self.bulletBlock) {
                        Bullet* bullet = [Bullet bulletWithPhoto:mediaFile
                                                       thumbnail:thumbnailFile
                                                       mediaSize:image.size
                                                       realMedia:(sourceType == UIImagePickerControllerSourceTypeCamera)];
                        self.bulletBlock(bullet);
                    }
                    if (self.userMediaInfoBlock) {
                        self.userMediaInfoBlock( kProfileMediaPhoto,
                                                thumbnailData,
                                                thumbnailFile,
                                                mediaFile,
                                                image.size,
                                                (sourceType == UIImagePickerControllerSourceTypeCamera));
                    }
                    
                    if (self.userMediaBlock) {
                        UserMedia *media = [UserMedia object];
                        media.mediaSize = image.size;
                        media.mediaFile = mediaFile;
                        media.thumbailFile = thumbnailFile;
                        media.mediaType = kProfileMediaPhoto;
                        media.isRealMedia = (sourceType == UIImagePickerControllerSourceTypeCamera);
                        
                        self.userMediaBlock(media);
                    }
                }
                else {
                    NSLog(@"ERROR:%@", error.localizedDescription);
                }
            }];
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
//            [activity stopAndDie];
        }
    } progressBlock:^(int percentDone) {
        // Thumbnail progress.
    }];
}

- (void) handleVideo:(NSDictionary<NSString*, id>*)info url:(NSURL*)url source:(UIImagePickerControllerSourceType)sourceType
{
    // Video Asset
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    // Thumbnail Image
    UIImage *thumbnailImage = [self thumbnailFromVideoAsset:asset source:sourceType];
    
    // Thumbnail Image data @ full compression
    NSData *thumbnailData = compressedImageData(UIImageJPEGRepresentation(thumbnailImage, kJPEGCompressionFull), kThumbnailWidth);
    
    
    [S3File saveImageData:thumbnailData completedBlock:^(NSString *thumbnailFile, BOOL succeeded, NSError *error) {
        NSString *tempId = randomObjectId();
        NSURL *outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:tempId]];
        
        [self convertVideoToLowQuailtyWithInputURL:url outputURL:outputURL handler:^(AVAssetExportSession *exportSession) {
            if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
                
                [S3File saveMovieData:videoData completedBlock:^(NSString *mediaFile, BOOL succeeded, NSError *error) {
                    if (succeeded && !error) {
                        if (self.bulletBlock) {
                            Bullet* bullet = [Bullet bulletWithVideo:mediaFile
                                                           thumbnail:thumbnailFile
                                                           mediaSize:thumbnailImage.size
                                                           realMedia:(sourceType == UIImagePickerControllerSourceTypeCamera)];
                            self.bulletBlock(bullet);
                        }
                        
                        if (self.userMediaInfoBlock) {
                            self.userMediaInfoBlock(kProfileMediaVideo,
                                                thumbnailData,
                                                thumbnailFile,
                                                mediaFile,
                                                thumbnailImage.size,
                                                (sourceType == UIImagePickerControllerSourceTypeCamera));
                        }
                        
                        if (self.userMediaBlock) {
                            UserMedia *media = [UserMedia object];
                            media.mediaSize = thumbnailImage.size;
                            media.mediaFile = mediaFile;
                            media.thumbailFile = thumbnailFile;
                            media.mediaType = kProfileMediaVideo;
                            media.isRealMedia = (sourceType == UIImagePickerControllerSourceTypeCamera);
                        
                            self.userMediaBlock(media);
                        }
                    }
                    else {
                        NSLog(@"ERROR:%@", error.localizedDescription);
                    }
                    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
                }];
            }
        }];
    } progressBlock:^(int percentDone) {
        // Thumbnail progress.
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

+ (void) handleAlertOnViewController:(UIViewController*)viewController
                      libraryHandler:(ActionHandlers)library
                       cameraHandler:(ActionHandlers)camera
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Library"
                                                  style:UIAlertActionStyleDefault
                                                handler:library]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Camera"
                                                  style:UIAlertActionStyleDefault
                                                handler:camera]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil]];
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
