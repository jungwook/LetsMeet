//
//  ChatUsers.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ChatUsers.h"
#import "AppEngine.h"
#import "UserCell.h"


@interface ChatUsers()
@property (nonatomic, strong) UIRefreshControl *refresh;
@property (nonatomic, weak, readonly) NSArray *users;
@property (nonatomic, weak, readonly) AppEngine *engine;

@end

@implementation ChatUsers

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        _engine = [AppEngine engine];
        _users = self.engine.usersNearMe;

        self.refresh = [UIRefreshControl new];
        [self.refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.refresh];
        [self sendSubviewToBack:self.refresh];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(messagesLoaded:)
                                                     name:AppUserMessagesReloadedNotification
                                                   object:nil];
    }
    return self;
}

- (void)refresh:(id)sender
{
    [[AppEngine engine] reloadNearUsers];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserMessagesReloadedNotification
                                                  object:nil];
    
}

- (void)messagesLoaded:(id)sender
{
    [self reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    return cell;
}

@end
