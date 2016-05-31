//
//  MessageCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFUser+Attributes.h"
#import "AppEngine.h"

@interface MessageCell : UITableViewCell
@property (nonatomic, weak) NSDictionary * message;
- (CGFloat) appropriateHeight;
- (void)setMessage:(NSDictionary *)message myPhoto:(UIImage*)myPhoto userPhoto:(UIImage*)userPhoto;
@end
