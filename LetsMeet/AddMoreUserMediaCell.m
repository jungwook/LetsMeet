//
//  AddMoreUserMediaCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 11..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "AddMoreUserMediaCell.h"
@interface AddMoreUserMediaCell()
@property (weak, nonatomic) IBOutlet UIView *back;
@end

@implementation AddMoreUserMediaCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    roundCorner(self.back);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.back.backgroundColor = backgroundColor;
}

- (IBAction)addMore:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addMoreUserMedia)]) {
        [self.delegate addMoreUserMedia];
    }
}

@end
