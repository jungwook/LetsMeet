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
@property (nonatomic, strong) User* user;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@end

@implementation UserLikesCell

- (void)awakeFromNib
{
    self.photo.layer.cornerRadius = 4.0f;
    self.photo.layer.masksToBounds = YES;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    self.nickname.textColor = titleColor;
}

- (void)setUser:(User *)user
{
    _user = user;

    [S3File getDataFromFile:self.user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        if (data && !error) {
            [self.photo setImage:[UIImage imageWithData:data]];
        }
        else {
            [self.photo setImage:user.sexImage];
        }
    }];
    
    self.nickname.text = self.user.nickname;
}

@end
