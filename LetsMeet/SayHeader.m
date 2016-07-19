//
//  SayHeader.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 18..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SayHeader.h"
#import "UserAnnotationView.h"

@interface Overlay : MKCircle
@property(nonatomic) BOOL isBoundary;
@end

@implementation Overlay

@end

@interface SayHeader()
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *overlay;
@property (strong, nonatomic) Overlay *circle;
@property (strong, nonatomic) UIImageView *marker;
@property (strong, nonatomic) NSMutableSet *markers;
@end

@implementation SayHeader

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.backView.bounds cornerRadius:2.0f];
    self.backView.layer.shadowPath = path.CGPath;
    self.backView.layer.shadowColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.7].CGColor;
    self.backView.layer.shadowOffset = CGSizeMake(0, 1);
    self.backView.layer.shadowRadius = 2.0f;
    self.backView.layer.shadowOpacity = 0.7f;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.map.alpha = 0.0;
    self.map.delegate = self;
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake([User me].location.latitude, [User me].location.longitude);
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(location, 2000, 2000)];

    self.circle = [Overlay circleWithCenterCoordinate:location radius:500];
    self.circle.isBoundary = YES;
    [self.map addOverlay: self.circle];

    self.marker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gps blue"]];
    [self.overlay addSubview:self.marker];
    
    [self.overlay removeConstraints:self.overlay.constraints];
    [self.marker removeConstraints:self.marker.constraints];
    
    self.markers = [NSMutableSet set];
}


-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [UIView animateWithDuration:0.2 animations:^{
        self.map.alpha = 0.4f;
    }];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    Overlay *over = overlay;
    
    MKCircleRenderer *circleR = [[MKCircleRenderer alloc] initWithCircle:over];
    if (over.isBoundary) {
        circleR.fillColor = [UIColor clearColor];
        circleR.alpha = 0.0f;
    }
    else {
        circleR.fillColor = [UIColor redColor];
        circleR.alpha = 0.8f;
    }
    return circleR;
}

- (void)showPostLocations:(NSArray*)posts
{
    [posts enumerateObjectsUsingBlock:^(UserPost *post, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![self.markers containsObject:post.location]) {
            [self.markers addObject:post.location];
            Overlay *circle = [Overlay circleWithCenterCoordinate:CLLocationCoordinate2DMake(post.location.latitude, post.location.longitude) radius:10];
            circle.isBoundary = NO;
            [self.map addOverlay: circle];
        }
    }];
}

- (void)showCoordinate:(CLLocationCoordinate2D)coordinate
{
    const CGFloat s = 10, hs = s / 2;
    CGPoint point = [self.map convertCoordinate:coordinate toPointToView:self.map];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gps white"]];
    imageView.frame = CGRectMake(point.x-hs, point.y-hs, s, s);
    
    [self.backView addSubview:imageView];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageView removeFromSuperview];
    });
}

- (void)addBoundaryOverlayWithCenterCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.map removeOverlay:self.circle];
    self.circle = [Overlay circleWithCenterCoordinate:coordinate radius:500];
    self.circle.isBoundary = YES;
    [self.map addOverlay: self.circle];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    __LF
    [self addBoundaryOverlayWithCenterCoordinate:mapView.centerCoordinate];

    self.overlay.frame = [mapView convertRegion:MKCoordinateRegionForMapRect(self.circle.boundingMapRect) toRectToView:self.map];
    self.overlay.layer.cornerRadius = MIN(self.overlay.bounds.size.width, self.overlay.bounds.size.height) / 2.0f;
    
    CGFloat w = self.overlay.bounds.size.width, h = self.overlay.bounds.size.height;
    CGFloat sw = 20, sh = 20;
    self.marker.frame = CGRectMake((w-sw)/2, (h-sh)/2, sw, sh);
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.map.alpha = 1.0f;
                     }];
    
    CLLocationCoordinate2D coordinate = mapView.centerCoordinate;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationUserAnnotationMoved"
                                                        object:@{@"location" : [PFGeoPoint geoPointWithLatitude:coordinate.latitude
                                                                                                      longitude:coordinate.longitude]
                                                                 }];
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
