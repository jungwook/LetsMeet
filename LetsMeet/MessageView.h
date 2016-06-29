//
//  MessageView.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 29..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MessageViewLazyBlock)(NSData* data);

@interface MessageView : UIView
@property (nonatomic, copy) MessageViewLazyBlock lazyBlock;
- (CGFloat) getSpacingWhileSettingMessage:(Bullet *)message;
- (void) setThumbnailImage:(UIImage *)image;
@end
