//
//  MenuCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MenuCell.h"

@interface MenuCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *menuLabel;
@end

@implementation MenuCell


- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self highlightCell:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self highlightCell:highlighted];
}

- (void)highlightCell:(BOOL)highlight {
    UIColor *tintColor = [UIColor whiteColor];
    if(highlight) {
        tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    }
    
    self.menuLabel.textColor = tintColor;
    self.iconView.tintColor = tintColor;
}


- (NSString*) menu {
    return self.menuLabel.text;
}

- (void) setMenu:(NSString *)menu
{
    [self.menuLabel setText:menu];
}

- (UIImage *) icon {
    return self.iconView.image;
}

- (void) setIcon:(UIImage *)icon {
    self.iconView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
