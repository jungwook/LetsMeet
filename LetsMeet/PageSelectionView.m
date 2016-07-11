//
//  PageSelectionView.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 8..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PageSelectionView.h"
#import "UIColor+LightAndDark.h"

#define pointerHeight 5.0f

@interface PageSelectionBar : UIView
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor* highlightedTextColor;
@property (nonatomic, strong) UIFont * highlightedFont;
@property (nonatomic, strong) UIFont * normalFont;
@property (nonatomic, strong) NSMutableArray* buttons;
@property (nonatomic, copy) PageSelectionBlock handler;
@property (nonatomic, readonly) NSUInteger pages;
@end

@implementation PageSelectionBar

- (instancetype)init
{
    __LF
    self = [super init];
    if (self) {
        self.buttons = [NSMutableArray array];
        self.textColor = [UIColor darkGrayColor];
        self.highlightedTextColor = [self.textColor lighterColor];
        self.barColor = self.backgroundColor;
        self.normalFont = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:18]; // [UIFont boldSystemFontOfSize:14];
        self.highlightedFont = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:16]; //[UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
        self.backgroundColor = [UIColor clearColor];
        self.index = 0;
    }
    return self;
}


- (NSUInteger)pages
{
    return self.buttons.count;
}

- (void)setIndex:(NSInteger)index
{
    __LF
    _index = index;
    [self setNeedsDisplay];
    [self.buttons enumerateObjectsUsingBlock:^(UIButton* _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        if (button.tag == self.index) {
            [button setTitleColor:self.textColor forState:UIControlStateNormal];
            [button.titleLabel setFont:self.normalFont];
        }
        else {
            [button setTitleColor:self.highlightedTextColor forState:UIControlStateNormal];
            [button.titleLabel setFont:self.highlightedFont];
        }
    }];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = [textColor lighterColor];
    _highlightedTextColor = [textColor darkerColor];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat __block ix = 0;
    CGFloat l = self.bounds.origin.x, r = self.bounds.size.width, t = self.bounds.origin.y, b = self.bounds.size.height-pointerHeight;
    
    [self.buttons enumerateObjectsUsingBlock:^(UIButton* _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        if (button.tag == self.index) {
            *stop = YES;
            ix = button.frame.origin.x + button.frame.size.width / 2.0f;
        }
    }];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    [shadowPath moveToPoint:CGPointMake(l, t+10)];
    [shadowPath addLineToPoint:CGPointMake(r, t+10)];
    [shadowPath addLineToPoint:CGPointMake(r, b)];
    [shadowPath addLineToPoint:CGPointMake(ix+pointerHeight, b)];
    [shadowPath addLineToPoint:CGPointMake(ix, b+pointerHeight)];
    [shadowPath addLineToPoint:CGPointMake(ix-pointerHeight, b)];
    [shadowPath addLineToPoint:CGPointMake(l, b)];
    [shadowPath addLineToPoint:CGPointMake(l, t+10)];
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(l, t)];
    [path addLineToPoint:CGPointMake(r, t)];
    [path addLineToPoint:CGPointMake(r, b)];
    [path addLineToPoint:CGPointMake(ix+pointerHeight, b)];
    [path addLineToPoint:CGPointMake(ix, b+pointerHeight)];
    [path addLineToPoint:CGPointMake(ix-pointerHeight, b)];
    [path addLineToPoint:CGPointMake(l, b)];
    [path addLineToPoint:CGPointMake(l, t)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    CGContextSetFillColorWithColor(context, self.barColor.CGColor);
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    
    self.layer.shadowPath = shadowPath.CGPath;
    self.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.7f].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOpacity = 0.3f;
}

- (void) addButtonWithTitle:(NSString*)title view:(UIView *)view
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button.titleLabel setFont:self.normalFont];
    [button setTag:self.buttons.count];
    [button addTarget:self action:@selector(tappedItem:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [self.buttons addObject:button];
}

- (void)layoutSubviews
{
    const CGFloat offset = -8;
    CGFloat height = self.bounds.size.height-pointerHeight;
    
    CGFloat __block sx = 20.0f;
    [self.buttons enumerateObjectsUsingBlock:^(UIButton* _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat w = CGRectGetWidth(rectForString(button.titleLabel.text, self.normalFont, CGFLOAT_MAX))+offset;
        button.frame = CGRectMake(sx, 0, w, height);
        sx += w;
    }];
}

- (CGFloat)nextStartPos
{
    CGFloat __block sx = 20.0f;
    
    [self.buttons enumerateObjectsUsingBlock:^(UIButton* _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        sx += button.bounds.size.width;
    }];
    
    return sx;
}

- (void) tappedItem:(UIButton*)button
{
    [self setIndex:button.tag];
    
    if (self.handler) {
        self.handler(button.tag);
    }
}

@end

#define PAGESELECTIONVIEWSUBVIEW 1199

@interface PageSelectionView()
@property (nonatomic, strong) PageSelectionBar *selectionBar;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation PageSelectionView

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    __LF
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    __LF
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
    __LF
    [view setTag:PAGESELECTIONVIEWSUBVIEW];
    [view setFrame:self.bounds];
    if ([view respondsToSelector:@selector(viewDidLoad)]) {
        [view viewDidLoad];
    }
    
    [self.selectionBar addButtonWithTitle:title view:view];
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
