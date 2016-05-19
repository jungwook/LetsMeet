//
//  UserCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 19..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell
- (void)setUser:(PFUser *)user andMessages:(NSArray*)messages;
@end
