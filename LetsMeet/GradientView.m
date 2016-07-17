//
//  GradientView.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView
+(Class) layerClass {
    __LF
    return [CAGradientLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    __LF
    self = [super initWithCoder:aDecoder];
    if (self) {
        ((CAGradientLayer*)self.layer).colors = @[
                                                  (id) [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0].CGColor,
                                                  (id) [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1].CGColor,
                                                  (id) [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.35].CGColor,
                                                  (id) [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.45].CGColor,
                                                  ];
        ((CAGradientLayer*)self.layer).locations = @[
                                                     [NSNumber numberWithFloat:0.8f],
                                                     [NSNumber numberWithFloat:0.9f],
                                                     [NSNumber numberWithFloat:0.95f],
                                                     [NSNumber numberWithFloat:1.0f],
                                                     ];
        
//        ((CAGradientLayer*)self.layer).colors = [NSArray arrayWithObjects:
//                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.90f].CGColor,
//                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.07f].CGColor,
//                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.03f].CGColor,
//                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
//                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
//                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.1f].CGColor,
//                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.17f].CGColor,
//                                                 (id)[UIColor colorWithWhite:0.0f alpha:0.9f].CGColor,
//                                                 nil];
//        ((CAGradientLayer*)self.layer).locations = [NSArray arrayWithObjects:
//                                                    [NSNumber numberWithFloat:0.0f],
//                                                    [NSNumber numberWithFloat:0.1f],
//                                                    [NSNumber numberWithFloat:0.13f],
//                                                    [NSNumber numberWithFloat:0.3f],
//                                                    [NSNumber numberWithFloat:0.6f],
//                                                    [NSNumber numberWithFloat:0.83f],
//                                                    [NSNumber numberWithFloat:0.9f],
//                                                    [NSNumber numberWithFloat:1.0f],
//                                                    nil];
        
        ((CAGradientLayer*)self.layer).cornerRadius = 2.0f;
        ((CAGradientLayer*)self.layer).masksToBounds = YES;
    }
    return self;
}
@end
