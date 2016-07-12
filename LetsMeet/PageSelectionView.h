//
//  PageSelectionView.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageSelectionBar.h"

@protocol PageSelectionViewProtocol <NSObject>
@optional
- (void)viewDidLoad;
@end

@interface PageSelectionView : UIView <UIScrollViewDelegate>
@property (nonatomic, assign) UIColor *textColor;
@property (nonatomic, assign) PageSelectionBlock handler;
@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic) CGFloat barHeight;
- (void) setHandler:(PageSelectionBlock)handler;
- (void) addButtonWithTitle:(NSString*)title view:(UIView<PageSelectionViewProtocol>*)view;
@end
