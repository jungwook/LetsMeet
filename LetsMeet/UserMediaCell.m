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

@property (strong, nonatomic) UserMedia* media;
@property (weak, nonatomic) UserMediaCollection* parent;
@property (nonatomic) BOOL editable;
@end


@implementation UserMediaCell

- (void)awakeFromNib
{
    self.back.layer.cornerRadius = 2.0f;
    self.back.layer.masksToBounds = YES;    
    setShadowOnView(self.delete, 1.5f, 0.4f);
}

- (IBAction)removeMedia:(id)sender
{
    [self.parent removeMedia:self.media row:self.tag];
}

- (IBAction)editComment:(id)sender {
    [self.parent editMediaComment:self.media row:self.tag];
}

- (void)setUserMedia:(UserMedia *)media parent:(UserMediaCollection *)parent row:(NSInteger)row
{
    self.tag = row;
    
    _media = media;
    _parent = parent;
    _editable = [media.userId isEqualToString:[User me].objectId];
    
    self.delete.hidden = !self.editable;
    self.edit.hidden = !self.editable;
    
    [self.photo setImage:nil];
    [self.photo loadMediaFromUserMedia:media completion:^(NSData *data, NSError *error, BOOL fromCache) {
        [[self.parent visibleCells] enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UserMediaCell class]]) {
                UserMediaCell *cell = (UserMediaCell*) obj;
                if ([cell.media.objectId isEqualToString:media.objectId]) {
                    *stop = YES;
                    [cell.photo setImage:[UIImage imageWithData:data]];
                    cell.comment.text = media.comment ? [media.comment uppercaseString] : [@"no comment" uppercaseString];
                }
            }
        }];
    }];
}

- (void)setMedia:(UserMedia *)media
{
}



@end
