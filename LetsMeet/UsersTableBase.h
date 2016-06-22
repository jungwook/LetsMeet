//
//  UsersTableBase.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UsersTableDelegate <NSObject>
@required
- (UITableViewCell*) cellForRowAtIndexPath:(NSIndexPath*) indexPath;
- (NSArray*) users;
- (void) refreshUsers;
@end

@interface UsersTableBase : UITableViewController
@property (nonatomic, strong) id <UsersTableDelegate> delegate;
@end

