//
//  Account.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Account.h"

@interface Account ()
@property (weak, nonatomic) IBOutlet UIView *nicknameIcon;
@property (weak, nonatomic) IBOutlet UIView *ageIcon;
@property (weak, nonatomic) IBOutlet UIView *introIcon;
@property (weak, nonatomic) IBOutlet UITextField *nickname;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *intro;
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UIView *photoView;

@end

@implementation Account

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (IBAction)tappedView:(id)sender {
    [self.tableView resignFirstResponder];
}

- (IBAction)chargePoints:(id)sender {
}

- (IBAction)editPhoto:(id)sender {
}

- (void)viewWillAppear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doKeyBoardEvent:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void) dealloc
{
    // Unregister for keyboard notifications
}

- (void)doKeyBoardEvent:(NSNotification *)notification
{
    CGRect keyboardEndFrameWindow;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
    
    double keyboardTransitionDuration;
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
    
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    
    float w = self.view.frame.size.width;
    float h = keyboardEndFrameWindow.origin.y;
    float nbh = self.navigationController.navigationBar.frame.size.height+self.navigationController.navigationBar.frame.origin.y;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(keyboardTransitionDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView setFrame:CGRectMake(0, nbh, w, h-nbh)];
    });
    [UIView animateWithDuration:keyboardTransitionDuration animations:^{
        [self.tableView setFrame:CGRectMake(0, nbh, w, h-nbh)];
    } completion:^(BOOL finished) {
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self circleView:self.photoView];
    [self circleView:self.ageIcon];
    [self circleView:self.nicknameIcon];
    [self circleView:self.introIcon];
}

- (void) circleView:(UIView*)view
{
    view.layer.cornerRadius = view.frame.size.height / 2.f;
    view.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (IBAction)toggleMenu:(id)sender {
    [AppDelegate toggleMenu];
}


@end
