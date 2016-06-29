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
#import "AudioPlayer.h"

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
@property (nonatomic) MediaTypes mediaType;
@property (nonatomic) ProfileMediaTypes profileMediaType;
@property (nonatomic) BOOL isReal;
@property (nonatomic, strong) id mediaFile;
@property (nonatomic, strong) id profileMediaFile;
@property (nonatomic, strong) id messageId;
@property (weak, nonatomic) IBOutlet UIView *audioView;
@property (strong, nonatomic) AudioPlayer *audioPlayer;
@end

@implementation ChatRight

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.balloon setIsMine:YES];
    
    self.photoView.layer.cornerRadius = 20.f;
    self.photoView.layer.masksToBounds = YES;
    self.thumbnailView.layer.contentsGravity = kCAGravityResizeAspect;

    if (![self.photoView.gestureRecognizers count]) {
        [self.photoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedPhotoView:)]];
    }
    
    self.thumbnailView.userInteractionEnabled = YES;
    if (![self.thumbnailView.gestureRecognizers count]) {
        [self.thumbnailView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedThumbnailView:)]];
    } else {
        NSLog(@"GESTURES:%@", self.thumbnailView.gestureRecognizers);
    }
    
    self.audioPlayer = [AudioPlayer audioPlayerOnView:self.audioView];
}

- (void) tappedPhotoView:(UITapGestureRecognizer*)tap
{
    [MediaViewer showMediaFromView:tap.view filename:self.profileMediaFile mediaType:mediaTypeFromProfileMediaTypes(self.profileMediaType) isReal:self.isReal];
}

- (void) tappedThumbnailView:(UITapGestureRecognizer*)tap
{
    [MediaViewer showMediaFromView:tap.view filename:self.mediaFile mediaType:self.mediaType isReal:self.isReal];
}

- (void)setMessage:(Bullet *)message user:(User*)user tableView:(UITableView*)tableView isConsecutive:(BOOL)consecutive
{
    _messageId = message.objectId;
    _profileMediaType = user.profileMediaType;
    _profileMediaFile = user.profileMedia;
    _mediaType = message.mediaType;
    _mediaFile = message.mediaFile;
    
    self.dateLabel.text = message.createdAt.timeAgo;
    self.nicknameLabel.text = user.nickname;
    self.nicknameLabel.hidden = consecutive;
    self.photoView.hidden = consecutive;
    self.audioView.alpha = 0.0;
    self.isReal = message.realMedia;
    self.messageLabel.hidden = NO;
    
    [S3File getDataFromFile:user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        if (!error) {
            self.photoView.layer.contents = (id) [UIImage imageWithData:data].CGImage;
        }
    }];
    
    self.thumbnailView.alpha = 0.0;
    
    NSString *string = [message.message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    self.messageLabel.text = string;
    
    CGFloat boxSize = 0;
    
    switch (message.mediaType) {
        case kMediaTypeText: {
            CGRect rect = rectForString(string, self.messageLabel.font, kTextMessageWidth);
            boxSize = rect.size.width;
        }
            break;
        case kMediaTypeVideo:
        case kMediaTypePhoto: {
            self.playView.hidden = (message.mediaType == kMediaTypePhoto);
            boxSize = kThumbnailWidth;
            [S3File getDataFromFile:message.mediaThumbnailFile completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
                if (!error) {
                    if (fromCache) {
                        [self setupThumbnailImageWithData:data animated:NO];
                    }
                    else {
                        [self lazyUpdateData:data onTableView:tableView];
                    }
                }
            }];
        }
            break;
        case kMediaTypeAudio: {
            self.playView.hidden = YES;
            self.messageLabel.hidden = YES;
            self.audioView.hidden = NO;
            boxSize = MIN(MAX(message.audioTicks*5 + 100, kAudioThumbnailWidth/2), kAudioThumbnailWidth);
            [S3File getDataFromFile:message.mediaThumbnailFile completedBlock:^(NSData *thumbnail, NSError *error, BOOL thumbnailFromCache) {
                if (!error) {
                    [self.audioPlayer setupAudioThumbnailData:thumbnail audioFile:message.mediaFile];
                    self.audioView.alpha = 1.0f;
                }
                else {
                    NSLog(@"ERROR:%@", error.localizedDescription);
                    self.audioView.alpha = 0.0f;
                }
            }];
        }
            break;
        case kMediaTypeURL:
            break;
        case kMediaTypeNone:
            break;
        default:
            break;
    }
    self.spacing.constant = self.contentView.bounds.size.width-boxSize-(self.trailing.constant+CHATVIEWINSET*2);
}

- (void)lazyUpdateData:(NSData*)data onTableView:(UITableView*)tableView
{
    [[tableView visibleCells] enumerateObjectsUsingBlock:^(ChatRight* _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell.messageId isEqualToString:self.messageId]) {
            *stop = YES;
            [self setupThumbnailImageWithData:data animated:YES];
        }
    }];
}

- (void)setupThumbnailImageWithData:(NSData*)data animated:(BOOL) animated
{
    self.thumbnailView.alpha = animated ? 0.0f : 1.0f;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *thumbnailImage = [UIImage imageWithData:data];
        self.thumbnailView.layer.contents = (id) thumbnailImage.CGImage;
        if (animated) {
            [UIView animateWithDuration:0.25 animations:^{
                self.thumbnailView.alpha = 1.0f;
            }];
        }
    });
}
@end
