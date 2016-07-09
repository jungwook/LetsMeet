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
@property (nonatomic, assign) UIColor *textColor;
@property (nonatomic, assign) PageSelectionBlock handler;
- (void) setHandler:(PageSelectionBlock)handler;
- (void) addButtonWithTitle:(NSString*)title view:(UIView*)view;
@end
