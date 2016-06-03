//
//  InBox.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "InBox.h"
#import "Chat.h"
#import "AppEngine.h"
#import "UserCell.h"
#import "UIBarButtonItem+Badge.h"

@interface InBox ()
@property (nonatomic, strong, readonly) PFUser* me;
@property (nonatomic, weak, readonly) AppEngine *engine;
@property (nonatomic, strong) UIRefreshControl *refresh;

@property (nonatomic, strong) NSMutableArray* users;

@end

@implementation InBox

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _me = [PFUser currentUser];
        _engine = [AppEngine engine];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMessageReceived:)
                                                 name:AppUserNewMessageReceivedNotification
                                               object:nil];
    [self.tableView reloadData];
    SENDNOTIFICATION(AppUserRefreshBadgeNotificaiton, nil);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserNewMessageReceivedNotification
                                                  object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refresh = [[UIRefreshControl alloc] init];
    [self setRefreshControl:self.refresh];
    [self.refresh addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];

    [self refreshUsers];
}

- (void) refreshUsers
{
    [AppEngine appEngineInboxUsers:^(NSArray *objects) {
        self.users = [NSMutableArray arrayWithArray:objects];
        [self.tableView reloadData];
    }];
}

- (void) refreshPage
{
    NSLog(@"PAGE REFRESH");
    [AppEngine appEngineInboxUsers:^(NSArray *objects) {
        self.users = [NSMutableArray arrayWithArray:objects];
        if ([self.refresh isRefreshing]) {
            [self.tableView reloadData];
            [self.refresh endRefreshing];
        }
    }];
}

- (void) newMessageReceived:(NSNotification*)notification
{
    Message* message = notification.object;
    id fromUser = message.fromUserId;
    id toUser = message.toUserId;
    
    if ([fromUser isEqualToString:self.me.objectId] || [toUser isEqualToString:self.me.objectId]) {
        [self refreshUsers];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InboxCell";
    PFUser *user = self.users[indexPath.row];
    UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setUser:user andMessages:[AppEngine appEngineMessagesWithUserId:user.objectId]];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"GotoChat"])
    {
        NSUInteger row = [self.tableView indexPathForSelectedRow].row;
        PFUser *selectedUser = self.users[row];
        Chat *vc = [segue destinationViewController];
        [vc setChatUser:selectedUser];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFUser *user = self.users[indexPath.row];
        
        if ([AppEngine appEngineRemoveAllMessagesFromUserId:user.objectId]) {
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [AppEngine appEngineInboxUsers:^(NSArray *objects) {
                self.users = [NSMutableArray arrayWithArray:objects];
                [tableView endUpdates];
            }];
        }
//        [self.tableView reloadData];
    }
}

@end
