//
//  UsersTableBase.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "UsersTableBase.h"
#import "RefreshControl.h"
#import "Notifications.h"

@interface UsersTableBase ()
@property (nonatomic, weak) User *me;
@property (nonatomic, strong) FileSystem *system;
@property (nonatomic, strong) RefreshControl *refresh;
@property (nonatomic, strong) Notifications *notifications;
@end

@implementation UsersTableBase

- (void)awakeFromNib
{
    __LF;
    self.notifications = [Notifications notificationWithMessage:^(id bullet) {
        [self refreshContents];
    } broadcast:^(id senderId, NSString *message, NSTimeInterval duration) {
        
    } refresh:nil];
}

- (void)refreshContents
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    __LF;
    [super viewWillAppear:animated];
    [self.notifications on];
    [self refreshContents];
}

- (void)viewWillDisappear:(BOOL)animated
{
    __LF
    [super viewWillDisappear:animated];
    [self.notifications off];
}

- (void)viewDidLoad {
    __LF
    [super viewDidLoad];
    self.me = [User me];
    self.system = [FileSystem new];
    
    self.refresh = [RefreshControl initWithCompletionBlock:^(UIRefreshControl *refreshControl) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshUsers)]) {
            [self.delegate refreshUsers];
        }
    }];
    
    [self setRefreshControl:self.refresh];
    [self.refresh beginRefreshing];
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshUsers)]) {
        [self.delegate refreshUsers];
    }
    
    [self.notifications setNotification:@"HELLO" forAction:^void(id actionParams) {
        NSLog(@"%@", actionParams);
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HELLO" object:@"lalala"];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (NSArray*) users
{
    static BOOL delegateSet = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(users)]) {
        delegateSet = YES;
    }
    
    if (delegateSet) {
        return [self.delegate users];
    }
    else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellForRowAtIndexPath:)]) {
        return [self.delegate cellForRowAtIndexPath:indexPath];
    }
    else {
        return [[UITableViewCell alloc] init];
    }
}

/*
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
