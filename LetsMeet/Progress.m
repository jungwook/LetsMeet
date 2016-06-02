//
//  Progress.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 2..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Progress.h"


@interface Progress()
@end

@implementation Progress

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    _progressLayer.lineWidth = lineWidth;
    _shapeLayer.lineWidth = lineWidth;
}

- (void) initialize
{
    self.strokeColor = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1 ];
    self.progressLabel = [UILabel new];
    self.shapeLayer = [CAShapeLayer new];
    self.progressLayer = [CAShapeLayer new];
    self.lineWidth = 2.0;
    
    self.font = [UIFont systemFontOfSize:30];
    self.progressLabel.font = self.font;
    self.progressLabel.textColor = self.strokeColor;
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.adjustsFontSizeToFitWidth = YES;
    self.progressLabel.hidden = YES;
    [self addSubview:self.progressLabel];
    
    self.progressLayer.strokeColor = self.strokeColor.CGColor;
    self.progressLayer.fillColor = nil;
    self.progressLayer.lineWidth = _lineWidth;
    [self.layer addSublayer:self.progressLayer];
    
    self.shapeLayer.strokeColor = self.strokeColor.CGColor;
    self.shapeLayer.lineWidth = self.lineWidth;
    self.shapeLayer.fillColor = nil;
    self.shapeLayer.lineCap = kCALineCapRound;
    self.shapeLayer.lineJoin = kCALineJoinRound;
    self.shapeLayer.strokeStart = 0;
    self.shapeLayer.strokeEnd = 0;
    
    [self.layer addSublayer:self.shapeLayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetAnimations)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
    self.progressLayer.strokeColor = strokeColor.CGColor;
    self.shapeLayer.strokeColor = strokeColor.CGColor;
    self.progressLabel.textColor = strokeColor;
}

- (void)setProgress:(CGFloat)newProgress
{
    if( newProgress - self.progress >= 0.01 || newProgress >= 100.0) {
        _progress = MIN(MAX(0, newProgress),1);
        self.progressLayer.strokeEnd = _progress;
        if (self.status == Loading) {
            [self.progressLayer removeAllAnimations];
        }
        else if (self.status == Completed) {
            self.shapeLayer.strokeStart = 0;
            self.shapeLayer.strokeEnd = 0;
            [_shapeLayer removeAllAnimations];
        }
        self.status = Progressing;
        
        self.progressLabel.hidden = NO;
        self.progressLabel.text = [NSString stringWithFormat:@"%.0f", self.progress];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat square = MIN(width, height);
    CGRect bounds = CGRectMake(0, 0, width, height);

    self.progressLayer.frame = bounds;
    [self setProgressLayerPath];
    self.shapeLayer.frame = bounds;
    self.shapeLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGFloat labelSquare = sqrt(2) / 2.0f *square;
    self.progressLabel.bounds = CGRectMake(0, 0, labelSquare, labelSquare);
    self.progressLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void) setProgressLayerPath
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = (MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) - self.progressLayer.lineWidth) / 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0.0 endAngle:2*M_PI clockwise:YES];
    
    self.progressLayer.path = path.CGPath;
    self.progressLayer.strokeStart = 0.0;
    self.progressLayer.strokeEnd = 0.0;
}

- (CGPoint) correctJoinPoint
{
    CGFloat r = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2;
    CGFloat m = r/2;
    CGFloat k = self.lineWidth/2;
    
    CGFloat a = 2.0;
    CGFloat b = -4 * r + 2 * m;
    CGFloat c = (r - m) * (r - m) + 2 * r * k - k * k;
    CGFloat x = (-b - sqrt(b * b - 4 * a * c))/(2 * a);
    CGFloat y = x + m;
    
    return CGPointMake(x, y);
}

- (CGPoint) errorJoinPoint
{
    CGFloat r = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2;
    CGFloat k = self.lineWidth/2;
    
    CGFloat a = 2.0;
    CGFloat b = -4 * r;
    CGFloat c = r * r + 2 * r * k - k * k;
    CGFloat x = (-b - sqrt(b * b - 4 * a * c))/(2 * a);
    
    return CGPointMake(x, x);
}

#define dhRingStorkeAnimationKey @"IDLoading.stroke"
#define dhRingRotationAnimationKey @"IDLoading.rotation"

-(void) resetAnimations
{
    if (self.status == Loading) {
        self.status = Unknown;
        [self.progressLayer removeAnimationForKey:dhRingRotationAnimationKey];
        [self.progressLayer removeAnimationForKey:dhRingStorkeAnimationKey];
        
        [self startLoading];
    }
}

- (void) hiddenLoadingView
{
    self.status = Completed;
    self.hidden = YES;
    
    if (self.completionBlock) {
        self.completionBlock();
    }
}

- (void) setStrokeSuccessShapePath {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat square = MIN(width, height);
    CGFloat b = square/2;
    CGFloat oneTenth = square/10;
    CGFloat xOffset = oneTenth;
    CGFloat yOffset = 1.5 * oneTenth;
    CGFloat ySpace = 3.2 * oneTenth;
    CGPoint point = [self correctJoinPoint];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, point.x, point.y);
    CGPathAddLineToPoint(path, nil, b - xOffset, b + yOffset);
    CGPathAddLineToPoint(path, nil, 2 * b - xOffset + yOffset - ySpace, ySpace);
    
    self.shapeLayer.path = path;
    self.shapeLayer.cornerRadius = square/2;
    self.shapeLayer.masksToBounds = true;
    self.shapeLayer.strokeStart = 0.0;
    self.shapeLayer.strokeEnd = 0.0;
}

-(void) setStrokeFailureShapePath {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat square = MIN(width, height);
    CGFloat b = square/2;
    CGFloat space = square/3;
    CGPoint point = [self errorJoinPoint];
    
    //y1 = x1
    //y2 = -x2 + 2b
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, point.x, point.y);
    CGPathAddLineToPoint(path, nil, 2 * b - space, 2 * b - space);
    CGPathMoveToPoint(path, nil, 2 * b - space, space);
    CGPathAddLineToPoint(path, nil, space, 2 * b - space);
    
    self.shapeLayer.path = path;
    self.shapeLayer.cornerRadius = square/2;
    self.shapeLayer.masksToBounds = YES;
    self.shapeLayer.strokeStart = 0;
    self.shapeLayer.strokeEnd = 0.0;
}

#define dhCompletionAnimationDuration 0.3
#define dhHidesWhenCompletedDelay 0.5

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.hidesWhenCompleted) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dhHidesWhenCompletedDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hiddenLoadingView];
        });
    }
    else {
        self.status = Completed;
        if (self.completionBlock)
            self.completionBlock();
    }
}

- (void) startLoading {
    if (self.status == Loading) {
        return;
    }
    
    self.status = Loading;
    
    self.progressLabel.hidden = true;
    self.progressLabel.text = @"0";
    _progress = 0;
    
    self.shapeLayer.strokeStart = 0;
    self.shapeLayer.strokeEnd = 0;
    [self.shapeLayer removeAllAnimations];
    
    self.hidden = false;
    self.progressLayer.strokeEnd = 0.0;
    [self.progressLayer removeAllAnimations];
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.duration = 4.0;
    animation.fromValue = @(0.0);
    animation.toValue = @(2 * M_PI);
    animation.repeatCount = MAXFLOAT;
    [self.progressLayer addAnimation:animation forKey:dhRingRotationAnimationKey];
    
    CGFloat totalDuration = 1.0;
    CGFloat firstDuration = 2.0 * totalDuration / 3.0;
    CGFloat secondDuration = totalDuration / 3.0;
    
    CABasicAnimation* headAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    headAnimation.duration = firstDuration;
    headAnimation.fromValue = @(0.0);
    headAnimation.toValue = @(0.25);
    
    CABasicAnimation* tailAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    tailAnimation.duration = firstDuration;
    tailAnimation.fromValue = @(0.0);
    tailAnimation.toValue = @(1.0);
    
    CABasicAnimation* endHeadAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    endHeadAnimation.beginTime = firstDuration;
    endHeadAnimation.duration = secondDuration;
    endHeadAnimation.fromValue = @0.25;
    endHeadAnimation.toValue = @1.0;
    
    
    CABasicAnimation* endTailAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    endTailAnimation.beginTime = firstDuration;
    endTailAnimation.duration = secondDuration;
    endTailAnimation.fromValue = @1.0;
    endTailAnimation.toValue = @1.0;
    
    CAAnimationGroup* animations = [CAAnimationGroup new];
    animations.duration = firstDuration + secondDuration;
    animations.repeatCount = MAXFLOAT;
    animations.animations = @[headAnimation, tailAnimation, endHeadAnimation, endTailAnimation];
    [self.progressLayer addAnimation:animations forKey:dhRingRotationAnimationKey];
}

- (void) completeLoading:(BOOL)success block:(voidBlock)completion
{
    if (self.status == Completed) {
        return;
    }
    
    self.completionBlock = completion;
    
    self.progressLabel.hidden = true;
    self.progressLayer.strokeEnd = 1.0;
    [self.progressLayer removeAllAnimations];
    
    if (success) {
        [self setStrokeSuccessShapePath];
    } else {
        [self setStrokeFailureShapePath];
    }
    
    CGFloat strokeStart     = 0.25;
    CGFloat strokeEnd       = 0.8;
    CGFloat phase1Duration  = 0.7 * dhCompletionAnimationDuration;
    CGFloat phase2Duration  = 0.3 * dhCompletionAnimationDuration;
    CGFloat phase3Duration  = 0.0;
    
    if (!success) {
        CGFloat square = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        CGPoint point = [self errorJoinPoint];
        CGFloat increase = 1.0/3 * square - point.x;
        CGFloat sum = 2.0/3 * square;
        strokeStart = increase / (sum + increase);
        strokeEnd = (increase + sum/2) / (sum + increase);
        
        phase1Duration = 0.5 * dhCompletionAnimationDuration;
        phase2Duration = 0.2 * dhCompletionAnimationDuration;
        phase3Duration = 0.3 * dhCompletionAnimationDuration;
    }
    
    self.shapeLayer.strokeEnd = 1.0;
    self.shapeLayer.strokeStart = strokeStart;
    CAMediaTimingFunction *timeFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation* headStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    headStartAnimation.fromValue = @0.0;
    headStartAnimation.toValue = @0.0;
    headStartAnimation.duration = phase1Duration;
    headStartAnimation.timingFunction = timeFunction;
    
    CABasicAnimation* headEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    headEndAnimation.fromValue = @0.0;
    headEndAnimation.toValue = @(strokeEnd);
    headEndAnimation.duration = phase1Duration;
    headEndAnimation.timingFunction = timeFunction;
    
    CABasicAnimation* tailStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    tailStartAnimation.fromValue = @0.0;
    tailStartAnimation.toValue = @(strokeStart);
    tailStartAnimation.beginTime = phase1Duration;
    tailStartAnimation.duration = phase2Duration;
    tailStartAnimation.timingFunction = timeFunction;
    
    CABasicAnimation* tailEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    tailEndAnimation.fromValue = @(strokeEnd);
    tailEndAnimation.toValue = success ? @1.0 : @(strokeEnd);
    tailEndAnimation.beginTime = phase1Duration;
    tailEndAnimation.duration = phase2Duration;
    tailEndAnimation.timingFunction = timeFunction;
    
    CABasicAnimation* extraAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    extraAnimation.fromValue = @(strokeEnd);
    extraAnimation.toValue = @1.0;
    extraAnimation.beginTime = phase1Duration + phase2Duration;
    extraAnimation.duration = phase3Duration;
    extraAnimation.timingFunction = timeFunction;
    
    
    CAAnimationGroup* groupAnimation = [CAAnimationGroup new];
    if (success) {
        groupAnimation.animations = @[headEndAnimation, headStartAnimation, tailStartAnimation, tailEndAnimation];
    }
    else {
        groupAnimation.animations = @[headEndAnimation, headStartAnimation, tailStartAnimation, tailEndAnimation, extraAnimation];
    }
    groupAnimation.duration = phase1Duration + phase2Duration + phase3Duration;
    groupAnimation.delegate = self;
    
    [self.shapeLayer addAnimation:groupAnimation forKey:nil];
}

@end    
