//
//  NearMe.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 3..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "NearMe.h"


@interface TopBar : UIView
@property (nonatomic) NSUInteger index;
@end

@interface TopBar()

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
    self.backgroundColor = [UIColor clearColor];
}

- (void)setIndex:(NSUInteger)index
{
    _index = index;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIColor *blue = [UIColor colorWithRed:95/255.f green:167/255.f blue:229/255.f alpha:1.0f];
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
    CGContextSetFillColorWithColor(context, blue.CGColor);
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
}

@end

@interface NearMe ()
@property (weak, nonatomic) IBOutlet TopBar *bar;

@end

@implementation NearMe

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)barItemSelected:(UIButton *)sender {
    __LF
    self.bar.index = sender.tag;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
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
