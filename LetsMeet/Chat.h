//
//  Chat.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageBar.h"

@interface Chat : UIViewController <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) User *user;
@end
