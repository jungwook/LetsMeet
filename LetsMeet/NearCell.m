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
@property (weak, nonatomic) IBOutlet UIButton *photo;
@end

@implementation NearCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    roundCorner(self.back);
    self.back.userInteractionEnabled = NO;
}

- (void)setUser:(User *)user
{
    _user = user;
    [self.user fetched:^{
        NSData *data = [S3File objectForKey:self.user.thumbnail];
        if (data) {
            [self.photo setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        }
        else {
            [S3File getDataFromFile:self.user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                if (error || !data) {
                    [self.photo setImage:self.user.sexImage forState:UIControlStateNormal];
                }
                else {
                    [self.photo setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                }
            }];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.photo.highlighted = YES;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    self.photo.highlighted = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.photo.highlighted = NO;
}


@end
