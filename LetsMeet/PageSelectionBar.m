//
//  PageSelectionBar.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 12..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "PageSelectionBar.h"
#import "UIColor+LightAndDark.h"

#define pointerHeight 5.0f

@implementation PageSelectionBar

- (void)awakeFromNib
{
    [self initialize];
}

- (instancetype)init
{
    //    __LF
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.buttons = [NSMutableArray array];
    self.textColor = [UIColor darkGrayColor];
    self.highlightedTextColor = [self.textColor lighterColor];
    self.barColor = self.backgroundColor;
    self.normalFont = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:18]; // [UIFont boldSystemFontOfSize:14];
    self.highlightedFont = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:16]; //[UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    self.backgroundColor = [UIColor clearColor];
    self.index = 0;
}


- (NSUInteger)pages
{
    return self.buttons.count;
}

- (void)setIndex:(NSInteger)index
{
    //    __LF
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

- (void) addButtonWithTitle:(NSString*)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button.titleLabel setFont:self.normalFont];
    [button setTag:self.buttons.count];
    [button addTarget:self action:@selector(tappedItem:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [self.buttons addObject:button];
    [self setIndex:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
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