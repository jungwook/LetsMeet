//
//  FS.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 18..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "FS.h"

@interface FS ()

@end

@implementation FS

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURLSessionConfiguration * defaultSession = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:defaultSession delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSString *url1 = @"https://api.foursquare.com/v2/venues/explore?client_id=5P1OVCFK0CCVCQ5GBBCWRFGUVNX5R4WGKHL2DGJGZ32FDFKT&client_secret=UPZJO0A0XL44IHCD1KQBMAYGCZ45Z03BORJZZJXELPWHPSAR&v=20160718&ll=37.52,127.03&limit=20&skip=20";
    NSString *url2 = @"https://api.foursquare.com/v2/venues/4b55a3d0f964a5200dea27e3/photos?client_id=5P1OVCFK0CCVCQ5GBBCWRFGUVNX5R4WGKHL2DGJGZ32FDFKT&client_secret=UPZJO0A0XL44IHCD1KQBMAYGCZ45Z03BORJZZJXELPWHPSAR&v=20160718&ll=37.52,127.03&limit=20&skip=20";
    NSString *url3 = @"https://api.foursquare.com/v2/venues/4bf7d44a508c0f47da083e31?client_id=5P1OVCFK0CCVCQ5GBBCWRFGUVNX5R4WGKHL2DGJGZ32FDFKT&client_secret=UPZJO0A0XL44IHCD1KQBMAYGCZ45Z03BORJZZJXELPWHPSAR&v=20160718&ll=37.52,127.03&limit=20&skip=20";
    
    [[delegateFreeSession dataTaskWithURL: [NSURL URLWithString:url3]
                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                            NSLog(@"Got response %@ with error %@.\n", response, error);
                            NSError *jsonError;
                            NSMutableDictionary *dJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                            NSLog(@"FULL:%@", dJSON);
                            [self exploreJSON:dJSON index:0];
                        }] resume];
}

- (NSString*) spacesForIndex:(NSInteger)index
{
    NSString* app = @"->";
    NSString *spaces = @"";
    for (int i=0; i<index; i++) {
        spaces = [spaces stringByAppendingString:app];
    }
    return spaces;
}

- (void) exploreJSON:(id)d index:(NSInteger)index
{
    if ([d isKindOfClass:[NSDictionary class]]) {
        [[d allKeys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id n = d[obj];
            BOOL isArray = [n isKindOfClass:[NSArray class]];
            if (isArray) {
                printf("\n%s[%s]", [[self spacesForIndex:index] UTF8String], [obj UTF8String]);
            } else {
                printf("\n%s%s", [[self spacesForIndex:index] UTF8String], [obj UTF8String]);
            }
            [self exploreJSON:d[obj] index:index+1];
        }];
        
    } else if ([d isKindOfClass:[NSArray class]]) {
        [self exploreJSON:[d firstObject] index:index];
    } else {
        NSString *ds;
        if ([d isKindOfClass:[NSNumber class]]) {
            ds = [d stringValue];
        }
        else {
            ds = d;
        }
        printf(": %s", [ds UTF8String]);
    }
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
