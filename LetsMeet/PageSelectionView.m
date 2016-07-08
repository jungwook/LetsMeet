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

@interface PageSelectionView()
@property (nonatomic, strong) NSMutableArray* buttons;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation PageSelectionView

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.buttons = [NSMutableArray array];
    self.textColor = [UIColor colorWithRed:183/255.0f green:233/255.0f blue:114/255.0f alpha:1.0f];
    self.highlightedTextColor = [UIColor colorWithRed:183/255.0f green:233/255.0f blue:114/255.0f alpha:0.6f];
    self.barColor = self.backgroundColor;
    self.normalFont = [UIFont boldSystemFontOfSize:14];
    self.highlightedFont = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    self.backgroundColor = [UIColor clearColor];
    self.index = 0;
    
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.scrollView translatesAutoresizingMaskIntoConstraints];
    
    [self addSubview:self.scrollView];
    self.pageControl = [UIPageControl new];
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;

    UILayoutGuide* margins = self.layoutMarginsGuide;
    [self.pageControl.heightAnchor constraintEqualToConstant:25];
    [self.pageControl.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor];
    [self.pageControl.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor];
    [self.pageControl.bottomAnchor constraintEqualToAnchor:margins.bottomAnchor];
    
    [self addSubview:self.pageControl];
}

- (void)setHandler:(PageSelectionBlock)handler
{
    _handler = handler;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = [textColor lighterColor];
    _highlightedTextColor = [textColor darkerColor];
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
    [self setNeedsDisplay];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == self.index) {
            [obj setTitleColor:self.textColor forState:UIControlStateNormal];
            [obj.titleLabel setFont:self.normalFont];
        }
        else {
            [obj setTitleColor:self.highlightedTextColor forState:UIControlStateNormal];
            [obj.titleLabel setFont:self.highlightedFont];
        }
    }];
}

- (void) addButtonWithTitle:(NSString*)title view:(UIView *)view
{
    const CGFloat offset = 16;
    CGFloat h = self.bounds.size.height - pointerHeight, height = self.bounds.size.height, width = self.bounds.size.width;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button.titleLabel setFont:self.normalFont];
    [button setTag:self.buttons.count];
    [button addTarget:self action:@selector(tappedItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setFrame:CGRectMake([self nextStartPos], 0, CGRectGetWidth(rectForString(title, self.normalFont, CGFLOAT_MAX))+offset, h)];
    [self addSubview:button];

    [self.buttons addObject:button];
    self.scrollView.contentSize = CGSizeMake(width*self.buttons.count, height);
    view.frame = CGRectMake(width*(self.buttons.count-1), 0, width, height);
    self.pageControl.numberOfPages = self.buttons.count;
    [self.scrollView addSubview:view];
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

- (void)drawRect:(CGRect)rect
{
    CGFloat __block ix = 0;
    CGFloat l = self.bounds.origin.x, r = self.bounds.size.width, t = self.bounds.origin.y, b = self.bounds.size.height-pointerHeight;
    
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
    
    self.layer.shadowPath = path.CGPath;
    self.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.7f].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOpacity = 0.3f;
}

@end
