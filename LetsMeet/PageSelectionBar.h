//
//  PageSelectionBar.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 12..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PageSelectionBlock)(NSUInteger index);

@interface PageSelectionBar : UIView
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor* highlightedTextColor;
@property (nonatomic, strong) UIFont * highlightedFont;
@property (nonatomic, strong) UIFont * normalFont;
@property (nonatomic, strong) NSMutableArray* buttons;
@property (nonatomic, copy) PageSelectionBlock handler;
@property (nonatomic, readonly) NSUInteger pages;

- (void) addButtonWithTitle:(NSString*)title;
@end
