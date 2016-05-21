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

@interface InBox ()
@property (nonatomic, strong, readonly) PFUser* me;
@property (nonatomic, strong) NSArray* chatUsers;
@property (nonatomic, weak, readonly) AppEngine *engine;
@property (nonatomic, strong) UIRefreshControl *refresh;
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

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self update];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refresh = [[UIRefreshControl alloc] init];
    [self setRefreshControl:self.refresh];
    [self.refresh addTarget:self action:@selector(update) forControlEvents:UIControlEventValueChanged];
    [self update];
}

- (void)update
{
    [AppEngine appEngineReloadAllChatUsersInBackground:^(NSArray *objects) {
        [AppEngine appEngineReloadUsersOfId:objects inBackgroundWithBlock:^(NSArray *users) {
            self.chatUsers = users;
            if ([self.refresh isRefreshing])
                [self.refresh endRefreshing];
            
            [self.tableView reloadData];
        }];
    }];
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
    return self.chatUsers.count;
}

- (IBAction)toggleMenu:(id)sender {
    [AppDelegate toggleMenu];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InboxCell";
    PFUser *user = self.chatUsers[indexPath.row];
    UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setUser:user andMessages:[self.engine messagesWithUser:user]];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"GotoChat"])
    {
        NSUInteger row = [self.tableView indexPathForSelectedRow].row;
        PFUser *selectedUser = self.chatUsers[row];
        Chat *vc = [segue destinationViewController];
        vc.toUser = selectedUser;
    }
}

@end
