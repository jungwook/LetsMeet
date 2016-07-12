//
//  UserMap.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "PageSelectionView.h"

@interface UserMap : MKMapView <MKMapViewDelegate, PageSelectionViewProtocol>
@property (strong, nonatomic) User* user;
@end
