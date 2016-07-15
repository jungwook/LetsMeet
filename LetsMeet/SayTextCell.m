//
//  SayTextCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SayTextCell.h"

@interface SayTextCell()
@property (weak, nonatomic) IBOutlet UILabel *placeholder;
@property (weak, nonatomic) IBOutlet UIView *placeholderView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end
@implementation SayTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.textView.delegate = self;
    self.placeholderView.alpha = 1.0f;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPost:(NSString *)text
{
    self.placeholder.alpha = [text isEqualToString:@""];
    self.textView.text = text;
}

- (void)setEditable:(BOOL)editable
{
    self.textView.editable = editable;
    self.textView.userInteractionEnabled = editable;
}

- (void)becomeFirstResponder
{
    [self.textView becomeFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.placeholderView.alpha != [textView.text isEqualToString:@""]) {
        [UIView animateWithDuration:0.35 animations:^{
            self.placeholderView.alpha = [textView.text isEqualToString:@""];
        }];
    }
    [self.parent sayText:textView.text changedAtIndex:self.index];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self.parent startNewLine];
        return NO;
    }
    return YES;
}

@end
