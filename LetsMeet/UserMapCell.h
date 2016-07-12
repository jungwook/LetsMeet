//
//  UserMapCell.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface UserMapCell : UICollectionViewCell <MKMapViewDelegate>
@property (nonatomic, weak) User *user;
@end
