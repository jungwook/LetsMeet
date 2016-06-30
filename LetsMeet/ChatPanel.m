//
//  ChatPanel.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 30..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ChatPanel.h"
#import "MediaViewer.h"

@interface ChatPanel()
@property (weak, nonatomic) IBOutlet MediaView *userPhoto;
@property (weak, nonatomic) IBOutlet MediaView *myPhoto;
@property (weak, nonatomic) IBOutlet MediaView *map;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (nonatomic, strong) User* me;

@end

@implementation ChatPanel

- (instancetype)initOnceWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"ChatPanel" owner:self options:nil] firstObject];
    if (self) {
        self.frame = frame;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self translatesAutoresizingMaskIntoConstraints];
    }
    return self;
}

+ (instancetype)chatPanelWithFrame:(CGRect)frame
{
    return [[ChatPanel new] initOnceWithFrame:frame];
}

- (void)awakeFromNib
{
    __LF
    UIVisualEffectView *eff = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    eff.frame = self.bounds;
    eff.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [eff translatesAutoresizingMaskIntoConstraints];
    eff.layer.cornerRadius = 30.f;
    eff.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.2].CGColor;
    eff.layer.borderWidth = 0.5f;
    eff.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.userPhoto.layer.cornerRadius = self.userPhoto.bounds.size.width / 2.0f;
    self.userPhoto.layer.masksToBounds = YES;
    self.myPhoto.layer.cornerRadius = self.myPhoto.bounds.size.width / 2.0f;
    self.myPhoto.layer.masksToBounds = YES;
    [self insertSubview:eff atIndex:0];
}

- (void)setUser:(User *)user
{
    _me = [User me];
    _user = user;
    
    [_userPhoto loadMediaFromUser:user];
    [_myPhoto loadMediaFromUser:self.me];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
