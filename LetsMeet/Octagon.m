//
//  Octagon.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Octagon.h"
#import "AppEngine.h"
#import "CachedFile.h"
#import "Hive.h"
#import "PFUser+Attributes.h"
#import "SimulatedUsers.h"

@interface Octagon ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *map;
@property (weak, nonatomic) AppEngine *engine;
@property (weak, nonatomic) PFUser *me;
@property (nonatomic) CGFloat radius, inset;
@property (nonatomic) CGRect hiveFrame;
@property (nonatomic) CGPoint hiveCenter;
@end

@implementation Octagon

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.engine = [AppEngine engine];
        self.me = [PFUser currentUser];
        self.radius = 30;
        self.inset = 3;
    }
    return self;
}

NSString *coordString(CGPoint point)
{
    return NSStringFromCGPoint(point);
}

float distance(PFUser *u1, PFUser* u2)
{
    return [u1.location distanceInKilometersTo:u2.location];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.map;
}


- (CGPoint) centerViewPort
{
    CGFloat w = self.view.frame.size.width, h = self.view.frame.size.height;
    CGFloat W = self.scrollView.contentSize.width, H = self.scrollView.contentSize.height;
    
    CGFloat x = (W-w) / 2.f, y = (H-h) / 2.f;
    return CGPointMake(x, y);
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [SimulatedUsers createHives]; // FOR CREATING NEW SIMULATED USERS
    
    self.scrollView.frame = self.view.bounds;
    self.map.frame = self.view.bounds;

    PFGeoPoint *location = [PFGeoPoint geoPointWithLatitude:37.520884 longitude:127.028360];
    
    [self loadUsersNearLocation:location completionBlock:^(NSArray *users, int levels) {
        NSLog(@"BOUNDS:%@", NSStringFromCGRect(self.hiveFrame));
    
        self.scrollView.contentSize = self.hiveFrame.size;
        self.scrollView.scrollEnabled = YES;
//        self.scrollView.contentOffset = [self centerViewPort];
        self.map.frame = CGRectMake(0, 0, self.hiveFrame.size.width, self.hiveFrame.size.height);
        
        CGPoint center = CGPointMake(-self.hiveFrame.origin.x, -self.hiveFrame.origin.y);
        
        for (PFUser* user in users) {
            Hive *hive = [Hive hiveWithRadius:self.radius inset:self.inset center:center];
            [hive setUser:user superview:self.scrollView];
        }
    }];
}

- (NSArray*) usersClosestToLocation:(PFGeoPoint*)location users:(NSArray *)users;
{
    NSComparisonResult (^c)(PFUser*, PFUser*) = ^NSComparisonResult(PFUser*user1,PFUser*user2){
        PFGeoPoint *p1 = user1.location;
        PFGeoPoint *p2 = user2.location;
        PFGeoPoint *m = location;
        
        float distanceFromObj1 = [p1 distanceInKilometersTo:m];
        float distanceFromObj2 = [p2 distanceInKilometersTo:m];
        
        if (distanceFromObj1 > distanceFromObj2) {
            return NSOrderedDescending;
        }
        
        if (distanceFromObj1 < distanceFromObj2) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    };
    return [NSMutableArray arrayWithArray:[users sortedArrayUsingComparator:c]];
}

float HeadingFromLocation(PFGeoPoint* fromLoc, PFUser* to)
{
    PFGeoPoint *toLoc = to[AppKeyLocationKey];
    return heading(fromLoc, toLoc);
}

int QuadForLevelFromLocation(int level, PFGeoPoint* fromLoc, PFUser* toUser)
{
    return (int) ( (float) HeadingFromLocation(fromLoc, toUser) / (360.0f / (float) numQuads(level)));
}

- (NSArray*) usersInQuad:(int)quad level:(int)level location:(PFGeoPoint*)location users:(NSArray*)users
{
    NSMutableArray *res = [NSMutableArray array];
    
    [users enumerateObjectsUsingBlock:^(PFUser* _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        if (QuadForLevelFromLocation(level, location, user) == quad) {
            [res addObject:user];
        }
    }];
    
    return res;
}

int numQuads(int level)
{
    return level ? (level)*6 : 1;
}

- (CGRect) minMaxBoundsForUsers:(NSArray*)users
{
    __block CGFloat minHeight = MAXFLOAT, maxHeight = -MAXFLOAT, minWidth = MAXFLOAT, maxWidth = -MAXFLOAT;
    [users enumerateObjectsUsingBlock:^(PFUser* _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect rect = hiveToFrame(user.coords, self.radius, self.inset, CGPointZero);
        CGFloat w = rect.origin.x, W = rect.origin.x + rect.size.width;
        CGFloat h = rect.origin.y, H = rect.origin.y + rect.size.height;
        
        minHeight = minHeight > h ? h : minHeight;
        maxHeight = maxHeight < H ? H : maxHeight;
        minWidth = minWidth > w ? w : minWidth;
        maxWidth = maxWidth < W ? W :maxWidth;
    }];
    return CGRectMake(minWidth, minHeight, maxWidth-minWidth, maxHeight-minHeight);
}

- (int) arrange:(NSArray*)users fromLocation:(PFGeoPoint*)location
{
    NSMutableArray *remaining = [NSMutableArray arrayWithArray:[self usersClosestToLocation:location users:users]];
    int level = 0;
    
    for (level=0; remaining.count;level++) {
        for (int quad=0; quad<numQuads(level) && remaining.count; quad++) {
            PFUser *userInQuad = [[self usersInQuad:quad level:level location:location users:remaining] firstObject];
            if (userInQuad) {
                [userInQuad setCoords:CGPointMake(level, quad)];
                [remaining removeObject:userInQuad];
            }
        }
    }
    return level;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [[self scrollView] setNeedsLayout];
}

- (CGRect) hiveToFrame:(CGPoint)hive radius:(CGFloat)radius inset:(CGFloat)inset center:(CGPoint)center;
{
    const int offx[] = { 1, -1, -2, -1, 1, 2};
    const int offy[] = { 1, 1, 0, -1, -1, 0};
    
    int level = hive.x;
    int quad = hive.y;
    
    int sx = level, sy = -level;
    
    for (int i=0; i<quad; i++) {
        int side = (int) i / (level);
        int ox = offx[side];
        int oy = offy[side];
        
        sx += ox;
        sy += oy;
    }
    
    const CGFloat f = 2-inset/radius;
    const CGFloat f2 = f*1.154;
    
    CGFloat x = center.x+(sx-0.5f)*radius;
    CGFloat y = center.y+(sy-0.5f)*radius*1.5*1.154;
    
    return CGRectMake(x, y, f*radius, f2*radius);
}

typedef void (^LoadUsersNearLocationTypeBlock)(NSArray *objects, int levels);

- (void) loadUsersNearLocation:(PFGeoPoint*)location completionBlock:(LoadUsersNearLocationTypeBlock)block
{
    PFQuery *query = [PFUser query];
    [query whereKey:AppKeyLocationKey nearGeoPoint:location];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR LOADING USERS NEAR ME:%@", error.localizedDescription);
        }
        else {
            int levels = [self arrange:users fromLocation:location];
            self.hiveFrame = [self minMaxBoundsForUsers:users];
            
            if (block) {
                block(users, levels);
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    self.scrollView.frame = self.view.bounds;
    self.map.frame = self.scrollView.frame;

    NSLog(@"%s %@ %ld", __FUNCTION__, NSStringFromCGPoint(self.scrollView.contentOffset), [self.scrollView.subviews count]);
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

