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
#import "MediaViewer.h"

#define CHATVIEWINSET 8

@interface ChatRight()
@property (weak, nonatomic) IBOutlet Balloon *balloon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacing;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet IndentedLabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *playView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailing;
@property (weak, nonatomic) IBOutlet UIImageView *realIcon;
@property (nonatomic) MediaTypes mediaType;
@property (nonatomic) ProfileMediaTypes profileMediaType;
@property (nonatomic, strong) id mediaFile;
@property (nonatomic, strong) id profileMediaFile;
@property (nonatomic, strong) id messageId;
@end

@implementation ChatRight

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.balloon setIsMine:YES];
    
    self.photoView.layer.cornerRadius = 20.f;
    self.photoView.layer.masksToBounds = YES;
    self.thumbnailView.layer.contentsGravity = kCAGravityResizeAspect;
    self.playView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.playView.layer.shadowOffset = CGSizeZero;
    self.playView.layer.shadowRadius = 2.0f;
    self.playView.layer.shadowOpacity = 0.3;

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
    [MediaViewer showMediaFromView:tap.view filename:self.profileMediaFile mediaType:mediaTypeFromProfileMediaTypes(self.profileMediaType)];
}

- (void) tappedThumbnailView:(UITapGestureRecognizer*)tap
{
    [MediaViewer showMediaFromView:tap.view filename:self.mediaFile mediaType:self.mediaType];
}

- (void)setMessage:(Bullet *)message user:(User*)user tableView:(UITableView*)tableView
{
    _messageId = message.objectId;
    
    _profileMediaType = user.profileMediaType;
    _profileMediaFile = user.profileMedia;
    
    _mediaType = message.mediaType;
    _mediaFile = message.mediaFile;

    self.dateLabel.text = message.createdAt.timeAgo;
    self.nicknameLabel.text = user.nickname;
    
    [S3File getDataFromFile:user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        if (!error) {
            self.photoView.layer.contents = (id) [UIImage imageWithData:data].CGImage;
        }
    } progressBlock:nil];

    self.thumbnailView.hidden = YES;
    self.realIcon.hidden = YES;
    
    switch (message.mediaType) {
        case kMediaTypeText: {
            NSString *string = [message.message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            CGRect rect = rectForString(string, [UIFont boldSystemFontOfSize:17], kThumbnailWidth);
            self.spacing.constant = self.contentView.bounds.size.width-rect.size.width-(self.trailing.constant+CHATVIEWINSET+CHATVIEWINSET);
            self.messageLabel.text = string;
        }
            break;
        case kMediaTypeVideo:
        case kMediaTypePhoto: {
            self.playView.hidden = (message.mediaType == kMediaTypePhoto);
            self.realIcon.hidden = !(message.realMedia);
            [S3File getDataFromFile:message.mediaThumbnailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                if (!error) {
                    if (fromCache) {
                        [self setupThumbnailImageWithData:data];
                    }
                    else {
                        [[tableView visibleCells] enumerateObjectsUsingBlock:^(ChatRight* _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
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
        self.spacing.constant = self.contentView.bounds.size.width-kThumbnailWidth-(self.trailing.constant+CHATVIEWINSET+CHATVIEWINSET);
        self.thumbnailView.layer.contents = (id) thumbnailImage.CGImage;
    });
}

@end
