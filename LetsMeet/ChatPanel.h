//
//  ChatPanel.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 30..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatPanel : UIView
@property (nonatomic, assign) User* user;
+ (instancetype)chatPanelWithFrame:(CGRect)frame;
@end
