//
//  Test.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Test.h"
#import "PageSelectionView.h"
#import "UserMediaCollection.h"

@import MapKit;

@interface Test ()
@property (strong, nonatomic) IBOutlet PageSelectionView *pageView;

@end

@implementation Test

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *v1 = [UIView new];
    v1.backgroundColor = [UIColor redColor];
    UIView *v2 = [UIView new];
    v2.backgroundColor = [UIColor blueColor];
    
    MKMapView *map = [MKMapView new];
    map.userInteractionEnabled = NO;
    
    UserMediaCollection *col = [UserMediaCollection userMediaCollectionOnViewController:self];
    [col setUser:[User me]];
    [self.pageView addButtonWithTitle:@"Media" view:col];
    [self.pageView addButtonWithTitle:@"Hello" view:v1];
    [self.pageView addButtonWithTitle:@"Location" view:map];
    [self.pageView addButtonWithTitle:@"Hello2" view:v2];
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
