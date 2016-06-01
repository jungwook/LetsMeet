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
@property (nonatomic, weak) UIViewController* parent;
@property (strong, nonatomic) ImagePickerBlock pickerBlock;
@property (nonatomic) ImagePickerSourceTypes types;
@end

@implementation ImagePicker

+ (void) proceedWithParentViewController:(UIViewController*)parent withPhotoSelectedBlock:(ImagePickerBlock)actionBlock featuring:(ImagePickerSourceTypes)types
{
    __unused ImagePicker *picker = [[ImagePicker alloc] initWithParentViewController:parent withPhotoSelectedBlock:actionBlock featuring:(ImagePickerSourceTypes)types];
}

- (instancetype)initWithParentViewController:(UIViewController*)parent withPhotoSelectedBlock:(ImagePickerBlock)actionBlock featuring:(ImagePickerSourceTypes)types
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.allowsEditing = NO;
        self.parent = parent;
        self.pickerBlock = actionBlock;
        self.types = types;
        self.videoQuality = UIImagePickerControllerQualityType640x480;
        
        self.alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        if (types >> kImagePickerSourceCamera) {
            UIAlertAction *camera = [UIAlertAction actionWithTitle:@"카메라" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               self.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                               self.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
                                                               
                                                               [self.parent presentViewController:self animated:YES completion:nil];
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
                                                                [self.parent presentViewController:self animated:YES completion:nil];
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
        
        [self.alert addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:nil]];
        [self.parent presentViewController:self.alert animated:YES completion:nil];
    }
    return self;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        imageToSave = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        NSData *data = UIImageJPEGRepresentation(imageToSave, 1.0);
        
        if (self.pickerBlock) {
            self.pickerBlock(data, kImagePickerMediaPhoto);
        }
    }
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)== kCFCompareEqualTo) {
        NSString *moviePath = [((NSURL*)[info objectForKey:UIImagePickerControllerMediaURL]) path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath, nil, nil, nil);
        }
        
        if (self.pickerBlock) {
            self.pickerBlock(moviePath, kImagePickerMediaMovie);
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
