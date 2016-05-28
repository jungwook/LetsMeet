//
//  Hive.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 24..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Hive : UIView
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic) CGFloat radius;


+ hiveWithRadius:(CGFloat)radius;
- (void) setUser:(PFUser*)user superview:(UIScrollView*)view;
@end
