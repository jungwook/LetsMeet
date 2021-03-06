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

@protocol MessageCellDelegate;

@interface MessageCell : UITableViewCell
@property (nonatomic, weak) Message* message;
@property (nonatomic, weak) id<MessageCellDelegate> delegate;
- (void)setMessage:(Message*)message
           myPhoto:(UIImage*)   myPhoto
         userPhoto:(UIImage*)   userPhoto
          userName:(NSString*)  userName
            myName:(NSString*)  myName;
@end

@protocol MessageCellDelegate <NSObject>
- (void) tappedPhoto:(Message*)message image:(UIImage*)image view:(UIView*)view;
- (void) redrawCell:(Message*)message;
@end
