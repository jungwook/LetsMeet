//
//  ImagePicker.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePicker : UIImagePickerController <UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate>
- (instancetype)initWithParentViewController:(UIViewController*)parent withPhotoSelectedBlock:(void(^)(UIImage *photo))actionBlock;
+ (void) proceedWithParentViewController:(UIViewController*)parent withPhotoSelectedBlock:(void(^)(UIImage *photo))actionBlock;
@end
