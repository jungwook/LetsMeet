//
//  ChatV2.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Chat.h"
#import "AppEngine.h"

#define NAVBARHEIGHT 64

@interface Chat()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MessageBar *messageBar;
@property (nonatomic, strong, readonly) PFObject *me;
@property (nonatomic, weak, readonly) AppEngine *engine;
@end

@implementation Chat

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _me = [PFUser currentUser];
        _engine = [AppEngine engine];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messageBar.messageBarDelegate = self;
    
}

- (void) messagesReloaded:(id)sender
{
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
    [self.engine resetUnreadMessagesFromUser:self.toUser notify:NO];
}

- (void)setToUser:(PFUser *)toUser
{
    _toUser = toUser;
    [self.engine resetUnreadMessagesFromUser:self.toUser notify:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messagesReloaded:)
                                                 name:AppUserMessagesReloadedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserMessagesReloadedNotification
                                                  object:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.engine messagesWithUser:self.toUser] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    PFObject *message = [self.engine messagesWithUser:self.toUser][indexPath.row];
    if ([message[AppMessageType] isEqualToString:AppMessageTypeMessage]) {
        cell.textLabel.text = message[AppMessageContent];
    }
    else if ([message[AppMessageType] isEqualToString:AppMessageTypePhoto]) {
        
    }
    else if ([message[AppMessageType] isEqualToString:AppMessageTypeVideo]) {
        
    }
    else if ([message[AppMessageType] isEqualToString:AppMessageTypeAudio]) {
        
    }
    else if ([message[AppMessageType] isEqualToString:AppMessageTypeURL]) {
        
    }

    return cell;
}

- (IBAction)tappedOutside:(id)sender {
    [self.messageBar pullDownKeyBoard];
}

- (void)keyBoardEvent:(CGRect)kbFrame duration:(double)duration animationType:(UIViewAnimationOptions)animation
{
    float w = self.view.frame.size.width;
    float m = self.messageBar.frame.size.height;
    float h = kbFrame.origin.y-m;
    float nbh = self.navigationController.navigationBar.frame.size.height+self.navigationController.navigationBar.frame.origin.y;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView setFrame:CGRectMake(0, nbh, w, h-nbh)];
        [self.messageBar setFrame:CGRectMake(0, h, w, m)];
        [self scrollToBottomAnimated:YES];
    });
    [UIView animateWithDuration:duration animations:^{
        [self.tableView setFrame:CGRectMake(0, nbh, w, h-nbh)];
        [self.messageBar setFrame:CGRectMake(0, h, w, m)];
    } completion:^(BOOL finished) {
//        [self scrollToBottomAnimated:YES];
    }];
}


// From MessageBarDelegate. A message was sent from the messageBar.

- (void)sendMessage:(id)message
{
    [self.engine sendMessage:[self messageToObject:message] toUser:self.toUser];
}

- (PFObject*) messageToObject:(id)message
{
    PFObject *obj = [PFObject objectWithClassName:AppMessagesCollection];
    obj[@"fromUser"] = self.me;
    obj[@"toUser"] = self.toUser;
    obj[AppMessageType] = message[AppMessageType];
    obj[AppMessageContent] = message[AppMessageContent];
    obj[@"isRead"] = @(NO);

    return obj;
}

- (void) scrollToBottomAnimated:(BOOL) animated
{
    NSUInteger count = [self.engine messagesWithUser:self.toUser].count;
    if (count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count ? count-1 : 0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

@end
