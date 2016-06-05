//
//  ImagePicker.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSMutableDictionary+Bullet.h"

typedef NS_OPTIONS(NSUInteger, ImagePickerSourceTypes) {
    kImagePickerSourceNone                  = 0,
    kImagePickerSourceCamera                = 1 << 0,
    kImagePickerSourceLibrary               = 1 << 1,
    kImagePickerSourceVoice                 = 1 << 2,
    kImagePickerSourceURL                   = 1 << 3,
};

typedef NS_OPTIONS(NSUInteger, ImagePickerMediaType) {
    kImagePickerMediaNone                   = 0,
    kImagePickerMediaPhoto                  = 1 << 0,
    kImagePickerMediaMovie                  = 1 << 1,
    kImagePickerMediaVoice                  = 1 << 2,
};

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
