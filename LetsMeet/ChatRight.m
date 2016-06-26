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
#define S3LOCATION @"http://parsekr.s3.ap-northeast-2.amazonaws.com/"

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
@property (weak, nonatomic) IBOutlet UIView *audioView;
@property (nonatomic) MediaTypes mediaType;
@property (nonatomic) ProfileMediaTypes profileMediaType;
@property (nonatomic, strong) id mediaFile;
@property (nonatomic, strong) id profileMediaFile;
@property (nonatomic, strong) id messageId;
@property (strong, nonatomic) AudioPlayer *audioPlayer;
@end

@implementation ChatRight

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.balloon setIsMine:YES];
    
    self.photoView.layer.cornerRadius = 20.f;
    self.photoView.layer.masksToBounds = YES;
    self.thumbnailView.layer.contentsGravity = kCAGravityResizeAspect;
    self.realIcon.layer.shadowColor = [UIColor blackColor].CGColor;
    self.realIcon.layer.shadowOffset = CGSizeZero;
    self.realIcon.layer.shadowRadius = 2.0f;
    self.realIcon.layer.shadowOpacity = 0.3;

    if (![self.photoView.gestureRecognizers count]) {
        [self.photoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedPhotoView:)]];
    }
    
    self.thumbnailView.userInteractionEnabled = YES;
    if (![self.thumbnailView.gestureRecognizers count]) {
        [self.thumbnailView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedThumbnailView:)]];
    } else {
        NSLog(@"GESTURES:%@", self.thumbnailView.gestureRecognizers);
    }
    
    self.audioPlayer =[AudioPlayer audioPlayerOnView:self.audioView];
}

- (void) tappedPhotoView:(UITapGestureRecognizer*)tap
{
    [MediaViewer showMediaFromView:tap.view filename:self.profileMediaFile mediaType:mediaTypeFromProfileMediaTypes(self.profileMediaType)];
}

- (void) tappedThumbnailView:(UITapGestureRecognizer*)tap
{
    [MediaViewer showMediaFromView:tap.view filename:self.mediaFile mediaType:self.mediaType];
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
    
    [S3File getDataFromFile:user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        if (!error) {
            self.photoView.layer.contents = (id) [UIImage imageWithData:data].CGImage;
        }
    } progressBlock:nil];
    
    self.thumbnailView.alpha = 0.0;
    self.realIcon.hidden = YES;
    self.audioView.hidden = YES;
    
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
            self.realIcon.hidden = !(message.realMedia);
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
            } progressBlock:nil];
        }
            break;
        case kMediaTypeAudio: {
            self.playView.hidden = YES;
            self.realIcon.hidden = YES;
            self.audioView.hidden = NO;
            boxSize = kThumbnailWidth*2.0f;
            [S3File getDataFromFile:message.mediaThumbnailFile completedBlock:^(NSData *thumbnail, NSError *error, BOOL fromCache) {
                if (!error) {
                    [self.audioPlayer setupAudioThumbnailData:thumbnail audioURL:[NSURL URLWithString:[S3LOCATION stringByAppendingString:self.mediaFile]]];
                }
            } progressBlock:nil];
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
