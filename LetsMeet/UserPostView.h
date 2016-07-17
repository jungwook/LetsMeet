//
//  UserPostView.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UserPostReadyBlock)(void);

@interface UserPostView : UIView
@property (nonatomic) CGFloat viewHeight;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *dateColor;
@property (nonatomic, strong) UIColor *nicknameColor;
@property (nonatomic, strong) UIColor *commentColor;

@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *dateFont;
@property (nonatomic, strong) UIFont *nicknameFont;
@property (nonatomic, strong) UIFont *commentFont;

- (void)setLoadedPost:(UserPost*)post andUser:(User*)user ready:(UserPostReadyBlock)ready;
- (instancetype)initWithWidth:(CGFloat)width properties:(id)properties;
@end
