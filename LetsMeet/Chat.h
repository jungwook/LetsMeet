//
//  ChatV2.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageBar.h"
#import "MessageCell.h"

@interface Chat : UIViewController <MessageBarDelegate, UITableViewDelegate, UITableViewDataSource, MessageCellDelegate>
- (void)setChatUser:(PFUser *)user;
@end
