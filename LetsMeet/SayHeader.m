//
//  SayHeader.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 18..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SayHeader.h"
#import "UserAnnotationView.h"

@interface SayHeader()
@property (weak, nonatomic) IBOutlet MKMapView *map;

@end

@implementation SayHeader

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.map.alpha = 0.0;
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake([User me].location.latitude, [User me].location.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 2000, 2000);
    self.map.delegate = self;
    [self.map setRegion:region];

    User *user = [User me];
    UserAnnotation *annotation = [[UserAnnotation alloc] initWithLocation:CLLocationCoordinate2DMake(user.location.latitude, user.location.longitude)];
    [self.map addAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    __LF
    
    NSLog(@"CENTETR:(%f, %f)", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
    
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    __LF
    [UIView animateWithDuration:0.25 delay:1.0f options:UIViewAnimationOptionTransitionNone animations:^{
        self.map.alpha = 1.0f;
    } completion:nil];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[UserAnnotation class]])
    {
        MarkerAnnotationView* pinView = (MarkerAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Marker"];
        
        if (!pinView)
        {
            pinView = [[MarkerAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Marker"];
        }
        else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

@end
