//
//  UserMediaCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UserMediaCell.h"
#import "MediaViewer.h"

@interface UserMediaCell()
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (weak, nonatomic) IBOutlet UIView *back;
@property (weak, nonatomic) IBOutlet UILabel *comment;
@property (weak, nonatomic) IBOutlet UIButton *edit;
@property (weak, nonatomic) IBOutlet UIButton *delete;
@property (nonatomic) BOOL editable;
@end

@implementation UserMediaCell

- (void)awakeFromNib
{
    roundCorner(self.back);
    setShadowOnView(self.delete, 1.5f, 0.4f);
}

- (IBAction)removeMedia:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(userMediaCell:removeMedia:)]) {
        [self.delegate userMediaCell:self removeMedia:self.media];
    }
}

- (IBAction)editComment:(id)sender {
    if ([self.delegate respondsToSelector:@selector(userMediaCell:editCommentOnMedia:)]) {
        [self.delegate userMediaCell:self editCommentOnMedia:self.media];
    }
}

- (void)setMedia:(UserMedia *)media
{
    _media = media;
    
    [self.media fetched:^{
        _editable = [self.media.userId isEqualToString:[User me].objectId];
        
        self.delete.hidden = !self.editable;
        self.edit.hidden = !self.editable;
        
        [self.photo loadMediaFromUserMedia:media completion:^(NSData *data, NSError *error, BOOL fromCache) {
            if ([self.delegate respondsToSelector:@selector(collectionVisibleCells)]) {
                [[self.delegate collectionVisibleCells] enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[UserMediaCell class]]) {
                        UserMediaCell *cell = (UserMediaCell*) obj;
                        if ([cell.media.objectId isEqualToString:media.objectId]) {
                            *stop = YES;
                            [cell.photo setImage:[UIImage imageWithData:data]];
                            cell.comment.text = media.comment ? [media.comment uppercaseString] : [@"no comment" uppercaseString];
                        }
                    }
                }];
            }
        }];
    }];
}
@end
