//
//  MediaPicker.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MediaPickerBlock)(Bullet* bullet);

@interface MediaPicker : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
+ (instancetype) mediaPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType completion:(MediaPickerBlock)block;
@end
