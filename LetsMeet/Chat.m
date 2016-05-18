//
//  ChatV2.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Chat.h"
#define kCOLLECTION_MESSAGES @"Messages"
#define NAVBARHEIGHT 64

@interface Chat()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MessageBar *messageBar;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong, readonly) NSString *channel;
@property (nonatomic, strong, readonly) PFObject *me;
@property (readonly) BOOL channelOpen;
@end

@implementation Chat

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _channelOpen = NO;
        _channel = nil;
        _me = [PFUser currentUser];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messageBar.messageBarDelegate = self;
}

- (void) channelFromUser:(PFUser*)user
{
    NSArray *names = [[NSArray arrayWithObjects:self.me.objectId, self.toUser.objectId, nil] sortedArrayUsingSelector:@selector(localizedCompare:)];
    
    _channel = [[[names firstObject] stringByAppendingString:@"--"] stringByAppendingString:[names lastObject]];
}

- (void) createChannelWithUser:(PFUser *)user
{
    if (self.channelOpen) {
        NSLog(@"CHANNEL OPEN");
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Channel"];
    [query whereKey:@"channel" equalTo:self.channel];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ERROR LOOKING UP CHANNEL:%@", error.localizedDescription);
        }
        else {
            if ([objects count] > 1) {    // MUST BE AN ERROR!!!!!!!!!! CANNOT BE MULTIPLE CHANNELS
                NSLog(@"ERROR CANNOT BE MORE THAN ONE CHANNEL:%@", self.channel);
                _channelOpen = YES;
            }
            else if ([objects count] == 1) {    // CHANNEL OPEN SO DO NOTHING
                NSLog(@"CHANNEL:%@ ALREADY OPEN", self.channel);
                _channelOpen = YES;
            }
            else { // NO CHANNEL SO CREATE;
                PFObject *channel = [PFObject objectWithClassName:@"Channel"];
                channel[@"channel"] = self.channel;
                channel[@"members"] = @[ self.me, user];
                [channel saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        NSLog(@"CHANNEL:%@ SUCCESSFULLY CREATED", self.channel);
                        _channelOpen = YES;
                    }
                    else {
                        NSLog(@"ERROR CREATING CHANNEL:%@", error.localizedDescription);
                        _channelOpen = NO;
                    }
                }];
            }
        }
    }];
}

- (void)setToUser:(PFUser *)toUser
{
    _toUser = toUser;
    [self channelFromUser:toUser];
    [self reloadMessages];
}

- (void) reloadMessages;
{
    self.query = [PFQuery queryWithClassName:kCOLLECTION_MESSAGES];
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


// From MessageBarDelegate. A message was sent from the messageBar.

- (void)sendMessage:(id)message
{
/*
 1. Retrieve PFObject from message
 2. Load message to messages[]
 3. Scroll to new message (bottom)
 4. If first message then save to Channel collection as a new channel with appropirate members.
 */
    [self createChannelWithUser:self.toUser];
    
    PFObject *object = [self messageToObject:message];
    
    [self.messages addObject:object];
    [self.tableView reloadData];
    [self scrollToBottom];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self sendPush:object];
        }
        else {
            NSLog(@"ERROR SAVING MESSAGE TO PARSE:%@", error.localizedDescription);
        }
    }];
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

#define kPUSH_RECIPIENT_ID @"recipientId"
#define kPUSH_SENDER_ID @"senderId"
#define kPUSH_MESSAGE @"message"
#define kPUSH_OBJECT_ID @"messageId"

- (void)sendPush:(PFObject*) object
{
    [PFCloud callFunctionInBackground:@"sendPushToUser"
                       withParameters:@{
                                        kPUSH_RECIPIENT_ID: self.toUser.objectId,
                                        kPUSH_SENDER_ID :   self.me.objectId,
                                        kPUSH_MESSAGE:      object[k_MESSAGECONTENT],
                                        kPUSH_OBJECT_ID:    object.objectId
                                        }
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"MESSAGE SENT SUCCESSFULLY:%@", object[k_MESSAGECONTENT]);
                                    }
                                    else {
                                        NSLog(@"ERROR SENDING PUSH:%@", error.localizedDescription);
                                    }
                                }];
}

- (PFObject*) messageToObject:(id)message
{
    PFObject *obj = [PFObject objectWithClassName:kCOLLECTION_MESSAGES];
    obj[@"fromUser"] = self.me;
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
