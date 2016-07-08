//
//  PageSelectionView.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PageSelectionBlock)(NSUInteger index);

@interface PageSelectionView : UIView <UIScrollViewDelegate>
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic, strong) UIColor* highlightedTextColor;
@property (nonatomic, strong) UIFont * highlightedFont;
@property (nonatomic, strong) UIFont * normalFont;
@property (nonatomic, copy) PageSelectionBlock handler;

- (void) setHandler:(PageSelectionBlock)handler;
- (void) addButtonWithTitle:(NSString*)title view:(UIView*)view;
@end
