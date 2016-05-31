//
//  MessageCell.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 31..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "MessageCell.h"
#import "Balloon.h"
#import "AppEngine.h"   

@interface MessageCell()
@property (weak, nonatomic) IBOutlet UIView *photo;
@property (weak, nonatomic) IBOutlet UIView *myPhoto;
@property (weak, nonatomic) IBOutlet Balloon *balloon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leading;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@end


@implementation MessageCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)setMessage:(NSDictionary *)message myPhoto:(UIImage*)myPhoto userPhoto:(UIImage*)userPhoto
{
    const CGFloat offset = 50;
    CGFloat width = [[[UIApplication sharedApplication] keyWindow] bounds].size.width * 0.7f;
    _message = message;

    const CGFloat inset = 8;
    NSString *string = [self.message[AppMessageContent] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    self.messageLabel.text = string;
    
    CGRect frame = rectForString(string, self.messageLabel.font, width);
    CGFloat w = frame.size.width+2*inset;
    
    BOOL isMine = [message[@"fromUser"] isEqualToString:[PFUser currentUser].objectId];
    [self.balloon setIsMine:isMine];
    
    self.leading.constant = isMine ? self.bounds.size.width-w-(offset+2*inset) - 20: offset;
    self.trailing.constant = isMine ? offset : self.bounds.size.width-w-(offset+2*inset) -20;
    
    self.myPhoto.alpha = isMine;
    self.photo.alpha = !isMine;
    
    drawImage(myPhoto, self.myPhoto);
    drawImage(userPhoto, self.photo);
    
    circleizeView(self.photo, 0.2);
    circleizeView(self.myPhoto, 0.2);
    
    self.balloon.backgroundColor = isMine ?
    [UIColor colorWithRed:100/255.f green:167/255.f blue:229/255.f alpha:1] :
    [UIColor colorWithRed:110/255.f green:200/255.f blue:41/255.f alpha:1];
    
}

-(CGFloat)appropriateHeight
{
    return 0;
}

- (void)dealloc
{
    NSLog(@"DEALLOC CELL");
}

@end
