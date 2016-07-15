//
//  SayCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 15..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Say.h"

@interface SayCell : UICollectionViewCell
@property (nonatomic, weak) UserPost *post;
@property (nonatomic) CGFloat postHeight;

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
@end
