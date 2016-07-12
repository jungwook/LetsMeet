//
//  AddMoreUserMediaCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AddMoreUserMediaCell;
@protocol AddMoreUserMediaCellDelegate <NSObject>
@required
- (void) addMoreUserMedia;
@end

@interface AddMoreUserMediaCell : UICollectionViewCell
@property (nonatomic, weak) id<AddMoreUserMediaCellDelegate> delegate;
@end
