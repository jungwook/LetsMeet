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

@interface Octagon ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) AppEngine *engine;
@property (weak, nonatomic) PFUser *me;

@property (strong, nonatomic) NSMutableArray *hives;
@property (strong, nonatomic) id origin;
@end

@implementation Octagon

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hives = nil;
        self.engine = [AppEngine engine];
        self.me = [PFUser currentUser];
    }
    return self;
}

#define CSTR(XXX) ((NSString*)XXX).UTF8String
#define Q(XXX) [NSString stringWithFormat:@"Q%d", XXX]
#define PQ(XXX) ((XXX+6-1) % 6)
#define NQ(XXX) ((XXX+1) %6)
#define AQ(XXX) ((quad+3) % 6)

- (CGPoint) newCoords:(int)q origin:(CGPoint) origin
{
    int x=origin.x, y=origin.y;
//    NSLog(@">>>>NC(%d) X:%d Y:%d", q, x, y);
    switch (q) {
        case 0:
            x = x+1;
            y = y-1;
            break;
        case 1:
            x = x+2;
            y = y;
            break;
        case 2:
            x = x+1;
            y = y+1;
            break;
        case 3:
            x = x-1;
            y = y+1;
            break;
        case 4:
            x = x-2;
            y = y;
            break;
        case 5:
        default:
            x = x-1;
            y = y-1;
            break;
    }
//    NSLog(@"    NC(%d) X:%d Y:%d", q, x, y);
    return CGPointMake(x, y);
}




#define CS(__x) [NSString stringWithFormat:@"X%dY%d", (int)__x.x, (int)__x.x]

- (void) addHiveToView:(Hive*)hive
{
    PFUser *user = hive.user;
    CGPoint coord = [self coord:user];
    const CGFloat f = 1.8;
    const CGFloat f2 = f*1.154;

    CGFloat radius = 30;
    CGPoint centerPoint = CGPointMake(1000, 1000);
    CGFloat cx = centerPoint.x, cy = centerPoint.y;
    CGFloat x = cx+(coord.x-0.5f)*radius;
    CGFloat y = cy+(coord.y-0.5f)*radius*1.5*1.154;
    hive.frame = CGRectMake(x, y, f*radius, f2*radius);
    
    [self.scrollView addSubview:hive];
}

- (IBAction)setNextUser:(id)sender {
    static NSMutableArray *sortedUsers;
    if (!sortedUsers) {
        sortedUsers = [NSMutableArray array];
        [sortedUsers addObject:self.me];
    }
    
    static int idx = 1;
    
    PFUser *user = self.hives[idx++];
    
    if ([user.objectId isEqualToString:self.me.objectId])
        return;
    
    NSArray *closestUsers = [self closestTwoUsersFromUser:user inUsers:sortedUsers];
    PFUser* first = [self first:closestUsers];
    PFUser* second = [self second:closestUsers];
    
    bool condition = NO;
    do {
        BOOL left = isLeft(self.me, user);
        BOOL above = isAbove(self.me, user);
        
        CGPoint n1 = first.coords;
        CGPoint n2 = second.coords;
        int x = 0, y = 0;
        
        if (n1.y == n2.y) { // 0 & 3
            printf("AB SETTING %s %s %s AND %s\n", user.desc, above ? "ABOVE" : "BELOW", first.desc, second.desc);
            if (n1.x == n2.x) {
                x = n1.x + (left ? -1 : 1);
            }
            else {
                x = n1.x + ((n1.x < n2.x) ? 1 : -1);
            }
            y = n1.y + (above ? -1 : +1);
        }
        else {
            int min = MIN(n1.x, n2.x);
            if (left) { // 4 & 5
                printf("LF SETTING %s %s %s AND %s\n", user.desc, "LEFT", first.desc, second.desc);
                x = min - 2;
                y = (n1.x == min) ? n2.y : n1.y;
            }
            else { // 1 & 2
                printf("RT SETTING %s %s %s AND %s\n", user.desc, "RIGHT", first.desc, second.desc);
                x = min + 2;
                y = (n1.x == min) ? n1.y : n2.y;
            }
        }
        user.coords = CGPointMake(x,y);
    } while (condition);
    
    [sortedUsers addObject:user];
    
    Hive *hive = [Hive new];
    hive.user = user;
    [self addHiveToView:hive];
    [self.view setNeedsLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(2000, 2000);
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentOffset = [self centerViewPort];

//    [self createHives]; // CREATING NEW USERS... DO NOT USE...
    
    [self loadUsersNearMeInBackground:^(NSArray *users) {
        
        PFUser* root = [PFUser currentUser];
        
        Hive *hive = [Hive new];
        hive.user = self.me;
        hive.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:1.0 alpha:0.4];
        hive.borderColor = [UIColor colorWithRed:0.5 green:0.1 blue:1.0 alpha:1.0];
        
        [self addHiveToView:hive];
        printf("\nROOT IS [%s]\n", CSTR(root.nickname));
        
        self.hives = [NSMutableArray arrayWithArray:users];

//      [self spartialSort:users usingRoot:root];
        /*
        for (PFUser* user in self.hives) {
            Hive *hive = [Hive new];
            hive.user = user;
            [self addHiveToView:hive];
        }
        NSLog(@"NOW WILL LAYOUT SUBVIEWS");
        */
    }];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [[self scrollView] setNeedsLayout];
    NSLog(@"WILL LAYOUT SUBVIEWS" );
}

- (void) loadUsersNearMeInBackground:(ArrayResultBlock)block
{
    PFQuery *query = [PFUser query];
    [query whereKey:AppKeyLocationKey nearGeoPoint:[self.engine currentLocation]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR LOADING USERS NEAR ME:%@", error.localizedDescription);
        }
        else {
            NSLog(@"LOADED:%ld USERS NEAR ME", users.count);
            
            NSArray * arr = [users sortedArrayUsingComparator:^NSComparisonResult(PFUser*  _Nonnull user1, PFUser* _Nonnull user2) {
                PFGeoPoint *p1 = [user1 objectForKey:AppKeyLocationKey];
                PFGeoPoint *p2 = [user2 objectForKey:AppKeyLocationKey];
                PFGeoPoint *m = self.me.location;
                
                float distanceFromObj1 = [p1 distanceInKilometersTo:m];
                float distanceFromObj2 = [p2 distanceInKilometersTo:m];
                
                if (distanceFromObj1 > distanceFromObj2) {
                    return NSOrderedDescending;
                }
                
                if (distanceFromObj1 < distanceFromObj2) {
                    return NSOrderedAscending;
                }
                return NSOrderedSame;
            }];
            if (block) {
                block(arr);
            }
            else {
                self.hives = [NSMutableArray arrayWithArray:users];
            }
        }
    }];
}

- (PFUser*) first:(NSArray*)users
{
    return [users firstObject];
}

- (PFUser*) second:(NSArray*)users
{
    return [users objectAtIndex:1];
}

- (NSArray*) closestTwoUsersFromUser:(PFUser*)user inUsers:(NSArray*)users
{
    NSComparisonResult (^c)(PFUser*, PFUser*) = ^NSComparisonResult(PFUser*user1,PFUser*user2){
        PFGeoPoint *p1 = user1.location;
        PFGeoPoint *p2 = user2.location;
        PFGeoPoint *m = user.location;
        
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
    NSArray *ret = [users sortedArrayUsingComparator:c];
    
    if (ret.count == 0)
    {
        return nil;
    }
    else if (ret.count == 1)
    {
        return @[[ret firstObject], [ret firstObject]];
    }
    else
    {
        return @[[ret objectAtIndex:0], [ret objectAtIndex:1]];
    }
}

- (float) metersBetween:(PFUser*)u1 and:(PFUser*)u2
{
    PFGeoPoint *l1 = u1.location;
    PFGeoPoint *l2 = u2.location;
    
    return [l1 distanceInKilometersTo:l2] * 1000.0f;
}

- (CGPoint) coord:(PFUser*)user
{
    int x = [user[@"hive-x"] intValue];
    int y = [user[@"hive-y"] intValue];
    
    return CGPointMake(x, y);
}

- (void) setCoord:(CGPoint)coord user:(PFUser*)user
{
    [user setObject:@(coord.x) forKey:@"hive-x"];
    [user setObject:@(coord.y) forKey:@"hive-y"];
//    printf("setting coordinates (%d, %d) for user %s\n", (int) coord.x, (int) coord.y, CSTR(user.nickname));
}

CGPoint Offset(PFUser* one, PFUser* two)
{
    int q = (int) (Heading(one, two)/90.f);
    
    switch (q) {
        case 0:
            return CGPointMake(1, -1);
        case 1:
            return CGPointMake(1, 1);
        case 2:
            return CGPointMake(-1, 1);
        case 3:
            return CGPointMake(-1, -1);
        default:
            return CGPointZero;
    }
}

BOOL isAbove(PFUser* root, PFUser* user)
{
    int offset = (int) (Heading(root, user)/90.f);
    switch (offset) {
        case 0:
        case 3:
            return YES;
        default:
            return NO;
    }
}

BOOL isLeft(PFUser* root, PFUser* user)
{
    int offset = (int) (Heading(root, user)/90.f);
    switch (offset) {
        case 0:
        case 1:
            return NO;
        default:
            return YES;
    }
}

NSString* Direction(PFUser* one, PFUser* two)
{
    int offset = (int) (Heading(one, two)/90.f);
    
    switch (offset) {
        case 0:
            return @"RA";
        case 1:
            return @"RB";
        case 2:
            return @"LB";
        case 3:
        default:
            return @"LA";
    }
}

CGPoint coords(PFUser*user)
{
    int x = [user[@"hive-x"] intValue];
    int y = [user[@"hive-y"] intValue];
    
    return CGPointMake(x, y);
}

void setCoords(CGPoint coord, PFUser* user)
{
    [user setObject:@(coord.x) forKey:@"hive-x"];
    [user setObject:@(coord.y) forKey:@"hive-y"];
}

- (void) spartialSort:(NSArray*)users usingRoot:(PFUser*)root
{
    NSMutableArray *sortedUsers = [NSMutableArray array];
    [sortedUsers addObject:root];
    [users enumerateObjectsUsingBlock:^(PFUser* _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![user.objectId isEqualToString: root.objectId]) {
            NSArray *closestUsers = [self closestTwoUsersFromUser:user inUsers:sortedUsers];
            PFUser* first = [self first:closestUsers];
            PFUser* second = [self second:closestUsers];
            
            bool condition = NO;
            do {
                BOOL left = isLeft(root, user);
                BOOL above = isAbove(root, user);
                
                CGPoint n1 = first.coords;
                CGPoint n2 = second.coords;
                int x = 0, y = 0;
                
                if (n1.y == n2.y) { // 0 & 3
                    printf("AB SETTING %s %s %s AND %s\n", user.desc, above ? "ABOVE" : "BELOW", first.desc, second.desc);
                    if (n1.x == n2.x) {
                        x = n1.x + (left ? -1 : 1);
                    }
                    else {
                        x = n1.x + ((n1.x < n2.x) ? 1 : -1);
                    }
                    y = n1.y + (above ? -1 : +1);
                }
                else {
                    int min = MIN(n1.x, n2.x);
                    if (left) { // 4 & 5
                        printf("LF SETTING %s %s %s AND %s\n", user.desc, "LEFT", first.desc, second.desc);
                        x = min - 1;
                        y = (n1.x == min) ? n2.y : n1.y;
                    }
                    else { // 1 & 2
                        printf("RT SETTING %s %s %s AND %s\n", user.desc, "RIGHT", first.desc, second.desc);
                        x = min + 1;
                        y = (n1.x == min) ? n1.y : n2.y;
                    }
                }
                
                
                user.coords = CGPointMake(x,y);
            } while (condition);
            
            [sortedUsers addObject:user];
            
            //        PFGeoPoint *g = user.location;
            //        g.latitude += (((int) (arc4random()%10000-5000)) / 10000000.0f);
            //        g.longitude += (((int) (arc4random()%10000-5000)) / 10000000.0f);
        }
    }];
}

- (NSArray*) usersWithQuad:(int)quad from:(PFUser*)start users:(NSArray*)users
{
    NSMutableArray *res = [NSMutableArray array];
    
    [users enumerateObjectsUsingBlock:^(PFUser* _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        if (start != user && Quad(start, user) == quad) {
            [res addObject:user];
        }
    }];
    
    return res;
}


- (void) createHives
{
    NSArray *names = @[@"가리온", @"가은", @"강다이", @"고루나", @"고운비", @"그레", @"그리미", @"글샘", @"기찬", @"길한", @"나나", @"나도람", @"나슬", @"난새", @"난한벼리", @"내누리", @"누니", @"늘새찬", @"늘품", @"늘해찬", @"다보라", @"다소나", @"다솜", @"다슴", @"다올", @"다조은", @"달래울", @"달비슬", @"대누리", @"드레", @"말그미", @"모도리", @"무아", @"미리내", @"미슬기", @"바다", @"바로", @"바우", @"밝음이", @"별아", @"보다나", @"봄이", @"비치", @"빛들", @"빛새온", @"빛찬온", @"사나래", @"새라", @"새로나", @"새미라", @"새하", @"샘나", @"소담", @"소란", @"솔다우니", @"슬미", @"아늘", @"아로미", @"아름이", @"아림", @"아음", @"애리", @"여슬", @"영아름", @"예달", @"온비", @"정다와", @"정아라미", @"조은", @"지예", @"진아", @"차니", @"찬샘", @"찬아람", @"참이", @"초은", @"파라", @"파랑", @"푸르나", @"푸르내", @"풀잎", @"하나", @"하나슬", @"하리", @"하은", @"한진이", @"한비", @"한아름", @"해나", @"해슬아", @"희라"];
    
    self.origin = @{ @"location" : [PFGeoPoint geoPointWithLatitude:37.52016263966829 longitude:127.0290097641595],
                     @"idx" : @(0)};
    
    int i = 1;
    for (NSString *name in names) {
        float dx = ((long)(arc4random()%10000)-5000)/1000000.0;
        float dy = ((long)(arc4random()%10000)-5000)/1000000.0;
        
        PFGeoPoint *loc =  [PFGeoPoint geoPointWithLatitude:(37.52016263966829+dx) longitude:(127.0290097641595+dy)];
        PFUser *user = [self newUserName:name location:loc photoIndex:i++];
        [self.hives addObject:user];
    }
}


- (PFUser *) newUserName:(NSString*)name location:(PFGeoPoint*)geoLocation photoIndex:(int)idx
{
    NSLog(@"CREATING USER:%@ LO:%@ IDX:%d", name, geoLocation, idx);
    
    long age = 20+ arc4random()%30;
    
    NSString *username = [[NSUUID UUID] UUIDString];
    PFUser *user = [PFUser user];
    
    user = [PFUser user];
    user.username = username;
    user.password = username;
    
    user.nickname = name;
    user.location = geoLocation;
    user[@"isSimulated"] = @(YES);
    user[AppKeyAgeKey] = [NSString stringWithFormat:@"%ld살", age];
    user[AppKeyIntroKey] = AppProfileIntroductions[arc4random()%(AppProfileIntroductions.count)];
    
    BOOL ret = [user signUp];
    
    if (ret) {
        PFUser *loggedIn = [PFUser logInWithUsername:user.username password:user.password];
        if (!loggedIn) {
            NSLog(@"Error: FAILED TO LOGIN AS :%@", loggedIn);
        }
        else {
            NSLog(@"SETTING UP PROFILE IMAGE FOR %@", name);
            
            NSString* imageName = [NSString stringWithFormat:@"image%d", idx];
            UIImage *image = [UIImage imageNamed:imageName];
            
            CGSize size = CGSizeMake(60, 60);
            
            CALayer *layer = [CALayer layer];
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width, image.size.width), false, 0.0);
            layer.frame = CGRectMake(0, 0, image.size.width, image.size.width);
            layer.contents = (id) image.CGImage;
            layer.contentsGravity = kCAGravityBottom;
            layer.masksToBounds = YES;
            [layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImage *profilePhoto = scaleImage(newImage, size);
            UIImage *originalPhoto = scaleImage(newImage, CGSizeMake(1024, 1024));
            
            NSData *smallData = UIImageJPEGRepresentation(profilePhoto, AppProfilePhotoCompression);
            NSData *largeData = UIImageJPEGRepresentation(originalPhoto, AppProfilePhotoCompression);
            
            PFFile *file = [PFFile fileWithName:AppProfilePhotoFileName data:smallData];
            BOOL fs = [file save];
            
            NSLog(@"FILE LOC:%@", file.url);
            PFFile *orig = [PFFile fileWithName:AppProfileOriginalPhotoFileName data:largeData];
            BOOL os = [orig save];
            
            NSLog(@"FILES %@SUCCESSFULLY SAVED", fs & os ? @"" : @"UN");
            loggedIn.profilePhoto = file;
            loggedIn.originalPhoto = orig;
            BOOL userSaved = [loggedIn save];
            NSLog(@"USER %@SUCCESSFULLY SAVED", userSaved ? @"" : @"UN");
        }
    }
    else {
        NSLog(@"ERROR SIGNINGUP USER");
    }
    
    return user;
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

