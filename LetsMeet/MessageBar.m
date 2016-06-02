//
//  MessageBar.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MessageBar.h"
#import "AppEngine.h"
#import "ImagePicker.h"

@interface MessageBar()
{
}
@property (nonatomic, strong) UIButton *mediaBut;
//@property (nonatomic, strong) UIButton *sendBut;
@property (nonatomic, strong) UITextView* textView;
@end

@implementation MessageBar


#define LEFTBUTSIZE 45
#define TOPINSET 8

static inline UIViewAnimationOptions AnimationOptionsForCurve(UIViewAnimationCurve curve)
{
    return curve << 16;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addContents];
        self.textView.delegate = self;
    }
    return self;
}

- (void) addContents
{
    [self addMediaBut];
    [self addTextView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doKeyBoardEvent:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doEndEditingEvent:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];

}

- (void) dealloc
{
    // Unregister for keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:nil];
}

- (void)doEndEditingEvent:(NSString *)string
{
}

- (void)doKeyBoardEvent:(NSNotification *)notification
{
    CGRect keyboardEndFrameWindow;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
    
    double keyboardTransitionDuration;
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
    
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    
    if ([self.barDelegate respondsToSelector:@selector(keyBoardEvent:duration:animationType:)]) {
        [self.barDelegate keyBoardEvent:keyboardEndFrameWindow duration:keyboardTransitionDuration animationType:AnimationOptionsForCurve(keyboardTransitionAnimationCurve)];
    }
}

- (void) addMediaBut
{
    CGSize size = self.frame.size;
    const CGFloat offset = 4;
    self.mediaBut = [[UIButton alloc] initWithFrame:CGRectMake(offset, offset, size.height-2*offset, size.height-2*offset)];
    self.mediaBut.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.mediaBut setShowsTouchWhenHighlighted:YES];
    [self.mediaBut setReversesTitleShadowWhenHighlighted:YES];
    [self.mediaBut setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [self.mediaBut addTarget:self action:@selector(mediaButPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.mediaBut];
}

- (void) addTextView
{
    CGSize size = self.frame.size;
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(LEFTBUTSIZE, TOPINSET, size.width-LEFTBUTSIZE-TOPINSET, size.height-2*TOPINSET)];
    [self.textView setScrollEnabled:NO];
    
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    self.textView.backgroundColor = [UIColor whiteColor];
    
    //textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.enablesReturnKeyAutomatically = YES;
    self.textView.layer.cornerRadius = 5.0;
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [self addSubview:_textView];
}

- (void) pullDownKeyBoard
{
    [self.textView resignFirstResponder];
}

- (void) mediaButPressed:(id)sender
{
    if ([self.barDelegate respondsToSelector:@selector(sendMedia)]) {
        [self.barDelegate sendMedia];
    }
}

- (void) sendText
{
    NSString *textToSend = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if ([self.barDelegate respondsToSelector:@selector(sendMessage:)]) {
        [self.barDelegate sendMessage:[NSMutableDictionary messageWithText:textToSend]];
    }
    
    self.textView.text = @"";
    [self.textView becomeFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendText];
        });
    }
    return YES;
}

@end
