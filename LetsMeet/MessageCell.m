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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingLabel;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *messagePhotoView;
@end


@implementation MessageCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)setMessage:(NSDictionary *)message myPhoto:(UIImage*)myPhoto userPhoto:(UIImage*)userPhoto userName:(NSString*)userName myName:(NSString*) myName
{
    const CGFloat offset = 45;
    
    CGFloat width = [[[UIApplication sharedApplication] keyWindow] bounds].size.width * 0.7f;
    _message = message;

    const CGFloat inset = 8;
    NSString *string = [self.message[AppMessageContent] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    CGRect frame = rectForString(string, self.messageLabel.font, width);
    CGFloat w = frame.size.width+2*inset;
    
    BOOL isMine = [message[@"fromUser"] isEqualToString:[PFUser currentUser].objectId];
    [self.balloon setIsMine:isMine];
    
    self.leading.constant = isMine ? self.bounds.size.width-w-(offset+2*inset) -10 : offset;
    self.trailing.constant = isMine ? offset : self.bounds.size.width-w-(offset+2*inset) -10;
    
    self.leadingLabel.constant = isMine ? 10 : 15;
    self.trailingLabel.constant = isMine ? 15 : 10;
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:message[@"updatedAt"] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    self.name.text = [NSString stringWithFormat:@"%@ %@", isMine ? @"" : userName, dateString];
    self.name.textAlignment = isMine ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    self.myPhoto.alpha = isMine;
    self.photo.alpha = !isMine;
    
    drawImage(myPhoto, self.myPhoto);
    drawImage(userPhoto, self.photo);
    
    circleizeView(self.photo, 0.5);
    circleizeView(self.myPhoto, 0.5);    

    if ([message[AppMessageType] isEqualToString:AppMessageTypeMessage]) {
        self.messageLabel.text = string;
    }
    else if ([message[AppMessageType] isEqualToString:AppMessageTypeVideo]) {
        // NSLog VIDEO
    }
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
