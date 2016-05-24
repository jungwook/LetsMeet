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

@interface Octagon ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) AppEngine *engine;
@property (strong, nonatomic) NSMutableArray *hives;
@property (strong, nonatomic) id origin;
@property (strong, nonatomic) NSMutableArray *coords;
@end

@implementation Octagon

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hives = nil;
        self.engine = [AppEngine engine];
        self.coords = [NSMutableArray array];
    }
    return self;
}

- (void) incrementQuad:(NSString*) quad withX:(CGFloat*)x withY:(CGFloat*)y
{
    if ([quad isEqualToString:@"Q0"]) { *x += 1, *y -= 1.5;}
    else if ([quad isEqualToString:@"Q1"]) { *x += 2, *y += 0;}
    else if ([quad isEqualToString:@"Q2"]) { *x += 1, *y += 1.5;}
    else if ([quad isEqualToString:@"Q3"]) { *x -= 1, *y += 1.5;}
    else if ([quad isEqualToString:@"Q4"]) { *x -= 2, *y +=  0;}
    else if ([quad isEqualToString:@"Q5"]) { *x -= 1, *y -= 1.5;}
}
- (NSString*) antiQuad:(NSString *) quad
{
    NSString *anti;
    if ([quad isEqualToString:@"Q0"]) { anti = @"Q3"; }
    else if ([quad isEqualToString:@"Q1"]) { anti = @"Q4"; }
    else if ([quad isEqualToString:@"Q2"]) { anti = @"Q5"; }
    else if ([quad isEqualToString:@"Q3"]) { anti = @"Q0"; }
    else if ([quad isEqualToString:@"Q4"]) { anti = @"Q1"; }
    else if ([quad isEqualToString:@"Q5"]) { anti = @"Q2"; }

    return anti;
}

#define CSTR(XXX) ((NSString*)XXX).UTF8String
#define Q(XXX) [NSString stringWithFormat:@"Q%d", XXX]
#define PQ(XXX) ((XXX+6-1) % 6)
#define NQ(XXX) ((XXX+1) %6)
#define AQ(XXX) ((quad+3) % 6)

- (int) nextAvailQuad:(PFUser *)user
{
    for (int i=0; i<6; i++) {
        if (!user[Q(i)]) {
            return i;
        }
    }
    return -1;
}

- (NSString*) seekSpaceForUser:(PFUser*)user from:(PFUser*)from quad:(int)quad incx:(CGFloat)x incy:(CGFloat)y
{
    int aq = AQ(quad);
    
    int nextQ = Quand(
    if ([self.coords containsObject:Q(quad)]) {
        
        
    }
    else {
        [self.coords addObject:Q(quad)];
        return Q(quad);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(2000, 2000);
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentOffset = [self centerViewPort];

//    [self createHives]; // CREATING NEW USERS... DO NOT USE...
    
    [self loadUsersNearMeInBackground:^(NSArray *users) {
        self.hives = [NSMutableArray arrayWithArray:users];
        PFUser* root = [PFUser currentUser];
        root[@"QROOT"] = root;
        root[@"xInc"] = @(0);
        root[@"yInc"] = @(0);
        
        Hive *hive = [Hive new];
        hive.user = root;
        hive.centerPoint = CGPointMake(1000, 1000);
        CGFloat radius = 30;
        CGPoint centerPoint = CGPointMake(1000, 1000);
        CGFloat cx = centerPoint.x, cy = centerPoint.y;
        CGFloat x = cx+(-0.5f)*radius;
        CGFloat y = cy+(-0.5f)*radius;
        hive.frame = CGRectMake(x, y, 1.7*radius, 1.7*radius);
        hive.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:1.0 alpha:0.4];

        [self.scrollView addSubview:hive];
        [[self scrollView] setNeedsLayout];
        [hive setNeedsLayout];
        
        for (PFUser* user in self.hives) {
            int quad = Quad(root[AppKeyLocationKey], user[AppKeyLocationKey]);
            printf("\nWORKING WITH [%s/%s] %s\n", CSTR(user[AppKeyNicknameKey]), CSTR(user.objectId), CSTR(Q(quad)));
            
            [self seekSpaceForUser:user from:root quad:quad incx:0 incy:0];
            CGFloat incX = [user[@"xInc"] floatValue], incY = [user[@"yInc"] floatValue];
            
            Hive *hive = [Hive new];
            hive.user = user;
            hive.centerPoint = CGPointMake(1000, 1000);
            CGFloat radius = 30;
            CGPoint centerPoint = CGPointMake(1000, 1000);
            CGFloat cx = centerPoint.x, cy = centerPoint.y;
            CGFloat x = cx+(incX-0.5f)*radius;
            CGFloat y = cy+(incY-0.5f)*radius;
            hive.frame = CGRectMake(x, y, 1.7*radius, 1.7*radius);
            [self.scrollView addSubview:hive];
            [[self scrollView] setNeedsLayout];
        }
        NSLog(@"NOW WILL LAYOUT SUBVIEWS");
    }];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    NSLog(@"WILL LAYOUT SUBVIEWS" );
}

- (void) loadUsersNearMeInBackground:(ArrayResultBlock)block
{
    PFQuery *query = [PFUser query];
    [query whereKey:AppKeyLocationKey nearGeoPoint:[self.engine currentLocation]];
    [query whereKey:AppKeyObjectId notEqualTo:[PFUser currentUser].objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR LOADING USERS NEAR ME:%@", error.localizedDescription);
        }
        else {
            if (block) {
                block(users);
            }
            else {
                self.hives = [NSMutableArray arrayWithArray:users];
            }
        }
    }];
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
    
    user[AppKeyNicknameKey] = name;
    user[AppKeyLocationKey] = geoLocation;
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
            loggedIn[AppProfilePhotoField] = file;
            loggedIn[AppProfileOriginalPhotoField] = orig;
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
