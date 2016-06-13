//
//  Chat.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Chat.h"
#import "ChatCell.h"
#import "MessageBar.h"
#import "NSMutableDictionary+Bullet.h"
#import "FileSystem.h"

@interface Chat ()
{
    CGRect keyboardEndFrameWindow;
    double keyboardTransitionDuration;
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bar;

@property (strong, nonatomic) UITextView *messageView;
@property (nonatomic) CGFloat textViewHeight;
@property (nonatomic, strong) NSArray* messages;
@property (nonatomic, strong) FileSystem* system;
@end

@implementation Chat

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.system = [FileSystem new];
    }
    return self;
}

- (void)setUser:(User *)user
{
    _user = user;
    self.messages = [self.system messagesWith:self.user.objectId];
    NSLog(@"MESSAGES:%@", self.messages);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (!self.messageView) {
        float m = self.bar.frame.size.height+30;
        float h = keyboardEndFrameWindow.origin.y-m;
        [self.bar setFrame:CGRectMake(self.bar.frame.origin.x, h, self.bar.frame.size.width, m)];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, 0, self.tableView.frame.size.width, h)];
        [self addTextView];
    }
    [self addObservers];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    __LF
    NSLog(@"COUNT:%ld", self.messages.count);
    NSLog(@"COUNT:%@", self.messages);
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];
    Bullet *bullet = self.messages[indexPath.row];
    cell.textLabel.text = bullet.message;
    return cell;
}

#define LEFTBUTSIZE 45
#define TOPINSET 8

- (void) addTextView
{
    
    CGSize size = self.bar.frame.size;
    self.messageView = [[UITextView alloc] initWithFrame:CGRectMake(LEFTBUTSIZE+TOPINSET, TOPINSET, size.width-2*(LEFTBUTSIZE+TOPINSET), size.height-2*TOPINSET)];
    self.messageView.delegate = self;
    self.messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.messageView.font = [UIFont systemFontOfSize:16];
    self.messageView.backgroundColor = [UIColor whiteColor];
    self.textViewHeight = 30;
    self.messageView.keyboardType = UIKeyboardTypeDefault;
    self.messageView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.messageView.returnKeyType = UIReturnKeyNext;
    self.messageView.enablesReturnKeyAutomatically = YES;
    self.messageView.layer.cornerRadius = 2.0;
    self.messageView.layer.borderWidth = 0.5;
    self.messageView.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    
    [self.bar addSubview:self.messageView];
}

- (void) dealloc
{
    [self removeObservers];
}

- (void)doEndEditingEvent:(NSString *)string
{
    __LF
}

- (IBAction)sendMessage:(id)sender {
    __LF

    Bullet* bullet = [Bullet bulletWithText:self.messageView.text];
    [self.system add:bullet for:self.user.objectId thumbnail:nil originalData:nil];
    [self.tableView reloadData];
}

- (IBAction)sendMedia:(id)sender {
    __LF
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


- (void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doKeyBoardEvent:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doEndEditingEvent:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];
}

- (void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:nil];
}

- (void)doKeyBoardEvent:(NSNotification *)notification
{
    __LF
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    
    [self keyBoardEvent];
}


- (IBAction)tappedOutside:(id)sender {
    __LF
    [self.messageView resignFirstResponder];
}

- (void)keyBoardEvent
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:keyboardTransitionAnimationCurve];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:keyboardTransitionDuration];
        
        float m = self.bar.frame.size.height;
        m = self.textViewHeight + 18;
        float h = keyboardEndFrameWindow.origin.y-m;
        [self.bar setFrame:CGRectMake(self.bar.frame.origin.x, h, self.bar.frame.size.width, m)];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, 0, self.tableView.frame.size.width, h)];
        CGPoint offsetPoint = CGPointMake(0.0, self.messageView.contentSize.height - self.messageView.bounds.size.height);
        [self.messageView setContentOffset:offsetPoint animated:YES];
        [UIView commitAnimations];
    });
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGRect rect = rectForString([textView.text stringByAppendingString:@"x"], textView.font, textView.frame.size.width);
    self.textViewHeight = MIN(300, MAX(rect.size.height+12,30));
    [self keyBoardEvent];
}


@end
