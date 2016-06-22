//
//  SignUp.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 22..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Welcome.h"
#import "ListPicker.h"

@interface SignUp ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *space;
@property (weak, nonatomic) IBOutlet UIView *pane;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet UITextField *nickname;
@property (weak, nonatomic) IBOutlet UITextField *intro;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *sex;
@property (weak, nonatomic) IBOutlet UILabel *information;
@end

@implementation SignUp

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        __LF
    }
    return self;
}

- (void)awakeFromNib
{
    __LF;
    [super awakeFromNib];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self.blurView setFrame:self.view.bounds];
    [self.blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.blurView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.view insertSubview:self.blurView atIndex:0];
    [ListPicker pickerWithArray:@[@"우리 만나요!", @"애인 찾아요", @"함께 드라이브 해요", @"나쁜 친구 찾아요", @"착한 친구 찾아요", @"함께 먹으러 가요", @"술친구 찾아요"] onTextField:self.intro selection:nil];
    [ListPicker pickerWithArray:@[@"고딩", @"20대", @"30대", @"40대", @"비밀"] onTextField:self.age selection:nil];
    [ListPicker pickerWithArray:@[@"여자", @"남자"] onTextField:self.sex selection:^(id data) {
        self.information.text = @"Please make sure... You cannot change sex ever!";
    }];
    
    [self addObservers];
    self.space.constant = (self.view.bounds.size.height - self.pane.bounds.size.height) / 3.0f;
}

- (void)dealloc {
    __LF
    [self removeObservers];
}

- (void)viewDidLoad {
    __LF
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews
{
    __LF
}

- (IBAction)proceed:(id)sender {
    BOOL notReady = NO;
    if ([self.nickname.text isEqualToString:@""]) {
        self.information.text = @"You must enter a nickname!";
        notReady = YES;
    }
    else if ([self.intro.text isEqualToString:@""]) {
        self.information.text = @"Please select why you're here!";
        notReady = YES;
    }
    else if ([self.age.text isEqualToString:@""]) {
        self.information.text = @"Please select an age group";
        notReady = YES;
    }
    else if ([self.sex.text isEqualToString:@""]) {
        self.information.text = @"Please select your gender. You cannot change this ever!";
        notReady = YES;
    }
    
    if (!notReady && self.completionBlock) {
        self.completionBlock(self, self.nickname.text, self.intro.text, self.age.text, self.sex.text);
        self.information.text = @"Processing...";
    }
}

- (void)setInfo:(NSString *)info
{
    self.information.text = info;
}

- (void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doKeyBoardEvent:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
}

- (void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

- (IBAction)tappedOutside:(id)sender {
    [self.view endEditing:YES];
}

- (void)doKeyBoardEvent:(NSNotification *)notification
{
    static CGRect keyboardEndFrameWindow;
    static double keyboardTransitionDuration;
    static UIViewAnimationCurve keyboardTransitionAnimationCurve;
    
    if (notification) {
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
        [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
        [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.space.constant = (keyboardEndFrameWindow.origin.y - self.pane.bounds.size.height) / 3.0f;
        [self.pane setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:keyboardTransitionDuration delay:0.0f options:(keyboardTransitionAnimationCurve << 16) animations:^{
            [self.pane layoutIfNeeded];
        } completion:nil];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
