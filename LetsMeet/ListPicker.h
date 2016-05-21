//
//  ListPicker.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListPicker : UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource>
+(instancetype) pickerWithArray:(NSArray*)array withPhotoSelectedBlock:(void(^)(id data))actionBlock;

@end
