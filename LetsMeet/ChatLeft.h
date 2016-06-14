//
//  ChatLeft.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatLeft : UITableViewCell
- (void)setMessage:(Bullet *)message user:(User*)user tableView:(UITableView*)tableView;
@end

