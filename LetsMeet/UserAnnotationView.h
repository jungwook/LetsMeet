//
//  UserAnnotationView.h
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 2..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface UserAnnotation : NSObject <MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) BOOL animate;
@property (nonatomic) BOOL draggable;
- (id)initWithLocation:(CLLocationCoordinate2D)coord;
@end

@interface UserAnnotationView : MKAnnotationView
@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UIView *ball;
@end
