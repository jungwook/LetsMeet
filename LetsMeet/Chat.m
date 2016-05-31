//
//  Chat.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Chat.h"
#import "AppEngine.h"
#import "PFUser+Attributes.h"
#import "MessageCell.h"
#import "CachedFile.h"

#define meId self.me.objectId
#define userId self.user.objectId

@interface Chat()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MessageBar *messageBar;
@property (nonatomic, strong, readonly) PFUser *me;
@property (nonatomic, weak, readonly) AppEngine *engine;
@property (nonatomic, strong) PFUser* user;
@property (nonatomic, strong) UIImage* myPhoto;
@property (nonatomic, strong) UIImage* userPhoto;
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
    
    [CachedFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        self.userPhoto = [UIImage imageWithData:data];
        [self.tableView reloadData];
    } fromFile:user.profilePhoto];

    [CachedFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        self.myPhoto = [UIImage imageWithData:data];
        [self.tableView reloadData];
    } fromFile:self.me.profilePhoto];
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
    Message *message = [Message new];
    message.fromUser = self.me;
    message.toUser = self.user;
    message.msgType = barMessage[AppMessageType];
    message.msgContent = barMessage[AppMessageContent];
    message.isRead = @(NO);
    message.isSyncFromUser = @(YES);

    if ([self.me.objectId isEqualToString:self.user.objectId]) {
        message.isSyncToUser = @(YES);
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
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];

    id message = [AppEngine appEngineMessagesWithUserId:userId][indexPath.row];
    [cell setMessage:message myPhoto:self.myPhoto userPhoto:self.userPhoto];

    return cell;
}

- (CGFloat) appropriateLineHeightForMessage:(NSDictionary*)message
{
    const CGFloat inset = 8;
    CGFloat width = [[[UIApplication sharedApplication] keyWindow] bounds].size.width * 0.7f;
    NSString *string = [message[AppMessageContent] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    UIFont *font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    
    CGRect frame = rectForString(string, font, width);
    return frame.size.height+inset*4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id message = [AppEngine appEngineMessagesWithUserId:userId][indexPath.row];
    return [self appropriateLineHeightForMessage:message];
}

- (IBAction)tappedOutside:(id)sender {
    [self.messageBar pullDownKeyBoard];
}

- (void)keyBoardEvent:(CGRect)kbFrame duration:(double)duration animationType:(UIViewAnimationOptions)animation
{
    float w = self.view.frame.size.width;
    float m = self.messageBar.frame.size.height;
    float h = kbFrame.origin.y-m;
    [UIView animateWithDuration:duration animations:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView setFrame:CGRectMake(0, 0, w, h)];
            [self.messageBar setFrame:CGRectMake(0, h, w, m)];
        });
    } completion:^(BOOL finished) {
        [self scrollToBottomAnimated:NO];
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
