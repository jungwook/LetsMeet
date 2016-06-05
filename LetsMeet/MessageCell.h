//
//  MessageCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSMutableDictionary+Bullet.h"

@protocol MessageCellDelegate;

@interface MessageCell : UITableViewCell
@property (nonatomic, weak) Bullet* message;
@property (nonatomic, weak) id<MessageCellDelegate> delegate;
- (void)setMessage:(Bullet*)    message
           myPhoto:(UIImage*)   myPhoto
         userPhoto:(UIImage*)   userPhoto
          userName:(NSString*)  userName
            myName:(NSString*)  myName;
@end

@protocol MessageCellDelegate <NSObject>
- (void) tappedPhoto:(Bullet*)message image:(UIImage*)image view:(UIView*)view;
- (void) redrawCell:(Bullet*)message;
@end
