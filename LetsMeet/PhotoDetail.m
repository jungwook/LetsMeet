//
//  PhotoDetail.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 1..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PhotoDetail.h"

@interface PhotoDetail () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImage *photo;
@end

@implementation PhotoDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize size = self.photo.size;
    CGSize Size = self.view.bounds.size;
    
    NSLog(@"FRAME SIZE:%@ IMAGE:%@", NSStringFromCGSize(Size), NSStringFromCGSize(size));
    self.scrollView.scrollEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.bounces = YES;
    self.scrollView.clipsToBounds = YES;
//    self.scrollView.minimumZoomScale = MIN(1, Size.height / size.height);
//    self.scrollView.maximumZoomScale = MAX(self.scrollView.minimumZoomScale, Size.height / size.height);
    self.scrollView.delegate = self;
    self.scrollView.contentSize = size;
    self.scrollView.contentOffset = CGPointMake(size.width/2-self.scrollView.bounds.size.width/2, size.height/2-self.scrollView.bounds.size.height/2);
    self.imageView.contentMode = UIViewContentModeCenter;
    [self.imageView setImage:self.photo];
}

-(void)setMessage:(NSDictionary *)message
{
    NSData *data = message[@"file"][@"data"];
    self.photo = [UIImage imageWithData:data];
    NSLog(@"IMAGE:%@", self.photo);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
