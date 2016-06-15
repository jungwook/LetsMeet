//
//  ChatLeft.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ChatLeft.h"
#import "Balloon.h"
#import "S3File.h"
#import "NSDate+TimeAgo.h"
#import "PhotoViewer.h"

@interface ChatLeft()
@property (weak, nonatomic) IBOutlet Balloon *balloon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacing;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *playView;
@property (nonatomic) BulletTypes mediaType;
@property (nonatomic) ProfileMediaTypes profileMediaType;
@property (nonatomic, strong) id mediaFile;
@property (nonatomic, strong) id profileMediaFile;
@property (nonatomic, strong) id messageId;
@end

@implementation ChatLeft

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.balloon setIsMine:NO];
    
    self.photoView.layer.cornerRadius = 20.f;
    self.photoView.layer.masksToBounds = YES;
    self.thumbnailView.layer.contentsGravity = kCAGravityResizeAspectFill;
    
    if (![self.photoView.gestureRecognizers count]) {
        [self.photoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedPhotoView:)]];
    }
    
    self.thumbnailView.userInteractionEnabled = YES;
    if (![self.thumbnailView.gestureRecognizers count]) {
        [self.thumbnailView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedThumbnailView:)]];
    } else {
        NSLog(@"GESTURES:%@", self.thumbnailView.gestureRecognizers);
    }

}

- (void) tappedPhotoView:(UITapGestureRecognizer*)tap
{
    NSLog(@"Tapped Photo");
    [PhotoViewer showMediaFromView:tap.view filename:self.profileMediaFile isPhoto:(self.profileMediaType == kProfileMediaPhoto)];
}

- (void) tappedThumbnailView:(UITapGestureRecognizer*)tap
{
    NSLog(@"Tapped Thumbnail:%@", tap);
    [PhotoViewer showMediaFromView:tap.view filename:self.mediaFile isPhoto:(self.mediaType == kBulletTypePhoto)];
}

- (void)setMessage:(Bullet *)message user:(User*)user tableView:(UITableView*)tableView
{
    _messageId = message.objectId;
    
    _profileMediaType = user.profileMediaType;
    _profileMediaFile = user.profileMedia;
    
    _mediaType = message.bulletType;
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
                    if (fromCache) {
                        [self setupThumbnailImageWithData:data];
                    }
                    else {
                        [[tableView visibleCells] enumerateObjectsUsingBlock:^(ChatLeft* _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([cell.messageId isEqualToString:self.messageId]) {
                                *stop = YES;
                                [self setupThumbnailImageWithData:data];
                            }
                        }];
                    }
                }
            } progressBlock:nil];
        }
            break;
        default:
            break;
    }
}

- (void)setupThumbnailImageWithData:(NSData*) data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.thumbnailView.hidden = NO;
        UIImage *thumbnailImage = [UIImage imageWithData:data];
        self.spacing.constant = self.contentView.bounds.size.width-240-85;
        self.thumbnailView.layer.contents = (id) thumbnailImage.CGImage;
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
