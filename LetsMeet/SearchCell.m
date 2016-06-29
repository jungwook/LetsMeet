//
//  SearchCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 23..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SearchCell.h"
#import "IndentedLabel.h"
#import "MediaViewer.h"

@interface SearchCell()
@property (weak, nonatomic) IBOutlet IndentedLabel *distance;
@property (weak, nonatomic) IBOutlet IndentedLabel *badge;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *intro;
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (strong, nonatomic) FileSystem *system;
@property (strong, nonatomic) id userId;
@end

@implementation SearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.system = [FileSystem new];
    
    [self setCornerRadiusOnView:self.photo radius:2.0f];
    [self setCornerRadiusOnView:self.distance radius:2.0f];
    [self setCornerRadiusOnView:self.badge radius:2.0f];
}

- (void) setCornerRadiusOnView:(UIView*) view radius:(CGFloat)radius;
{
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}

- (void) setUser:(User*)user tableView:(UITableView*)tableView
{
    if (![self.userId isEqualToString:user.objectId]) {
        self.userId = user.objectId;
        
        NSInteger count = [self.system unreadMessagesFromUser:user.objectId];
        self.badge.hidden = !count;
        double distance = [self.system.location distanceInKilometersTo:user.location];
        
        self.badge.text = [NSString stringWithFormat:@"%ld", count];
        self.distance.text = distanceString(distance);
        self.nickname.text = user.nickname;
        self.intro.text = user.intro;
        
        [self.photo loadMediaFromUser:user completion:^(NSData *data, NSError *error, BOOL fromCache) {
            UIImage *photo = [UIImage imageWithData:data];
            if (fromCache && data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.photo.image = photo;
                });
            }
            else {
                NSArray *visible = [tableView visibleCells];
                [visible enumerateObjectsUsingBlock:^(SearchCell* _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([cell.userId isEqualToString:user.objectId]) {
                        *stop = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.photo.image = photo;
                        });
                    }
                }];
            }
        }];
    }
}

@end
