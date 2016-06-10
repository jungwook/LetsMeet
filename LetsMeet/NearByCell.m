//
//  NearByCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 10..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "NearByCell.h"
#import "IndentedLabel.h"
#import "S3File.h"

@interface NearByCell()
@property (weak, nonatomic) IBOutlet UILabel *nicknameLB;
@property (weak, nonatomic) IBOutlet UILabel *introLB;
@property (weak, nonatomic) IBOutlet UILabel *sexLB;
@property (weak, nonatomic) IBOutlet UILabel *ageLB;
@property (weak, nonatomic) IBOutlet IndentedLabel *distanceLB;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (nonatomic, strong) SetUserBlock block;
@end

@implementation NearByCell

- (NSString*) distanceString:(double)distance
{
    if (distance > 500) {
        return [NSString stringWithFormat:@"TOO FAR!"];
    }
    else if (distance < 1.0f) {
        return [NSString stringWithFormat:@"%.0fm", distance*1000];
    }
    else {
        return [NSString stringWithFormat:@"%.0fkm", distance];
    }
}

-(void)setUser:(User *)user completion:(SetUserBlock)block
{
    _user = user;
    _block = block;

    double distance = [[User me].location distanceInKilometersTo:self.user.location];
    
    self.nicknameLB.text = self.user.nickname;
    self.ageLB.text = self.user.age;
    self.sexLB.text = self.user.sexString;
    self.introLB.text = self.user.intro;
    self.distanceLB.text = [self distanceString:distance];

    [S3File getDataFromFile:self.user.profileMediaType == kProfileMediaPhoto ? self.user.profileMedia : self.user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        if (fromCache) {
            [self setUserProfileImageWithData:data];
        }
        if (!error) {
            if (self.block) {
                self.block(self.user, data);
            }
        }
    } progressBlock:^(int percentDone) {
        
    }];
}

- (void)setUserProfileImageWithData:(NSData *)data
{
    self.photoView.layer.contents = (id) [UIImage imageWithData:data].CGImage;
    self.photoView.layer.contentsGravity = kCAGravityResizeAspectFill;
}

@end
