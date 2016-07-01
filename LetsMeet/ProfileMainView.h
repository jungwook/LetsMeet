//
//  ProfileMainView.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 1..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileMainDelegate <NSObject>
- (void) addMoreMedia;
@end

@class ProfileMain;
@interface ProfileMainView : UICollectionReusableView
@property (nonatomic, strong) id<ProfileMainDelegate> delegate;
- (void) sayHi;
@end
