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
    
    self.back.layer.cornerRadius = 2.0f;
    self.back.layer.masksToBounds = YES;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.back.backgroundColor = backgroundColor;
}

- (IBAction)addMore:(id)sender {
    [self.parent addMedia];
}

@end
