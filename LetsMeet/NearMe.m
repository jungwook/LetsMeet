//
//  NearMe.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 3..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "NearMe.h"
#import "MediaViewer.h"
#import "RefreshControl.h"
#import "UIButton+Badge.h"
#import "ProfileMain.h"

#define blueColor [UIColor colorWithRed:95/255.f green:167/255.f blue:229/255.f alpha:1.0f]
#define greyColor [UIColor colorWithWhite:0.3 alpha:1.0]

@interface NearMeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet MediaView *photo;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UIButton *like;
@property (weak, nonatomic) User *user;
@property (weak, nonatomic) NearMe *parent;
@end

@implementation NearMeCell

- (void)awakeFromNib
{
    __LF
    [self.photo setIsCircle:YES];
    self.distance.textColor = blueColor;
    self.nickname.textColor = blueColor;
    self.desc.textColor = greyColor;
}

- (void)setUser:(User *)user
{
    __LF
    _user = user;
    [self.photo loadMediaFromUser:user];
    
    double distance = [[User me].location distanceInKilometersTo:self.user.location];
    self.distance.text = distanceString(distance);
    self.nickname.text = user.nickname;
    self.desc.text = [NSString stringWithFormat:@"%@ / %@", user.age ? user.age : @"", user.intro ? user.intro : @""];
    self.like.selected = [[User me].likes containsObject:self.user.objectId];
}

- (IBAction)showProfile:(id)sender {
    [self.parent showProfileForUser:self.user];
}

- (IBAction)likeUser:(UIButton *)sender {
    User *me = [User me];
    
    NSArray *likes = me.likes;
    if ([likes containsObject:self.user.objectId]) {
        [me removeObject:self.user.objectId forKey:@"likes"];
        sender.selected = NO;
    }
    else {
        [me addUniqueObject:self.user.objectId forKey:@"likes"];
        sender.selected = YES;
    }
    [me saveInBackground];
}

@end

@interface TopBar : UIView
@property (nonatomic) NSUInteger index;
@end


@interface NearMe ()
@property (weak, nonatomic) IBOutlet TopBar *bar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FileSystem *system;
@property (strong, nonatomic) User *me;
@property (strong, nonatomic) NSMutableDictionary *users;
@property (strong, nonatomic) NSArray *usersData;
@property (strong, nonatomic) RefreshControl *refresh;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) BOOL grouped;
@end

@implementation NearMe

- (void)awakeFromNib
{
    self.system = [FileSystem new];
    self.me = [User me];
    self.users = [NSMutableDictionary dictionary];
    self.grouped = YES;
    self.refresh = [RefreshControl initWithCompletionBlock:^(UIRefreshControl *refreshControl) {
        [self reloadAllUsersOnCondition:self.bar.index];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView addSubview:self.refresh];
    [self reloadAllUsersOnCondition:self.bar.index]; //All users initially
}

- (void) showProfileForUser:(User*)user
{
    ProfileMain* main = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileMain"];
    [main setMe:user];
    main.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:main animated:YES completion:nil];
}

- (IBAction)barItemSelected:(UIButton *)sender {
    __LF
    self.bar.index = sender.tag;
    [self reloadAllUsersOnCondition:sender.tag];
}

- (IBAction)groupItemSelected:(UIButton*)sender {
    sender.selected = !sender.selected;
    self.grouped = sender.selected;
    [self rearrangeUsers:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)usersNear:(User*)user completionHandler:(UsersArrayBlock)block condition:(NSUInteger)condition
{
    PFQuery *query = [User query];
    switch (condition) {
        case 1:
            [query whereKey:@"sex" equalTo:@(kSexFemale)];
            break;
        case 2:
            [query whereKey:@"sex" equalTo:@(kSexMale)];
            break;
        case 3:
            [query whereKey:@"objectId" containedIn:[[PFUser currentUser] objectForKey:@"likes"]];
            break;
        default:
            break;
    }
    
    [query whereKey:@"location" nearGeoPoint:user.location];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        if (block)
            block([users sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                PFGeoPoint *p1 = ((User*)obj1).location;
                PFGeoPoint *p2 = ((User*)obj2).location;
                
                CGFloat distanceA = [user.location distanceInKilometersTo:p1];
                CGFloat distanceB = [user.location distanceInKilometersTo:p2];
                
                if (distanceA < distanceB) {
                    return NSOrderedAscending;
                } else if (distanceA > distanceB) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }]);
    }];
}

- (void)reloadAllUsersOnCondition:(NSUInteger)condition
{
    self.selectedIndexPath = nil;
    if (![self.refresh isRefreshing]) {
        [self.refresh beginRefreshing];
    }
    [self usersNear:self.me completionHandler:^(NSArray<User *> *users) {
        self.usersData = users;
        [self rearrangeUsers:users];
        [self.refresh endRefreshing];
    } condition:condition];
}

- (void) rearrangeUsers:(NSArray*)users
{
    if (!users) {
        users = self.usersData;
    }
    
    self.users = [NSMutableDictionary dictionary];
    
    [users enumerateObjectsUsingBlock:^(User * _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        id intro = self.grouped ? (user.intro ? user.intro : @"Not Set") : @"Everyone";
        id arr = [self.users objectForKey:intro];
        if (arr) {
            [arr addObject:user];
        }
        else {
            [self.users setObject:[NSMutableArray arrayWithObject:user] forKey:intro];
        }
    }];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.users allKeys].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id key = [[self.users allKeys] objectAtIndex:section];
    return ((NSArray*)[self.users objectForKey:key]).count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = indexPath.row % 2 ? [UIColor colorWithRed:252/255.f green:252./255.f blue:252/255.f alpha:1.0f] : [UIColor whiteColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NearMeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NearMe" forIndexPath:indexPath];
    
    id key = [[self.users allKeys] objectAtIndex:indexPath.section];
    User *user = [[self.users objectForKey:key] objectAtIndex:indexPath.row];
    
    cell.user = user;
    cell.parent = self;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.selectedIndexPath]) {
        return 200;
    }
    else {
        return 80;
    }
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    _selectedIndexPath = selectedIndexPath;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = [indexPath isEqual:self.selectedIndexPath] ? nil : indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id key = [[self.users allKeys] objectAtIndex:section];
    return key;
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


@implementation TopBar

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    __LF
    self.backgroundColor = [UIColor clearColor];
}

- (void)setIndex:(NSUInteger)index
{
    __LF
    _index = index;
    [self setNeedsDisplay];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == self.index) {
            obj.highlighted = NO;
        }
        else {
            obj.highlighted = YES;
        }
    }];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat hs = 5, __block ix = 0;
    CGFloat l = self.bounds.origin.x, r = self.bounds.size.width, t = self.bounds.origin.y, b = self.bounds.size.height-hs;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == self.index) {
            *stop = YES;
            ix = obj.frame.origin.x + obj.frame.size.width / 2.0f;
        }
    }];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(l, t)];
    [path addLineToPoint:CGPointMake(r, t)];
    [path addLineToPoint:CGPointMake(r, b)];
    [path addLineToPoint:CGPointMake(ix+hs, b)];
    [path addLineToPoint:CGPointMake(ix, b+hs)];
    [path addLineToPoint:CGPointMake(ix-hs, b)];
    [path addLineToPoint:CGPointMake(l, b)];
    [path addLineToPoint:CGPointMake(l, t)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    CGContextSetFillColorWithColor(context, blueColor.CGColor);
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    
    
    self.layer.shadowPath = path.CGPath;
    self.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.7f].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOpacity = 0.3f;
}



@end
