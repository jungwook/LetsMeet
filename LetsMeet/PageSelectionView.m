//
//  PageSelectionView.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PageSelectionView.h"
#import "UIColor+LightAndDark.h"

#define PAGESELECTIONVIEWSUBVIEW 1199

#define pointerHeight 5.0f

@interface PageSelectionView()
@property (nonatomic, strong) PageSelectionBar *selectionBar;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation PageSelectionView

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
//    __LF
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
//    __LF
    self.selectionBar.frame = CGRectMake(0, 0, self.bounds.size.width, self.barHeight+pointerHeight);
    self.pageControl.frame = CGRectMake(0, self.bounds.size.height-25, self.bounds.size.width, 10);
    self.scrollView.frame = CGRectMake(0, self.barHeight, self.bounds.size.width, self.bounds.size.height-self.barHeight);

    CGFloat height = self.scrollView.bounds.size.height, width = self.scrollView.frame.size.width;
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (view.tag == PAGESELECTIONVIEWSUBVIEW) {
            view.frame = CGRectMake(width*idx, self.scrollView.bounds.origin.y, width, height);
        }
    }];
    self.scrollView.contentSize = CGSizeMake(width*self.selectionBar.pages, height+self.scrollView.bounds.origin.y);
}

- (void)awakeFromNib
{
    PageSelectionBlock handler = ^(NSUInteger index) {
        [self showPage:index];
    };
    self.barHeight = 44;
    self.backgroundColor = [UIColor clearColor];
    self.scrollView = [UIScrollView new];
    self.scrollView.backgroundColor = [UIColor yellowColor];
    [self.scrollView setContentInset:UIEdgeInsetsZero];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    self.selectionBar = [PageSelectionBar new];
    self.selectionBar.barColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    self.selectionBar.handler = handler;
    [self addSubview:self.selectionBar];
    
    self.pageControl = [UIPageControl new];
    [self.pageControl addTarget:self action:@selector(pageSelected:) forControlEvents:UIControlEventValueChanged];

    [self addSubview:self.pageControl];
    [self layoutIfNeeded];
}

- (void)setBarHeight:(CGFloat)barHeight
{
    _barHeight = barHeight;
    [self setNeedsLayout];
    [self.selectionBar setNeedsLayout];
    [self.selectionBar setNeedsDisplay];
}

- (void)setBarColor:(UIColor *)barColor
{
    _barColor = barColor;
    self.selectionBar.barColor = barColor;
    [self.selectionBar setNeedsDisplay];
}

- (void) addButtonWithTitle:(NSString*)title view:(UIView<PageSelectionViewProtocol>*)view
{
//    __LF
    [view setTag:PAGESELECTIONVIEWSUBVIEW];
    [view setFrame:self.bounds];
    if ([view respondsToSelector:@selector(viewDidLoad)]) {
        [view viewDidLoad];
    }
    
    [self.selectionBar addButtonWithTitle:title];
    [self.selectionBar setIndex:0];
    self.pageControl.numberOfPages = self.selectionBar.pages;
    [self.scrollView addSubview:view];
    [self layoutIfNeeded];
}

- (void) pageSelected:(UIPageControl*)sender
{
    [self showPage:sender.currentPage];
    [self.selectionBar setIndex:sender.currentPage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat x = scrollView.contentOffset.x, sw = scrollView.bounds.size.width;
    NSInteger index = (x / sw);
    if (index != self.pageControl.currentPage) {
        [self.pageControl setCurrentPage:index];
        [self.selectionBar setIndex:index];
    }
}

- (void) showPage:(NSInteger)page
{
    [self.scrollView scrollRectToVisible:CGRectMake(page*self.scrollView.bounds.size.width,
                                                    self.scrollView.bounds.origin.y,
                                                    self.scrollView.bounds.size.width,
                                                    self.scrollView.bounds.size.height) animated:YES];
}


- (void)setHandler:(PageSelectionBlock)handler
{
    self.selectionBar.handler = handler;
}

- (void)setTextColor:(UIColor *)textColor
{
    self.selectionBar.textColor = textColor;
}

@end
