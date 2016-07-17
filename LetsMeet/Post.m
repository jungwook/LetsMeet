//
//  Post.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Post.h"
#import "SayTextCell.h"
#import "SayMediaCell.h"
#import "MediaPicker.h"
#import "S3File.h"

@interface BorderedTextView : UITextField

@end

@implementation BorderedTextView

- (void)drawRect:(CGRect)rect
{
    CGFloat l = self.bounds.origin.x-4, r = self.bounds.size.width, t = self.bounds.origin.y, b = self.bounds.size.height;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(l, t)];
    [path addLineToPoint:CGPointMake(r, t)];
    [path moveToPoint:CGPointMake(l, b)];
    [path addLineToPoint:CGPointMake(r, b)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
}

@end


@interface Post()
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet BorderedTextView *postTitle;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *now;
@property (weak, nonatomic) IBOutlet UIButton *done;
@property (strong, nonatomic) UserPost* post;
@property (strong, nonatomic) NSMutableArray *posts;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;
@end

@implementation Post

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    roundCorner(self.photo);
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SayTextCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SayTextCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SayMediaCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SayMediaCell"];
    [self addEffectsOnView:self.view];
    [self.postTitle becomeFirstResponder];
    
    self.post = [UserPost mine];
    self.posts = [NSMutableArray array];
    [self.posts addObject:@""];
    
    [self.tableView reloadData];
    
    [[User me] fetched:^{
        self.nickname.text = [User me].nickname;
        self.now.text = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
        [S3File getDataFromFile:[User me].thumbnail completedBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            UIImage *image = data ? [UIImage imageWithData:data] : [User me].sexImage;
            [self.photo setContentMode:UIViewContentModeScaleAspectFill];
            [self.photo setImage:image];
        }];
    }];
    self.height.constant = self.view.bounds.size.height -64 -280;
    [self.view layoutIfNeeded];
}

- (void)addEffectsOnView:(UIView*)view
{
    view.backgroundColor = [UIColor clearColor];
    
    CGRect frame = view.bounds;
    UIVisualEffectView* blurView;
    UIVisualEffectView* vibracyView;
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVibrancyEffect *vibe = [UIVibrancyEffect effectForBlurEffect:blur];
    
    blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.frame = frame;
    
    vibracyView = [[UIVisualEffectView alloc] initWithEffect:vibe];
    vibracyView.frame = frame;
    
    [view insertSubview:vibracyView atIndex:0];
    [view insertSubview:blurView atIndex:0];
}

- (void)scrollToEnd
{
    NSUInteger index = self.posts.count - 1;
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    if ([[self.posts lastObject] isKindOfClass:[NSString class]]) {
        SayTextCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell becomeFirstResponder];
    }
}

- (void)sayText:(NSString *)text changedAtIndex:(NSUInteger)index
{
    __LF
    
    self.done.enabled = !(self.posts.count == 1 && [text isEqualToString:@""]);
    id post = [self.posts objectAtIndex:index];
    
    if ([post isKindOfClass:[NSString class]]) {
        [self.posts removeObjectAtIndex:index];
        [self.posts insertObject:text atIndex:index];
    }
    else {
        NSLog(@"ERROR:Post of different type. should be NSString");
    }
}

- (void)startNewLine
{
    [self.posts addObject:@""];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.posts.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    [self scrollToEnd];
}

- (IBAction)addUserMedia:(UIButton *)sender
{
    __LF
    [self.view endEditing:YES];
    
    MediaPickerUserMediaBlock handler = ^(UserMedia* media) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"JUST 1 SEC" message:@"enter comment for your media" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Enter a comment for your media";
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"SAVE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            media.userId = [User me].objectId;
            media.comment = [alert.textFields firstObject].text;
            
            if ([[self.posts lastObject] isKindOfClass:[NSString class]] && [[self.posts lastObject] isEqualToString:@""]) {
                NSUInteger index = self.posts.count - 1;
                [self.posts insertObject:media atIndex:index];
                [self.tableView reloadData];
                [self scrollToEnd];
            }
            else {
                NSUInteger index = self.posts.count;
                [self.tableView beginUpdates];
                [self.posts addObject:media];
                [self.posts addObject:@""];
                [self.tableView insertRowsAtIndexPaths:@[
                                                         [NSIndexPath indexPathForRow:index inSection:0],
                                                         [NSIndexPath indexPathForRow:index+1 inSection:0],
                                                         ] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                [self scrollToEnd];
            }
            self.done.enabled = YES;
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Add media cancelled");
        }]];
        alert.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    [MediaPicker addMediaOnViewController:self withUserMediaHandler:handler];
}

- (IBAction)sendPost:(UIButton *)sender {
    __LF
    NSLog(@"DS:%@", self.posts);
    
    self.post.title = self.postTitle.text;
    self.post.location = [User me].location;
    [self.posts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            if (![obj isEqualToString:@""]) {
                [self.post addUniqueObject:obj forKey:@"posts"];
            }
        }
        else {
            [self.post addUniqueObject:obj forKey:@"posts"];
        }
    }];
    
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.view endEditing:YES];
        [self killThisView];
    }];
}

- (IBAction)tappedOutside:(id)sender {
    [self.view endEditing:YES];
}

- (void)dealloc
{
    __LF
}

- (IBAction)dismissView:(id)sender
{
    [self killThisView];
}

- (void) killThisView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id post = [self.posts objectAtIndex:indexPath.row];
    
    if ([post isKindOfClass:[NSString class]]) {
        SayTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SayTextCell" forIndexPath:indexPath];
        [cell setPost:post];
        [cell setEditable:(indexPath.row == self.posts.count-1)];
        cell.parent = self;
        cell.index = indexPath.row;
        return cell;
    }
    else if ([post isKindOfClass:[UserMedia class]]) {
        SayMediaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SayMediaCell" forIndexPath:indexPath];
        cell.media = post;
        return cell;
    }
    else {
        NSLog(@"ERROR: Error loading post of <%@> class", [post class]);
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    const CGFloat hf = 0.5f;
    
    NSUInteger row = indexPath.row;
    
    id post = [self.posts objectAtIndex:row];
    
    if ([post isKindOfClass:[NSString class]] && row != (self.posts.count-1)) {
        CGRect rect = rectForString(post, [UIFont systemFontOfSize:14], tableView.bounds.size.width-20);
        return rect.size.height - 5;
    }
    else if ([post isKindOfClass:[UserMedia class]]) {
        UserMedia *media = post;
        
        CGSize mediaSize = media.mediaSize;
        CGFloat w = tableView.bounds.size.width;
        return mediaSize.width > 0 ? hf * w * mediaSize.height / mediaSize.width: 300;
    }
    else {
        return tableView.bounds.size.height * hf;
    }
}

@end
