//
//  Map.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 2..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Map.h"
#import "UserAnnotationView.h"
#import "S3File.h"

@interface Map ()
@property (strong, nonatomic) FileSystem *system;
@property (strong, nonatomic) NSArray* users;
@property (strong, nonatomic) User *me;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation Map

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.system = [FileSystem new];
        self.me = [User me];
        self.users = [NSArray new];
    }
    return self;
}

- (void)awakeFromNib
{
}

- (void)reloadAllUsers
{
    [self.system usersNearMeInBackground:^(NSArray<User *> *users) {
        self.users = [NSArray arrayWithArray:users];
        [self addUserAnnotations];
    }];
}

- (void)viewDidLayoutSubviews
{
    __LF
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

- (void) initializeMap
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.me.location.latitude, self.me.location.longitude);
    const CGFloat span = 2500.0f;
    
    self.mapView.showsUserLocation = YES;
    self.mapView.showsCompass = YES;
    self.mapView.showsScale = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.delegate = self;
    
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(coordinate, span, span)];
}

- (void) addUserAnnotations
{
    __LF
    [self.users enumerateObjectsUsingBlock:^(User* _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        UserAnnotation *annotation = [[UserAnnotation alloc] initWithLocation:CLLocationCoordinate2DMake(user.location.latitude, user.location.longitude)];
        [S3File getDataFromFile:user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            if ([user.objectId isEqualToString:self.me.objectId]) {
                annotation.animate = YES;
            }
            annotation.image = [UIImage imageWithData:data];
            [self.mapView addAnnotation:annotation];
        }];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeMap];
    [self reloadAllUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
