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

@end

@implementation NearByCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

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

-(void)setUser:(User *)user collectionView:(UICollectionView *)collectionView
{
    static NSData *placeholder = nil;
    
    if (!placeholder) {
        placeholder = UIImageJPEGRepresentation([UIImage imageNamed:@"girl"], 1.0f);
    }
    _user = user;

    double distance = [[User me].location distanceInKilometersTo:self.user.location];
    
    self.nicknameLB.text = self.user.nickname;
    self.ageLB.text = self.user.age;
    self.sexLB.text = self.user.sexString;
    self.introLB.text = self.user.intro;
    self.distanceLB.text = [self distanceString:distance];
    self.photoView.contentMode = UIViewContentModeScaleAspectFill;
    
    id filename = self.user.profileMediaType == kProfileMediaPhoto ? self.user.profileMedia : self.user.thumbnail;
    filename = self.user.thumbnail;
    
    NSData *imageData = [S3File objectForKey:filename];
    if (imageData) {
        [self setUserProfileImageWithData:imageData animate:NO];
    }
    else {
        [self setUserProfileImageWithData:placeholder animate:NO];
        [S3File getDataFromFile:filename completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            if (!fromCache) {
                NSArray *visibles = [collectionView visibleCells];
                [visibles enumerateObjectsUsingBlock:^(NearByCell* _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([cell.user.objectId isEqualToString:user.objectId]) {
                        *stop = YES;
                        [self setUserProfileImageWithData:data animate:YES];
                    }
                }];
            }
        } progressBlock:^(int percentDone) {
            
        }];
    }
}

- (void)setUserProfileImageWithData:(NSData *)data animate:(BOOL)animate
{
    if (animate) {
        [UIView animateWithDuration:0.2 animations:^{
            self.photoView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.photoView.layer.contents = (id) [UIImage imageWithData:data].CGImage;
            [UIView animateWithDuration:0.1f animations:^{
                self.photoView.alpha = 1.0f;
            }];
        }];
    }
    else {
        self.photoView.alpha = 1.0f;
        self.photoView.layer.contents = (id) [UIImage imageWithData:data].CGImage;
    }
}

@end
