//
//  Chat.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Chat.h"
#import "ChatRight.h"
#import "ChatLeft.h"
#import "NSMutableDictionary+Bullet.h"
#import "FileSystem.h"
#import "Notifications.h"
#import "S3File.h"
#import "MediaPicker.h"

#define kInitialTextViewHeight 34
#define kMaxTextViewHeight 200
#define kNavigationBarHeight 64
#define photoViewHeight 40
#define balloonOffet 8

@interface Chat ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bar;
@property (weak, nonatomic) IBOutlet UITextView *messageView;
@property (weak, nonatomic) IBOutlet UIButton *microphone;
@property (weak, nonatomic) IBOutlet UIButton *sendBut;
@property (nonatomic) CGFloat textViewHeight;
@property (nonatomic, strong) FileSystem* system;
@property (nonatomic, strong) Notifications* notifications;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *barTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *barBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *barHeight;
@end

@implementation Chat

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.system = [FileSystem new];
        self.textViewHeight = kInitialTextViewHeight;
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setUser:(User *)user
{
    __LF
    _user = user;
    self.navigationItem.title = user.nickname;
    self.notifications = [Notifications notificationWithMessage:^(id bullet) {
        [self.system readUnreadBulletsWithUserId:self.user.objectId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self scrollToBottomAnimated:YES];
        });
    } broadcast:^(id senderId, NSString *message, NSTimeInterval duration) {
        
    } refresh:nil];
    [self.system readUnreadBulletsWithUserId:self.user.objectId];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.notifications on];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollToBottomAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.notifications off];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addObservers];
    [self setupTableInsetsOnFirstLoad];
}

- (IBAction)startRecording:(id)sender {
    __LF
}

- (IBAction)stopRecording:(id)sender {
    __LF
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    __LF
    return [self.system messagesWith:self.user.objectId].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Bullet *bullet = [[self.system messagesWith:self.user.objectId] objectAtIndex:indexPath.row];
    
    BOOL consecutive = NO;
    
    if (indexPath.row > 0) {
        Bullet *prev = [[self.system messagesWith:self.user.objectId] objectAtIndex:indexPath.row-1];
        if ([bullet.fromUserId isEqualToString:prev.fromUserId]) {
            consecutive = YES;
        }
    }
    
    if (bullet.isFromMe) {
        ChatRight *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatRight" forIndexPath:indexPath];
        [cell setMessage:bullet user:[User me] tableView:self.tableView isConsecutive:consecutive];
        return cell;
    }
    else {
        User *user = [self.system userWithId:bullet.fromUserId];
        ChatLeft *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatLeft" forIndexPath:indexPath];
        [cell setMessage:bullet user:user tableView:self.tableView isConsecutive:consecutive];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Bullet *bullet = [[self.system messagesWith:self.user.objectId] objectAtIndex:indexPath.row];
    MediaTypes type = bullet.mediaType;
    
    BOOL consecutive = NO;
    
    if (indexPath.row > 0) {
        Bullet *prev = [[self.system messagesWith:self.user.objectId] objectAtIndex:indexPath.row-1];
        if ([bullet.fromUserId isEqualToString:prev.fromUserId]) {
            consecutive = YES;
        }
    }

    switch (type) {
        case kMediaTypePhoto:
        case kMediaTypeVideo: {
            if (bullet.mediaSize.width) {
                CGFloat height = balloonOffet - 4 + kThumbnailWidth * bullet.mediaSize.height / bullet.mediaSize.width;
                return height;
            }
            else {
                return kThumbnailWidth;
            }
        }
        case kMediaTypeText: {
            CGRect rect = rectForString(bullet.message, self.messageView.font, kTextMessageWidth);
            return rect.size.height;
        }
        default:
            return photoViewHeight+balloonOffet;
    }
}

- (void) dealloc
{
    [self removeObservers];
}

- (void)clearTextView
{
    self.messageView.text = @"";
    self.textViewHeight = kInitialTextViewHeight;
    [self doKeyBoardEvent:nil];
}

- (IBAction)sendMessage:(id)sender {
    __LF
    NSString *string = [self.messageView.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if ([self.messageView.text isEqualToString:@""])
        return;
    
    Bullet* bullet = [Bullet bulletWithText:string];
    [self.system add:bullet for:self.user.objectId];
    [self clearTextView];
}

- (IBAction)sendMedia:(id)sender {
    __LF
    if (![self.messageView.text isEqualToString:@""]) {
        [self sendMessage:nil];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Library"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self selectMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
                                                }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Camera"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [self selectMediaFromSource:UIImagePickerControllerSourceTypeCamera];
                                                }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Audio"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self selectAudioMedia];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) selectMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    MediaPicker *mediaPicker = [MediaPicker mediaPickerWithSourceType:sourceType completion:^(Bullet *bullet) {
        [self.system add:bullet for:self.user.objectId];
        [self clearTextView];
    }];
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void) selectAudioMedia
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#define Height(__X__) __X__.bounds.size.height


- (void)doKeyBoardEvent:(NSNotification *)notification
{
    static CGRect keyboardEndFrameWindow;
    static CGRect keyboardBeginFrameWindow;
    static double keyboardTransitionDuration;
    static UIViewAnimationCurve keyboardTransitionAnimationCurve;

    if (notification) {
        [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBeginFrameWindow];
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
        [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
        [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    }

    self.messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize kbSize = keyboardBeginFrameWindow.size;
        BOOL isUp = (keyboardBeginFrameWindow.origin.y > keyboardEndFrameWindow.origin.y);
        UIEdgeInsets zeroInsets = UIEdgeInsetsMake(kNavigationBarHeight+6, 0, 0, 0);
        UIEdgeInsets contentInsets = isUp ? UIEdgeInsetsMake(kNavigationBarHeight+6, 0.0, kbSize.height, 0.0) : zeroInsets;
        self.barBottom.constant = isUp ? kbSize.height : 0;
        self.barHeight.constant = self.textViewHeight + self.messageTop.constant + self.messageBottom.constant;
        
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
        [self.bar setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:keyboardTransitionDuration delay:0.0f options:(keyboardTransitionAnimationCurve << 16) animations:^{
            [self.bar layoutIfNeeded];
            [self moveDownTextView:self.messageView];
        } completion:^(BOOL finished) {
            [self scrollToBottomAnimated:YES];
        }];
    });
}

- (void) setupTableInsetsOnFirstLoad
{
    UIEdgeInsets zeroInsets = UIEdgeInsetsMake(6, 0, 0, 0);
    self.tableView.contentInset = zeroInsets;
    self.tableView.scrollIndicatorInsets = zeroInsets;
}

- (void) moveDownTextView:(UITextView*)textView
{
    if (![textView.text isEqualToString:@""]) {
        [textView setContentOffset:CGPointMake(0.0, textView.contentSize.height - Height(textView)) animated:NO];
    }
}

- (void) scrollToBottomAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height-1, 1, 1) animated:animated];
}


- (IBAction)tappedOutside:(id)sender {
    __LF
    [self.messageView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.sendBut.hidden = [textView.text isEqualToString:@""];
    self.microphone.hidden = !self.sendBut.hidden;
    
    CGRect rect = CGRectIntegral([textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width, 0)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{
                                                                       NSFontAttributeName: textView.font,
                                                                       } context:nil]);

    self.textViewHeight = MIN(kMaxTextViewHeight, MAX(rect.size.height+balloonOffet*2.f, kInitialTextViewHeight));
    [self doKeyBoardEvent:nil];
}

@end
