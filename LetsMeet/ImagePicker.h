//
//  ImagePicker.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppEngine.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ImagePicker : UIImagePickerController <UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate>
- (instancetype)initWithParentViewController:(UIViewController*)parent
                                   featuring:(ImagePickerSourceTypes)types
                          photoSelectedBlock:(ImagePickerBlock)actionBlock
                                 cancelBlock:(voidBlock)cancelBlock;
+ (void) proceedWithParentViewController:(UIViewController*)parent
                               featuring:(ImagePickerSourceTypes)types
                  photoSelectedBlock:(ImagePickerBlock)actionBlock
                             cancelBlock:(voidBlock)cancelBlock;
@end
