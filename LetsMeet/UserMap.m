//
//  UserMap.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserMap.h"
#import "UserAnnotationView.h"
#import "S3File.h"

@implementation UserMap

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

UIImage* snapshot(UIView* view)
{
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@(0.0) forKey:kCIInputSaturationKey];
    
    CIImage *outputImage = filter.outputImage;
    
    CGImageRef cgImageRef = [context createCGImage:outputImage fromRect:outputImage.extent];
    
    UIImage *result = [UIImage imageWithCGImage:cgImageRef];
    CGImageRelease(cgImageRef);
    
    return result;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.user = [User me];
    }
    return self;
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
    
    self.showsUserLocation = YES;
    self.showsCompass = YES;
    self.showsScale = YES;
    self.zoomEnabled = NO;
    self.delegate = self;
    
    [self setRegion:MKCoordinateRegionMakeWithDistance(coordinate, span, span)];
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
        [self addAnnotation:annotation];
    }];
}

@end
