//
//  NearCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 12..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "NearCell.h"
#import "S3File.h"

@interface NearCell()
@property (weak, nonatomic) IBOutlet UIView *back;
@property (weak, nonatomic) IBOutlet UIView *photo;
@end

@implementation NearCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.back.layer.cornerRadius = 2.0f;
    self.back.layer.masksToBounds = YES;
}
- (void)setUser:(User *)user
{
    _user = user;
    [self.user fetched:^{
        NSData *data = [S3File objectForKey:self.user.thumbnail];
        if (data) {
            drawImage([UIImage imageWithData:data], self.photo);
        }
        else {
            [S3File getDataFromFile:self.user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                if (error || !data) {
                    drawImage(self.user.sexImage, self.photo);
                }
                else {
                    drawImage([UIImage imageWithData:data], self.photo);
                }
            }];
        }
    }];
}

@end
