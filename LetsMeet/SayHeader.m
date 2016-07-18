//
//  SayHeader.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 18..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SayHeader.h"

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
@end
