//
//  Search.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Search.h"
#import "SearchCell.h"
#import "FileSystem.h"
#import "RefreshControl.h"
#import "Notifications.h"
#import "S3File.h"
#import "Chat.h"
#import "MediaViewer.h"

@interface Search ()
@property (nonatomic, weak) User *me;
@property (nonatomic, strong) NSArray* users;
@property (nonatomic, strong) FileSystem *system;
@property (nonatomic, strong) RefreshControl *refresh;
@property (nonatomic, strong) Notifications *notifications;
@end

@implementation Search

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
        [self reloadAllUsers];
    }];
    
    [self setRefreshControl:self.refresh];
    [self.refresh beginRefreshing];
    [self reloadAllUsers];
    
    [self.notifications setNotification:@"HELLO" forAction:^void(id actionParams) {
        NSLog(@"%@", actionParams);
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HELLO" object:@"lalala"];
}

- (void)reloadAllUsers
{
    [self.system usersNearMeInBackground:^(NSArray<User *> *users) {
        NSLog(@"Loaded %ld users near me", users.count);
        _users = [NSArray arrayWithArray:users];
        [self.refresh endRefreshing];
        [self refreshContents];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    User *user = [self.users objectAtIndex:indexPath.row];
    
    [cell setUser:user tableView:tableView];
    return cell;
}


- (UITableViewCell *)tableView2:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCellBasic" forIndexPath:indexPath];
    User *user = [self.users objectAtIndex:indexPath.row];
    
    cell.textLabel.text = user.nickname;
    cell.detailTextLabel.text = user.intro;
    cell.imageView.image = [UIImage imageNamed:(user.sex == kSexMale) ? @"guy" : @"girl"];
    cell.imageView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    
    cell.tag = indexPath.row;
    [S3File getDataFromFile:user.thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        UIImage *photo = [UIImage imageWithData:data];
        if (fromCache && data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = photo;
                cell.imageView.layer.cornerRadius = cell.imageView.bounds.size.width / 2.0f;
                cell.imageView.layer.masksToBounds = YES;
            });
        }
        else {
            NSArray *visible = [self.tableView visibleCells];
            [visible enumerateObjectsUsingBlock:^(UITableViewCell* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.tag == indexPath.row) {
                    *stop = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        obj.imageView.image = photo;
                        obj.imageView.layer.cornerRadius = cell.imageView.bounds.size.width / 2.0f;
                        obj.imageView.layer.masksToBounds = YES;
                    });
                }
            }];
        }
    } progressBlock:^(int percentDone) {
        
    }];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    __LF
    
    if ([[segue identifier] isEqualToString:@"GotoChat"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        User *selectedUser = self.users[indexPath.row];
        Chat *vc = [segue destinationViewController];
        [vc setUser:selectedUser];
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
