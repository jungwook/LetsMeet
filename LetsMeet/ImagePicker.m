//
//  ImagePicker.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ImagePicker.h"

@interface ImagePicker ()
@property (nonatomic, strong) UIAlertController* alert;
@property (nonatomic, weak) UINavigationController  * parent;
@property (strong, nonatomic) ImagePickerBlock pickerBlock;
@property (strong, nonatomic) voidBlock cancelBlock;
@property (nonatomic) ImagePickerSourceTypes types;
@end

@implementation ImagePicker

+ (void) proceedWithParentViewController:(UIViewController*)parent
                               featuring:(ImagePickerSourceTypes)types
                      photoSelectedBlock:(ImagePickerBlock)actionBlock
                             cancelBlock:(voidBlock)cancelBlock
{
    __unused ImagePicker *picker = [[ImagePicker alloc] initWithParentViewController:parent
                                                                           featuring:types
                                                                  photoSelectedBlock:actionBlock
                                                                         cancelBlock:cancelBlock];
}

- (instancetype)initWithParentViewController:(UIViewController*)parent
                                   featuring:(ImagePickerSourceTypes)types
                          photoSelectedBlock:(ImagePickerBlock)actionBlock
                                 cancelBlock:(voidBlock)cancelBlock
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.allowsEditing = NO;
        self.parent = parent.navigationController;
        self.pickerBlock = actionBlock;
        self.cancelBlock = cancelBlock;
        self.types = types;
        self.videoQuality = UIImagePickerControllerQualityType640x480;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.videoMaximumDuration = 10;
        [self.parent setNavigationBarHidden:YES animated:YES];
        
        self.alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        if (types >> kImagePickerSourceCamera) {
            UIAlertAction *camera = [UIAlertAction actionWithTitle:@"카메라" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               self.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                               self.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                                                               [parent presentViewController:self animated:YES completion:nil];
                                                           }];
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [self.alert addAction:camera];
            }
        }

        if (types >> kImagePickerSourceLibrary) {
            UIAlertAction *library = [UIAlertAction actionWithTitle:@"사진/동영상" style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                self.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                                                                [parent presentViewController:self animated:YES completion:nil];
                                                            }];

            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                [self.alert addAction:library];
            }
        }
        
        if (types << kImagePickerSourceVoice) {
            [self.alert addAction:[UIAlertAction actionWithTitle:@"보이스" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
        }
        
        if (types << kImagePickerSourceURL) {
            [self.alert addAction:[UIAlertAction actionWithTitle:@"링크" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
        }
        
        [self.alert addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (self.cancelBlock)
                self.cancelBlock();
        }]];
        [parent presentViewController:self.alert animated:YES completion:nil];
    }
    return self;
}

- (UIImage *)fixOrientation:(UIImage*) image
{
    if (image.imageOrientation == UIImageOrientationUp)
        return image;

    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self.parent setNavigationBarHidden:NO animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
        NSURL *url = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        
        // Handle a still image capture
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            UIImage *image = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
            CGSize imageSize = image.size;
            
            UIImageWriteToSavedPhotosAlbum (image, nil, nil , nil);
            
            image = [self fixOrientation:image];
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            
            if (self.pickerBlock) {
                self.pickerBlock(data, kMessageTypePhoto, NSStringFromCGSize(imageSize), url);
            }
        }
        
        // Handle a movie capture
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)== kCFCompareEqualTo) {
            AVAsset *asset = [AVAsset assetWithURL:url];
            
            AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            CGSize dimensions = track ? CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform) : CGSizeMake(400, 300);
            dimensions.width = fabs(dimensions.width);
            dimensions.height = fabs(dimensions.height);
            
            NSString *moviePath = [((NSURL*)[info objectForKey:UIImagePickerControllerMediaURL]) path];
            
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(moviePath, nil, nil, nil);
            }
            
            if (self.pickerBlock) {
                self.pickerBlock(moviePath, kMessageTypeVideo, NSStringFromCGSize(dimensions), url);
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.parent setNavigationBarHidden:NO animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    }];
}


@end
