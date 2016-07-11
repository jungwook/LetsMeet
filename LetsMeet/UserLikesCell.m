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
@property (weak, nonatomic) IBOutlet UIButton *photo;
@property (weak, nonatomic) UserMediaCollection *parent;
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

- (void)setUser:(User *)user parent:(UserMediaCollection *)parent
{
    _user = user;
    _parent = parent;

    [S3File getDataFromFile:self.user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        if (data && !error) {
            [self.photo setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        }
        else {
            [self.photo setImage:user.sexImage forState:UIControlStateNormal];
        }
    }];
}

- (IBAction)tappedUser:(id)sender
{
    [self.parent tappedOnLikeUser:self.user];
}

@end
