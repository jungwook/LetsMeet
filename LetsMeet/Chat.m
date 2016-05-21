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
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) PFUser* chatUser;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMessageReceived:)
                                                 name:AppUserNewMessageReceivedNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserNewMessageReceivedNotification
                                                  object:nil];
}

- (void)setChatUser:(PFUser *)user withMessages:(NSArray *)messages
{
    NSLog(@"USER:%@", user);
    _chatUser = user;
    self.messages = [NSMutableArray arrayWithArray:messages];
    [self resetAllUnreadMessages];
    [self.tableView reloadData];
    return;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollToBottomAnimated:YES];
}

- (void) resetAllUnreadMessages
{
    [self.messages enumerateObjectsUsingBlock:^(PFObject*  _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![message[@"isRead"] boolValue]) {
            [message setObject:@(YES) forKey:@"isRead"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!succeeded) {
                    NSLog(@"ERROR SAVING:%@ - %@", message, error.localizedDescription );
                }
            }];
        }
    }];
}

- (void) newMessageReceived:(NSNotification*)msg
{
    PFObject *message = msg.object;
    PFUser* fromUser = message[@"fromUser"];
    
    if ([fromUser.objectId isEqualToString:self.chatUser.objectId]) {
        [self addNewMessage:message];
        [self resetAllUnreadMessages];
    }
}

// From MessageBarDelegate. A message was sent from the messageBar.

- (void)sendMessage:(id)message
{
    PFObject* messageObject= [self messageToObject:message];
    [AppEngine appEngineSendMessage:messageObject toUser:self.chatUser];
    [self addNewMessage:messageObject];
}

- (void)addNewMessage:(PFObject*)message
{
    if (!self.messages) {
        self.messages = [NSMutableArray array];
    }
    [self.messages addObject:message];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    PFObject *message = self.messages[indexPath.row];
    
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


- (PFObject*) messageToObject:(id)message
{
    PFObject *obj = [PFObject objectWithClassName:AppMessagesCollection];
    obj[@"fromUser"] = self.me;
    obj[@"toUser"] = self.chatUser;
    obj[AppMessageType] = message[AppMessageType];
    obj[AppMessageContent] = message[AppMessageContent];
    obj[@"isRead"] = @(NO);

    return obj;
}

- (void) scrollToBottomAnimated:(BOOL) animated
{
    NSUInteger count = [self.tableView numberOfRowsInSection:0];

    if (count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count ? count-1 : 0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

@end
