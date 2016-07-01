//
//  ProfileMainView.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 7. 1..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ProfileMainView.h"
#import "MediaViewer.h"
#import "ListPicker.h"

@interface ProfileMainView()
@property (weak, nonatomic) IBOutlet MediaView *mainPhoto;
@property (weak, nonatomic) IBOutlet UITextField *nickname;
@property (weak, nonatomic) IBOutlet UITextField *intro;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *sex;
@property (weak, nonatomic) IBOutlet UIButton *gps;
@property (weak, nonatomic) IBOutlet UILabel *location;
@end

@implementation ProfileMainView

- (void)awakeFromNib
{
    __LF
    self.backgroundColor = [UIColor clearColor];
    [self.mainPhoto setIsCircle:YES];
//    self.layer.contents = (id) [UIImage imageNamed:@"bg"].CGImage;
//    self.layer.contentsGravity = kCAGravityResizeAspectFill;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        __LF
    }
    return self;
}

- (void)sayHi
{
    User *me = [User me];
    [self.mainPhoto loadMediaFromUser:[User me]];
    self.nickname.text = me.nickname;
    self.intro.text = me.intro;
    
    self.intro.text = me.intro ? me.intro : @"";
    [ListPicker pickerWithArray:@[@"우리 만나요!", @"애인 찾아요", @"함께 드라이브 해요", @"나쁜 친구 찾아요", @"착한 친구 찾아요", @"함께 먹으러 가요", @"술친구 찾아요"] onTextField:self.intro selection:^(id data) {
        me.intro = data;
        [me saveInBackground];
    }];
    
    self.sex.text = me.sexString;
    self.age.text = me.age;
}

- (IBAction)addMedia:(id)sender {
    __LF
    if ([self.delegate respondsToSelector:@selector(addMoreMedia)]) {
        [self.delegate addMoreMedia];
    }
}

- (IBAction)gotoInbox:(id)sender {
    [AppDelegate toggleMenu];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AppDelegate toggleMenuWithScreenID:@"InBox"];
    });
}

@end
