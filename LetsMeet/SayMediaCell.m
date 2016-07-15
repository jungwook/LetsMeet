//
//  SayMediaCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SayMediaCell.h"
#import "MediaViewer.h"

@interface SayMediaCell()
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (weak, nonatomic) IBOutlet UILabel *comment;
@end

@implementation SayMediaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}

- (void)setMedia:(UserMedia *)media
{
    _media = media;
    [self.media fetched:^{
        self.comment.text = self.media.comment ? [self.media.comment uppercaseString] : @"<NO COMMENT>";
        [self.photo loadMediaFromUserMedia:self.media animated:NO];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
