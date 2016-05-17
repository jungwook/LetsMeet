//
//  ChatV2.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Chat.h"
#define kCOL_MESSAGES @"Messages"
#define NAVBARHEIGHT 64

@interface Chat()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MessageBar *messageBar;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong) NSString *channel;
@end

@implementation Chat

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messageBar.messageBarDelegate = self;
}

- (void)setToUser:(PFUser *)toUser
{
    _toUser = toUser;

    NSArray *names = [[NSArray arrayWithObjects:[PFUser currentUser].username, self.toUser.username, nil] sortedArrayUsingSelector:@selector(localizedCompare:)];
    
    self.channel = [[[names firstObject] stringByAppendingString:@"--"] stringByAppendingString:[names lastObject]];
    
    [self reloadMessages];
}

- (void) reloadMessages;
{
    self.query = [PFQuery queryWithClassName:kCOL_MESSAGES];
    [self.query whereKey:@"channel" equalTo:[self channel]];
    
    [self.query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (self.messages) {
            [self.messages removeAllObjects];
        }
        self.messages = [NSMutableArray arrayWithArray:objects];
        [self.tableView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollToBottom];
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
    if ([message[k_MESSAGETYPE] isEqualToString:k_MESSAGETYPEMSG]) {
        cell.textLabel.text = message[k_MESSAGECONTENT];
    }
    else if ([message[k_MESSAGETYPE] isEqualToString:k_MESSAGETYPEPHOTO]) {
        
    }
    else if ([message[k_MESSAGETYPE] isEqualToString:k_MESSAGETYPEVIDEO]) {
        
    }
    else if ([message[k_MESSAGETYPE] isEqualToString:k_MESSAGETYPEAUDIO]) {
        
    }
    else if ([message[k_MESSAGETYPE] isEqualToString:k_MESSAGETYPEURL]) {
        
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
    });
    [UIView animateWithDuration:duration animations:^{
        [self.tableView setFrame:CGRectMake(0, nbh, w, h-nbh)];
        [self.messageBar setFrame:CGRectMake(0, h, w, m)];
    } completion:^(BOOL finished) {
        [self scrollToBottom];
    }];
}

- (void)sendMessage:(id)message
{
    PFObject *object = [self messageToObject:message];
    
    [self.messages addObject:object];
    [self.tableView reloadData];
    [self scrollToBottom];
    [object saveInBackground];
    
//    [self sendPushClient:object];
    [self sendPush:object];
}

- (void) sendPushClient:(PFObject*) object
{
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:self.toUser];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setMessage:object[k_MESSAGECONTENT]];
    [push sendPushInBackground];
}

- (void)sendPush:(PFObject*) object
{
    NSLog(@"ME:%@", [PFUser currentUser]);
    NSLog(@"REC:%@", self.toUser);
    [PFCloud callFunctionInBackground:@"sendPushToUser"
                       withParameters:@{@"recipientId": self.toUser.objectId, @"message": object[k_MESSAGECONTENT]}
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        // Push sent successfully
                                    }
                                }];
}

- (PFObject*) messageToObject:(id)message
{
    PFObject *obj = [PFObject objectWithClassName:kCOL_MESSAGES];
    obj[@"fromUser"] = [PFUser currentUser];
    obj[@"toUser"] = self.toUser;
    obj[@"channel"] = self.channel;
    obj[k_MESSAGETYPE] = message[k_MESSAGETYPE];
    obj[k_MESSAGECONTENT] = message[k_MESSAGECONTENT];

    return obj;
}

- (void) scrollToBottom
{
    if (self.messages.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count ? self.messages.count-1 : 0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

@end
