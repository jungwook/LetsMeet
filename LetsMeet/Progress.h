//
//  Progress.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 2..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    Unknown = 0,
    Loading,
    Progressing,
    Completed
} ProgressStatus;

typedef void (^voidBlock)(void);

@interface Progress : UIView
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGFloat progress;
@property (nonatomic) ProgressStatus status;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic) BOOL hidesWhenCompleted;
@property (nonatomic) NSTimeInterval hideAfterTime;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) voidBlock completionBlock;

- (void) startLoading;
- (void) completeLoading:(BOOL)success block:(voidBlock)completion;
@end
