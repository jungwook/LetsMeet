//
//  UserMapCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserMapCell.h"
#import "UserAnnotationView.h"
#import "S3File.h"

@interface UserMapCell()
@property (weak, nonatomic) IBOutlet MKMapView *map;

@end

@implementation UserMapCell

- (void)awakeFromNib
{
    self.userInteractionEnabled = NO;
}

- (void)setUser:(User *)user
{
    _user = user;
    [self initializeMapToUserLocation];
}

- (void) initializeMapToUserLocation
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.user.location.latitude, self.user.location.longitude);
    const CGFloat span = 2500.0f;
    
    self.map.showsUserLocation = YES;
    self.map.showsCompass = YES;
    self.map.showsScale = YES;
    self.map.zoomEnabled = NO;
    self.map.delegate = self;
    
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(coordinate, span, span)];
    [self addUserAnnotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[UserAnnotation class]])
    {
        UserAnnotationView* pinView = (UserAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"UserAnnotationView"];
        
        if (!pinView)
        {
            pinView = [[UserAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"UserAnnotationView"];
            UserAnnotation *anno = (UserAnnotation*) annotation;
            [pinView.photoView setImage:anno.image];
        }
        else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void) addUserAnnotation
{
    __LF
    UserAnnotation *annotation = [[UserAnnotation alloc] initWithLocation:CLLocationCoordinate2DMake(self.user.location.latitude, self.user.location.longitude)];
    [S3File getDataFromFile:self.user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        annotation.animate = YES;
        annotation.image = [UIImage imageWithData:data];
        [self.map addAnnotation:annotation];
    }];
}

@end
