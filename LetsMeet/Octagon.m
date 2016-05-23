//
//  Octagon.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Octagon.h"

@interface Octagon ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *hives;
@property (strong, nonatomic) id origin;
@end

@implementation Octagon

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hives = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(2000, 2000);
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentOffset = [self centerViewPort];

    [self createHives];

    [self.hives enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
    }];
}

- (void) createHives
{
    self.origin = @{ @"location" : [PFGeoPoint geoPointWithLatitude:37.52016263966829 longitude:127.0290097641595],
                     @"idx" : @(0)};
    for (int i=0; i<100; i++) {
        float dx = ((long)(arc4random()%10000)-5000)/1000000.0;
        float dy = ((long)(arc4random()%10000)-5000)/1000000.0;
        id obj = @{ @"location" : [PFGeoPoint geoPointWithLatitude:(37.52016263966829+dx) longitude:(127.0290097641595+dy)],
                    @"idx" : @(i)};
        [self.hives addObject:obj];
    }
}

- (CGPoint) centerViewPort
{
    CGFloat w = self.view.frame.size.width, h = self.view.frame.size.height;
    CGFloat W = self.scrollView.contentSize.width, H = self.scrollView.contentSize.height;
    
    CGFloat x = (W-w) / 2.f, y = (H-h) / 2.f;
    return CGPointMake(x, y);
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
