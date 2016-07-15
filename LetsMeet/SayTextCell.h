//
//  SayTextCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"


@interface SayTextCell : UITableViewCell <UITextViewDelegate>
@property (weak, nonatomic) Post *parent;
@property (nonatomic) NSUInteger index;
@property (nonatomic, assign) BOOL editable;
- (void) becomeFirstResponder;
- (void) setPost:(NSString*)text;
@end
