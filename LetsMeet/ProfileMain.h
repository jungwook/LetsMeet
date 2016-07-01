//
//  ProfileMain.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 1..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileMain : UICollectionViewController
- (void) setMe:(User *)user;
- (void) addMedia;
- (void) removeMedia:(UserMedia*)media row:(NSInteger)row;
@end
