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

typedef NS_OPTIONS(NSUInteger, ImagePickerMediaType) {
    kImagePickerMediaNone                   = 0,
    kImagePickerMediaPhoto                  = 1 << 0,
    kImagePickerMediaMovie                  = 1 << 1,
    kImagePickerMediaVoice                  = 1 << 2,
};

typedef void (^ImagePickerBlock)(id data, MediaTypes type, NSString* sizeString, NSURL *url);

@interface ImagePicker : UIImagePickerController <UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate>
- (instancetype)initWithParentViewController:(UIViewController*)parent
                          photoSelectedBlock:(ImagePickerBlock)actionBlock
                                 cancelBlock:(voidBlock)cancelBlock;
+ (void) proceedWithParentViewController:(UIViewController*)parent
                  photoSelectedBlock:(ImagePickerBlock)actionBlock
                             cancelBlock:(voidBlock)cancelBlock;
@end
