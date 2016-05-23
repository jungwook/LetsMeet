//
//  ChatV2.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Chat.h"
#import "AppEngine.h"

#define meId self.me.objectId
#define userId self.user.objectId

@interface Chat()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MessageBar *messageBar;
@property (nonatomic, strong, readonly) PFUser *me;
@property (nonatomic, weak, readonly) AppEngine *engine;

@property (nonatomic, strong) PFUser* user;
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

- (void)dealloc
{
}

- (void)setChatUser:(PFUser *)user
{
    _user = user;
    
    [AppEngine appEngineSetReadAllMyMessagesWithUserId:userId];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMessageReceived:)
                                                 name:AppUserNewMessageReceivedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserNewMessageReceivedNotification
                                                  object:nil];
}


- (void) newMessageReceived:(NSNotification*)notification
{
    // SUPPOSED TO BE USER CHANNEL
    //
    // 1. Message From ME           TO ME.      POSSIBLE FOR TESTING BUT CANNOT SINCE I CANNOT BE FOUND FROM SEARCH
    //                              TO USER     NOT DO ANYTHING
    //                              TO UNKNOWN  BY PASS IN THIS VC (CHAT SCREEN) AND LET INBOX HANDLE (ACTUALLY NOT POSSIBLE)
    // 2. Message From USER         TO ME.      HANDLE BY RESETING ISREAD TO YES AND RELOADING TABLE
    //                              TO USER     BY PASS IN THIS VC (CHAT SCREEN) AND LET INBOX HANDLE OR NOT
    //                              TO UNKNOWN  BY PASS IN THIS VC (CHAT SCREEN) AND LET INBOX HANDLE OR NOT
    // 3. Message From UNKNOWN      TO ME.      BY PASS IN THIS VC (CHAT SCREEN) AND LET INBOX HANDLE OR NOT
    //                              TO USER     BY PASS IN THIS VC (CHAT SCREEN) AND LET INBOX HANDLE OR NOT
    //                              TO UNKNOWN  BY PASS IN THIS VC (CHAT SCREEN) AND LET INBOX HANDLE OR NOT
    //
    // WHAT AM I HANDLING
    //
    id message = notification.object;
    id fromUser = message[AppKeyFromUserField];
    id toUser = message[AppKeyToUserField];
    
    if ([fromUser isEqualToString:meId] && [toUser isEqualToString:userId]) {
        if ([userId isEqualToString:meId]) {
            [AppEngine appEngineSetReadAllMyMessagesWithUserId:fromUser]; // ME = FROM = TO %% SPECIAL CASE
        }
        [self.tableView reloadData];
    }
    else if ([fromUser isEqualToString:userId] && [toUser isEqualToString:meId]) {
        [AppEngine appEngineSetReadAllMyMessagesWithUserId:fromUser];
        [self.tableView reloadData];
    }
    else {
        return;
    }
    [self scrollToBottomAnimated:YES];
}

// From MessageBarDelegate. A message was sent from the messageBar.

- (void)sendMessage:(id)barMessage
{
    PFObject *message = [PFObject objectWithClassName:AppMessagesCollection];
    message[AppKeyFromUserField] = self.me;
    message[AppKeyToUserField] = self.user;
    message[AppMessageType] = barMessage[AppMessageType];
    message[AppMessageContent] = barMessage[AppMessageContent];
    message[AppKeyIsReadKey] = @(NO);
    message[AppKeyIsSyncFromUserField] = @(YES);
    
    if ([self.me.objectId isEqualToString:self.user.objectId]) {
        message[AppKeyIsSyncToUserField] = @(YES);
    }

    [AppEngine appEngineSendMessage:message toUser:self.user];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AppEngine appEngineMessagesWithUserId:userId].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    id message = [AppEngine appEngineMessagesWithUserId:userId][indexPath.row];
    
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

- (void) scrollToBottomAnimated:(BOOL) animated
{
    NSUInteger count = [self.tableView numberOfRowsInSection:0];

    if (count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count ? count-1 : 0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

@end
