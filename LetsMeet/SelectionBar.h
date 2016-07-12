//
//  SelectionBar.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 6..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectionBarBlock)(NSInteger index);

@interface SelectionBar : UIView
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic, copy) SelectionBarBlock handler;

- (void) setHandler:(SelectionBarBlock)handler;
- (void) addButtonWithTitle:(NSString*)title width:(CGFloat)width;
@end
