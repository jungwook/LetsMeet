//
//  Preview.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 2..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Preview.h"

@interface CenterScrollView : UIScrollView
@end

@implementation CenterScrollView

-(void)layoutSubviews
{
    [super layoutSubviews];
    UIView* v = [self.delegate viewForZoomingInScrollView:self];
    CGFloat svw = self.bounds.size.width;
    CGFloat svh = self.bounds.size.height;
    CGFloat vw = v.frame.size.width;
    CGFloat vh = v.frame.size.height;
    CGRect f = v.frame;
    if (vw < svw)
        f.origin.x = (svw - vw) / 2.0;
    else
        f.origin.x = 0;
    
    if (vh < svh)
        f.origin.y = (svh - vh) / 2.0 - 64.0f;
    else
        f.origin.y = -64.0f;
    v.frame = f;
}
@end

@interface Preview () <UIScrollViewDelegate>
@property (strong, nonatomic) CenterScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic) CGFloat zoom;
@end

@implementation Preview

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [[CenterScrollView alloc] initWithFrame:self.view.frame];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];
    
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.backgroundColor = [UIColor redColor];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.image = [UIImage imageNamed:@"image2"];
    [self.scrollView addSubview:self.imageView];
    
    NSDictionary *metrics = @{@"height" : @(self.image.size.height), @"width" : @(self.image.size.width)};
    NSDictionary *views = @{@"imageView":self.imageView};
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView(height)]|" options:kNilOptions metrics:metrics views:views]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView(width)]|" options:kNilOptions metrics:metrics views:views]];
    
    self.imageView.image = self.image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    
    [self.scrollView addGestureRecognizer:doubleTap];
    [self initZoom];
}

- (void) doubleTap:(id)sender {
    static CGFloat prev = 1;
    
    CGFloat zoom = self.scrollView.zoomScale;
    [UIView animateWithDuration:0.1 animations:^{
        self.scrollView.zoomScale = prev;
    }];
    prev = zoom;
}

- (void) initZoom {
    float minZoom = MIN(self.view.bounds.size.width / self.image.size.width,
                        self.view.bounds.size.height / self.image.size.height);
    if (minZoom > 1) return;
    
    self.scrollView.minimumZoomScale = minZoom;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.zoomScale = minZoom;
    self.zoom = minZoom;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.zoom = scale;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
