//
//  ImagePicker.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ImagePicker.h"
#import "AppEngine.h"

@interface ImagePicker ()
@property (nonatomic, strong) UIAlertController* alert;
@property (nonatomic, weak) UIViewController* parent;
@property (strong, nonatomic) void (^photoSelectedBlock)(UIImage* photo);
@end

@implementation ImagePicker

+ (void) proceedWithParentViewController:(UIViewController*)parent withPhotoSelectedBlock:(void(^)(UIImage *photo))actionBlock
{
    __unused ImagePicker *picker = [[ImagePicker alloc] initWithParentViewController:parent withPhotoSelectedBlock:actionBlock];
}

- (instancetype)initWithParentViewController:(UIViewController*)parent withPhotoSelectedBlock:(void(^)(UIImage *photo))actionBlock
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.allowsEditing = YES;
        self.parent = parent;
        self.photoSelectedBlock = actionBlock;
        self.alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"사진촬영" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           self.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                           [self.parent presentViewController:self animated:YES completion:nil];
                                                       }];
        UIAlertAction *library = [UIAlertAction actionWithTitle:@"사진선택" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                            [self.parent presentViewController:self animated:YES completion:nil];
                                                        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:nil];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self.alert addAction:camera];
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [self.alert addAction:library];
        }
        [self.alert addAction:cancel];
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
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    if (self.photoSelectedBlock) {
        self.photoSelectedBlock(chosenImage);
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
