//
//  MediaPicker.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^MediaPickerBulletBlock)(Bullet* bullet);

typedef void(^MediaPickerMediaInfoBlock)(ProfileMediaTypes mediaType,
                                         NSData* thumbnailData,
                                         NSString* thumbnailFile,
                                         NSString* mediaFile,
                                         CGSize mediaSize,
                                         BOOL isRealMedia);

typedef void(^MediaPickerUserMediaBlock)(UserMedia* userMedia);


//typedef void(^MediaPickerMediaBlock)(ProfileMediaTypes mediaType,
//                                     NSURL* movieURL,
//                                     NSData* imageData);

@interface MediaPicker : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+ (void) addMediaOnViewController:(UIViewController*)viewController
             withMediaInfoHandler:(MediaPickerMediaInfoBlock)handler;

+ (void) addMediaOnViewController:(UIViewController*)viewController
             withUserMediaHandler:(MediaPickerUserMediaBlock)handler;

//+ (void) addMediaOnViewController:(UIViewController*)viewController
//               withOfflineHandler:(MediaPickerMediaBlock)handler;

+ (instancetype) mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                               bulletBlock:(MediaPickerBulletBlock)block;

+ (instancetype) mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                                userMediaInfoBlock:(MediaPickerMediaInfoBlock)block;

+ (instancetype) mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                        userMediaBlock:(MediaPickerUserMediaBlock)block;
@end
