//
//  MessageBar.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFUser+Attributes.h"
#import "AppEngine.h"

@protocol MessageBarDelegate;

@interface MessageBar : UIToolbar <UITextViewDelegate>
@property (nonatomic, strong) id<MessageBarDelegate> barDelegate;
- (void) pullDownKeyBoard;

@end

@protocol MessageBarDelegate <NSObject>
- (void) keyBoardEvent:(CGRect)kbFrame duration:(double)duration animationType:(UIViewAnimationOptions)animation;
- (void) sendMessage:(NSString*)message;
- (void) sendMedia;
@end
