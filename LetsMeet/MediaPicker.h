//
//  MediaPicker.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MediaPickerBulletBlock)(Bullet* bullet);
typedef void(^MediaPickerMediaBlock)(ProfileMediaTypes mediaType, NSData* thumbnailData, NSString* thumbnailFile, NSString* mediaFile, CGSize mediaSize, BOOL isRealMedia);

@interface MediaPicker : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
+(void) addMediaOnViewController:(UIViewController*)viewController withMediaHandler:(MediaPickerMediaBlock)handler;
+ (instancetype) mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType bulletBlock:(MediaPickerBulletBlock)block;
+ (instancetype) mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType mediaBlock:(MediaPickerMediaBlock)block;
@end
