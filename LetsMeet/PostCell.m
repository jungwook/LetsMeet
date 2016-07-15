//
//  PostCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PostCell.h"
@interface PostCell()

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SayCell"];
}

- (void)setUser:(User *)user
{
    _user = user;
    
    self.nickname.text = self.user.nickname;
    self.now.text = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle];
    
    
}

- (IBAction)addMedia:(id)sender {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *sayTextCell = [tableView dequeueReusableCellWithIdentifier:@"SayCell" forIndexPath:indexPath];
    
    return sayTextCell;
}
@end
