//
//  ChatRight.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ChatRight.h"
#import "Balloon.h"
#import "S3File.h"
#import "NSDate+TimeAgo.h"

@interface ChatRight()
@property (weak, nonatomic) IBOutlet Balloon *balloon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacing;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *playView;
@property (nonatomic, strong) id mediaFile;
@property (nonatomic) BulletTypes bulletType;
@property (nonatomic, strong) id messageId;
@end

@implementation ChatRight

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.balloon setIsMine:YES];
    
    self.photoView.layer.cornerRadius = 2.0f;
    self.photoView.layer.masksToBounds = YES;
    self.thumbnailView.layer.contentsGravity = kCAGravityResizeAspectFill;
    
    if (![self.photoView.gestureRecognizers count]) {
        [self.photoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedPhotoView:)]];
    }
    
    if (![self.thumbnailView.gestureRecognizers count]) {
        [self.thumbnailView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedThumbnailView:)]];
    }
}

- (void) tappedPhotoView:(id)sender
{
    NSLog(@"Tapped Photo");
}

- (void) tappedThumbnailView:(id)sender
{
    NSLog(@"Tapped Thumbnail");
}

- (void)setMessage:(Bullet *)message user:(User*)user tableView:(UITableView*)tableView
{
    _messageId = message.objectId;
    _bulletType = message.bulletType;
    _mediaFile = message.mediaFile;

    self.dateLabel.text = message.createdAt.timeAgo;
    [S3File getDataFromFile:user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        if (!error) {
            self.photoView.layer.contentsGravity = kCAGravityResizeAspectFill;
            self.photoView.layer.contents = (id) [UIImage imageWithData:data].CGImage;
        }
    } progressBlock:nil];

    self.thumbnailView.hidden = YES;
    
    switch (message.bulletType) {
        case kBulletTypeText: {
            NSString *string = [message.message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            CGRect rect = rectForString(string, [UIFont boldSystemFontOfSize:17], 280);
            self.spacing.constant = self.contentView.bounds.size.width-rect.size.width-85;
            self.messageLabel.text = string;
        }
            break;
        case kBulletTypeVideo:
        case kBulletTypePhoto: {
            self.playView.hidden = (message.bulletType == kBulletTypePhoto);
            [S3File getDataFromFile:message.mediaThumbnailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                if (!error) {
                    [[tableView visibleCells] enumerateObjectsUsingBlock:^(ChatRight* _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([self.messageId isEqualToString:message.objectId]) {
                            *stop = YES;
                            self.thumbnailView.hidden = NO;
                            UIImage *thumbnailImage = [UIImage imageWithData:data];
                            self.spacing.constant = self.contentView.bounds.size.width-240-85;
                            self.thumbnailView.layer.contents = (id) thumbnailImage.CGImage;
                        }
                    }];

                }
            } progressBlock:nil];
        }
            break;
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
