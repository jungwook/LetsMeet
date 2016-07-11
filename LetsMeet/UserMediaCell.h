//
//  UserMediaCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserMediaCollection.h"

@interface UserMediaCell : UICollectionViewCell
- (void) setUserMedia:(UserMedia*)media parent:(UserMediaCollection*)parent row:(NSInteger)row;
@end
