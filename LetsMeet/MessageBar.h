//
//  MessageBar.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageBarDelegate;

@interface MessageBar : UIToolbar <UITextViewDelegate>
@property (nonatomic, strong) id<MessageBarDelegate> messageBarDelegate;
- (void) pullDownKeyBoard;

@end

@protocol MessageBarDelegate <NSObject>
- (void) keyBoardEvent:(CGRect)kbFrame duration:(double)duration animationType:(UIViewAnimationOptions)animation;
- (void) sendMessage:(id)message;
@end
