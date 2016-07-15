//
//  Post.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Post : UIViewController <UITableViewDelegate, UITableViewDataSource>
- (void) sayText:(NSString*)text changedAtIndex:(NSUInteger)index;
- (void) startNewLine;
@end
