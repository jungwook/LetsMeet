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
#import "MessageView.h"

#define CHATVIEWINSET 8

@interface ChatLeft()
@property (weak, nonatomic) IBOutlet MessageView *messageView;
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top;
@property (nonatomic, strong) id messageId;
@property (strong, nonatomic) AudioPlayer *audioPlayer;

@end

@implementation ChatLeft

- (void)awakeFromNib {
    [super awakeFromNib];
    self.photo.layer.cornerRadius = 14.f;
    self.photo.layer.masksToBounds = YES;
}

- (void)setMessage:(Bullet *)message user:(User*)user tableView:(UITableView*)tableView isConsecutive:(BOOL)consecutive
{
    self.messageId = message.objectId;
    CGFloat boxSize = [self.messageView getSpacingWhileSettingMessage:message];
    self.messageView.lazyBlock = ^(NSData* data) {
        [[tableView visibleCells] enumerateObjectsUsingBlock:^(id _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[self zelf:cell].messageId isEqualToString:self.messageId]) {
                [self.messageView setThumbnailImage:[UIImage imageWithData:data]];
                *stop = YES;
            }
        }];
    };

    self.photo.hidden = consecutive;
    self.dateLabel.hidden = consecutive;
    self.dateLabel.text = message.createdAt.timeAgo;
    self.top.constant = consecutive ? -4 : 16;
    
    [self.photo loadMediaFromUser:user animated:NO];
    self.spacing.constant = self.contentView.bounds.size.width-boxSize-(self.leading.constant);
}

- (instancetype)zelf:(id)class
{
    return class;
}
@end
