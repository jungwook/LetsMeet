//
//  DisplayLinkView.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 26..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "DisplayLinkView.h"

@implementation DisplayLinkView

- (void)awakeFromNib
{
    self.isRecording = YES;
    self.progress = 0.0;
}

- (void)layoutSubviews
{
    self.backgroundColor = self.superview.backgroundColor;
}

- (void)displayRecording
{
    const CGFloat lineWidth = 5.f;
    const CGFloat barWidth = 3.0f;
    const CGFloat offset = 0.5f;
    const CGFloat scale = 5;
    
    CGFloat w = self.bounds.size.width/lineWidth;
    CGFloat h = self.bounds.size.height;
    
    NSUInteger l = self.audioData.length;
    NSUInteger start = MAX(w - l, 0);
    NSUInteger rangeStart = MAX(l - w, 0);
    NSUInteger rangeLength = l - rangeStart;
    
    NSData *small = [self.audioData subdataWithRange:NSMakeRange(rangeStart, rangeLength)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextSetLineWidth(context, barWidth);
    for (NSUInteger i = start; i<w; i++) {
        CGFloat amp = ampAtIndex(i-start, small)*scale;
        CGFloat val = MAX(MIN(amp*h*offset, h*offset), 1.0f);
        
        CGContextMoveToPoint(context, i*lineWidth, 0.5*h - val);
        CGContextAddLineToPoint(context, i*lineWidth, 0.5*h + val);
    }
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)displayPlayback
{
    const CGFloat lineWidth = 5.f;
    const CGFloat barWidth = 3.0f;
    const CGFloat offset = 0.5f;
    const CGFloat scale = 5;
    
    CGFloat w = self.bounds.size.width/lineWidth;
    CGFloat h = self.bounds.size.height;
    
    NSUInteger l = self.audioData.length;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:1.0 alpha:1.0] CGColor]);
    CGContextSetLineWidth(context, barWidth);
    
    BOOL passed = NO;
    
    for (NSUInteger i = 0; i<w; i++) {
        int index = (int) (((CGFloat)i)*((CGFloat)l)/w);
        CGFloat amp = ampAtIndex(index, self.audioData)*scale;
        CGFloat val = MAX(MIN(amp*h*offset, h*offset), 1.0f);
        
        if (!passed) {
            if (i>=self.progress*w) {
                passed = YES;
                CGContextDrawPath(context, kCGPathStroke);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.9 alpha:1.0] CGColor]);
                CGContextSetLineWidth(context, barWidth);
            }
        }
        CGContextMoveToPoint(context, i*lineWidth, 0.5*h - val);
        CGContextAddLineToPoint(context, i*lineWidth, 0.5*h + val);
    }
    
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)setIsRecording:(BOOL)isRecording
{
    _isRecording = isRecording;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.isRecording) {
        [self displayRecording];
    } else {
        [self displayPlayback];
    }
}

@end