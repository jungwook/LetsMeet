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
@property (weak, nonatomic) AppEngine *engine;
@property (weak, nonatomic) PFUser *me;
@property (strong, nonatomic) id origin;
@end

@implementation Octagon

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.engine = [AppEngine engine];
        self.me = [PFUser currentUser];
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

    PFGeoPoint *location = [PFGeoPoint geoPointWithLatitude:37.520884 longitude:127.028360];
    [self loadUsersNearLocation:location completionBlock:^(NSArray *users, int levels) {
        CGFloat radius = 40;
        CGFloat size = radius * levels * 2 * 2;
        self.scrollView.contentSize = CGSizeMake(size, size);
        self.scrollView.scrollEnabled = YES;
        self.scrollView.contentOffset = [self centerViewPort];
        
        for (PFUser* user in users) {
            Hive *hive = [Hive hiveWithRadius:radius inset:radius*0.2f];
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

- (void) loadUsersNearLocation:(PFGeoPoint*)location completionBlock:(ArrayIntResultBlock)block
{
    PFQuery *query = [PFUser query];
    [query whereKey:AppKeyLocationKey nearGeoPoint:location];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR LOADING USERS NEAR ME:%@", error.localizedDescription);
        }
        else {
            int levels = [self arrange:users fromLocation:location];
            
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

