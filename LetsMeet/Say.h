//
//  Say.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 15..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SayLayout.h"

CGRect getPostRect(NSString *string, UIFont *font, CGFloat maxWidth);

@interface Say : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, SayDelegateLayout>

@end
