//
//  UserLikesCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserLikesCell.h"
#import "S3File.h"

@interface UserLikesCell()
@property (weak, nonatomic) IBOutlet UIButton *photo;
@end

@implementation UserLikesCell

- (void)awakeFromNib
{
    roundCorner(self.photo);
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setUser:(User *)user
{
    _user = user;
    [self.user fetched:^{
        NSData* data = [S3File objectForKey:self.user.thumbnail];
        if (data) {
            [self.photo setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        }
        else {
            [S3File getDataFromFile:self.user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                if (data && !error) {
                    [self.photo setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                }
                else {
                    [self.photo setImage:user.sexImage forState:UIControlStateNormal];
                }
            }];
        }
    }];
}

- (IBAction)tappedUser:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(userLikesCell:selectUser:)]) {
        [self.delegate userLikesCell:self selectUser:self.user];
    }
}

@end
