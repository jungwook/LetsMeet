//
//  SelectionBar.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 6..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SelectionBar.h"
#import "UIColor+LightAndDark.h"

#define pointerHeight 5.0f

@interface SelectionBar()
@property (nonatomic, strong) NSMutableArray* buttons;
@property (nonatomic, strong) UIColor* highlightedColor;
@property (nonatomic, strong) UIFont * highlightedFont;
@property (nonatomic, strong) UIFont * normalFont;
@end

@implementation SelectionBar

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
    self.highlightedColor = [UIColor colorWithRed:183/255.0f green:233/255.0f blue:114/255.0f alpha:0.6f];
    self.barColor = self.backgroundColor;
    self.normalFont = [UIFont boldSystemFontOfSize:14];
    self.highlightedFont = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    self.backgroundColor = [UIColor clearColor];
    self.index = 0;
}

- (void)setHandler:(SelectionBarBlock)handler
{
    _handler = handler;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = [textColor lighterColor];
    _highlightedColor = [textColor darkerColor];
}

- (CGFloat)nextStartPos
{
    CGFloat __block sx = 20.0f;
    
    [self.buttons enumerateObjectsUsingBlock:^(UIButton* _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        sx += button.bounds.size.width;
    }];
    
    return sx;
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
            [obj setTitleColor:self.highlightedColor forState:UIControlStateNormal];
            [obj.titleLabel setFont:self.highlightedFont];
        }
    }];
}

- (void) addButtonWithTitle:(NSString*)title width:(CGFloat)width
{
    CGFloat h = self.bounds.size.height - pointerHeight;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button.titleLabel setFont:self.normalFont];
    [button setTag:self.buttons.count];
    [button setFrame:CGRectMake([self nextStartPos], 0, width, h)];
    [button addTarget:self action:@selector(tappedItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
    [self.buttons addObject:button];
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
