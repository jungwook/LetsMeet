//
//  SimulatedUsers.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 29..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SimulatedUsers.h"
#import "NSMutableDictionary+Bullet.h"
#import "S3File.h"

@implementation SimulatedUsers

+ (void) createUsers
{
    [[SimulatedUsers new] createUsers];
}

+ (void) resetUsers
{
    PFQuery *query = [User query];
    
    [query whereKey:@"isSimulated" equalTo:@(YES)];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        [users enumerateObjectsUsingBlock:^(User*  _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *name = user.username;
            PFUser *loggedIn = [PFUser logInWithUsername:name password:name];
            if (!loggedIn) {
                NSLog(@"Error: FAILED TO LOGIN AS :%@", loggedIn);
            }
            else {
                NSLog(@"SETTING UP PROFILE IMAGE FOR %@", user.nickname);
                PFFile* file = loggedIn[@"originalPhoto"];
                NSString *filename = [@"ParseFiles/" stringByAppendingString:file.name];
                loggedIn[@"profileMedia"] = filename;
                [loggedIn save];
                [PFUser logOut];
            }
        }];
    }];
}

- (void) createUsers
{
    NSArray *names = @[@"가리온", @"가은", @"강다이", @"고루나", @"고운비", @"그레", @"그리미", @"글샘", @"기찬", @"길한", @"나나", @"나도람", @"나슬", @"난새", @"난한벼리", @"내누리", @"누니", @"늘새찬", @"늘품", @"늘해찬", @"다보라", @"다소나", @"다솜", @"다슴", @"다올", @"다조은", @"달래울", @"달비슬", @"대누리", @"드레", @"말그미", @"모도리", @"무아", @"미리내", @"미슬기", @"바다", @"바로", @"바우", @"밝음이", @"별아", @"보다나", @"봄이", @"비치", @"빛들", @"빛새온", @"빛찬온", @"사나래", @"새라", @"새로나", @"새미라", @"새하", @"샘나", @"소담", @"소란", @"솔다우니", @"슬미", @"아늘", @"아로미", @"아름이", @"아림", @"아음", @"애리", @"여슬", @"영아름", @"예달", @"온비", @"정다와", @"정아라미", @"조은", @"지예", @"진아", @"차니", @"찬샘", @"찬아람", @"참이", @"초은", @"파라", @"파랑", @"푸르나", @"푸르내", @"풀잎", @"하나", @"하나슬", @"하리", @"하은", @"한진이", @"한비", @"한아름", @"해나", @"해슬아", @"희라"];
    
    int i = 1;
    for (NSString *name in names) {
        float dx = ((long)(arc4random()%10000)-5000)/1000000.0;
        float dy = ((long)(arc4random()%10000)-5000)/1000000.0;
        
        PFGeoPoint *loc =  [PFGeoPoint geoPointWithLatitude:(37.52016263966829+dx) longitude:(127.0290097641595+dy)];
        [self newUserName:name location:loc photoIndex:i++];
    }
}

#define AppProfileIntroductions @[@"우리 만나요!", @"애인 찾아요", @"함께 드라이브"]
#define AppProfileSexSelections @[@"남자", @"여자"]
#define AppProfileAgeSelections @[@"20대", @"30대", @"40대", @"50대"]

- (void) newUserName:(NSString*)name location:(PFGeoPoint*)geoLocation photoIndex:(int)idx
{
    NSLog(@"CREATING USER:%@ LO:%@ IDX:%d", name, geoLocation, idx);
    
    long age = 20+ arc4random()%30;
    
    User *user = [User user];
    
    user.username = name;
    user.password = name;
    
    user.nickname = name;
    user.location = geoLocation;
    user.isSimulated = YES;
    
    user.age = [NSString stringWithFormat:@"%ld살", age];
    user.intro = AppProfileIntroductions[arc4random()%(AppProfileIntroductions.count)];
    user.sex = kSexFemale;
    
    BOOL ret = [user signUp];
    
    if (ret) {
        User *loggedIn = [User logInWithUsername:user.username password:user.password];
        if (!loggedIn) {
            NSLog(@"Error: FAILED TO LOGIN AS :%@", loggedIn);
        }
        else {
            NSLog(@"SETTING UP PROFILE IMAGE FOR %@", name);
            
            NSString* imageName = [NSString stringWithFormat:@"image%d", idx];
            UIImage *image = [UIImage imageNamed:imageName];
            
            CALayer *layer = [CALayer layer];
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width, image.size.width), false, 0.0);
            layer.frame = CGRectMake(0, 0, image.size.width, image.size.width);
            layer.contents = (id) image.CGImage;
            layer.contentsGravity = kCAGravityBottom;
            layer.masksToBounds = YES;
            [layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImage *originalPhoto = scaleImage(newImage, CGSizeMake(1024, 1024));
            
            NSData *largeData = UIImageJPEGRepresentation(originalPhoto, kJPEGCompressionMedium);
            NSData *tnData = compressedImageData(largeData, 100);
            
            NSString *oFN = [loggedIn.objectId stringByAppendingString:@".jpg"];
            NSString *tFN = [loggedIn.objectId stringByAppendingString:@"TN.jpg"];
            
            loggedIn.profileMedia = [S3File saveData:largeData named:@"profile" extension:@".jpg" group:@"ProfileMedia" completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"saved profile media [%@/%ld] for %@/%@ ", oFN, largeData.length, loggedIn.username, loggedIn.objectId);
                }
            } progressBlock:nil];
            
            loggedIn.thumbnail = [S3File saveData:tnData named:@"thumbnail" extension:@".jpg" group:@"ProfileMedia" completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"saved thumbnail [%@/%ld] for %@/%@ ", tFN, tnData.length, loggedIn.username, loggedIn.objectId);
                }
            } progressBlock:nil];
            [loggedIn save];
        }
    }
    else {
        NSLog(@"ERROR SIGNINGUP USER");
    }
}

- (NSString*) fullname:(NSString*)filename
{
    return [@"ProfileMedia/" stringByAppendingString:filename];
}


@end
