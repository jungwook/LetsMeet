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
#import "MediaViewer.h"
#import "AudioPlayer.h"

#define CHATVIEWINSET 8

@interface ChatLeft()
@property (weak, nonatomic) IBOutlet Balloon *balloon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacing;
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (weak, nonatomic) IBOutlet MediaView *thumbnail;
@property (weak, nonatomic) IBOutlet IndentedLabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *playView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leading;
@property (nonatomic) MediaTypes mediaType;
@property (nonatomic) ProfileMediaTypes profileMediaType;
@property (nonatomic) BOOL isReal;
@property (nonatomic, strong) id mediaFile;
@property (nonatomic, strong) id profileMediaFile;
@property (nonatomic, strong) id messageId;
@property (weak, nonatomic) IBOutlet UIView *audioView;
@property (strong, nonatomic) AudioPlayer *audioPlayer;

@end

@implementation ChatLeft

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.balloon setIsMine:NO];
    
    self.photo.layer.cornerRadius = 14.f;
    self.photo.layer.masksToBounds = YES;
    self.audioPlayer = [AudioPlayer audioPlayerOnView:self.audioView];
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
    self.photo.hidden = consecutive;
    self.isReal = message.realMedia;
    self.messageLabel.hidden = YES;
    self.thumbnail.hidden = YES;
    self.audioView.hidden = YES;
    
    [self.photo loadMediaFromUser:user];
    
    NSString *string = [message.message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    self.messageLabel.text = string;
    
    CGFloat boxSize = 0;
    
    switch (message.mediaType) {
        case kMediaTypeText: {
            CGRect rect = rectForString(string, self.messageLabel.font, kTextMessageWidth);
            boxSize = rect.size.width+self.leading.constant;
            self.messageLabel.hidden = NO;
        }
            break;
        case kMediaTypeVideo:
        case kMediaTypePhoto: {
            self.playView.hidden = (message.mediaType == kMediaTypePhoto);
            boxSize = kThumbnailWidth;
            [self.thumbnail loadMediaFromMessage:message completion:^(NSData *data, NSError *error, BOOL fromCache) {
                if (fromCache) {
                    self.thumbnail.image = [UIImage imageWithData:data];
                }
                else {
                    [self lazyUpdateData:data onTableView:tableView];
                }
            }];
            self.thumbnail.hidden = NO;
        }
            break;
        case kMediaTypeAudio: {
            self.audioView.hidden = NO;
            boxSize = MIN(MAX(message.audioTicks*5 + 100, kAudioThumbnailWidth/2), kAudioThumbnailWidth);
            [S3File getDataFromFile:message.mediaThumbnailFile completedBlock:^(NSData *thumbnail, NSError *error, BOOL thumbnailFromCache) {
                if (!error) {
                    [self.audioPlayer setupAudioThumbnailData:thumbnail audioFile:message.mediaFile];
                }
                else {
                    NSLog(@"ERROR:%@", error.localizedDescription);
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
    self.spacing.constant = self.contentView.bounds.size.width-boxSize-(self.trailing.constant);
}

- (instancetype)zelf:(id)class
{
    return class;
}

- (void)lazyUpdateData:(NSData*)data onTableView:(UITableView*)tableView
{
    [[tableView visibleCells] enumerateObjectsUsingBlock:^(id _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[self zelf:cell].messageId isEqualToString:self.messageId]) {
            *stop = YES;
            self.thumbnail.image = [UIImage imageWithData:data];
        }
    }];
}
@end
