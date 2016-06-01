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

@property (nonatomic) BOOL isMine;
@end


@implementation MessageCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)setupMyPhoto:(UIImage *)myPhoto userPhoto:(UIImage*) userPhoto
{
    drawImage(myPhoto, self.myPhoto);
    drawImage(userPhoto, self.photo);
    
    circleizeView(self.photo, 0.5);
    circleizeView(self.myPhoto, 0.5);
}

- (void)setupMessage:(NSDictionary *)message
{
    const CGFloat offset = 45;
    const CGFloat inset = 8;
    
    CGFloat width = [[[UIApplication sharedApplication] keyWindow] bounds].size.width * 0.7f;
    
    if ([message[AppMessageType] isEqualToString:AppMessageTypeMessage]) {
        NSString *string = [self.message[AppMessageContent] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        CGRect frame = rectForString(string, self.messageLabel.font, width);
        CGFloat w = frame.size.width+2*inset;
        
        
        
        self.leading.constant = self.isMine ? self.bounds.size.width-w-(offset+2*inset)-10 : offset;
        self.trailing.constant = self.isMine ? offset : self.bounds.size.width-w-(offset+2*inset)-10;
        self.messageLabel.text = string;
        self.messagePhotoView.alpha = NO;
        self.messageLabel.alpha = YES;
    }
    else if ([message[AppMessageType] isEqualToString:AppMessageTypePhoto]) {
        UIImage *image = [UIImage imageWithData:message[@"file"][@"data"]];
        CGFloat w = width;
        if (image) {
            CGFloat h = w * image.size.height / image.size.width;
            image = scaleImage(image, CGSizeMake(w, h));
            drawImage(image, self.messagePhotoView);
        }
        else {
            
        }
        self.leading.constant = self.isMine ? self.bounds.size.width-w-(offset+2*inset): offset;
        self.trailing.constant = self.isMine ? offset : self.bounds.size.width-w-(offset+2*inset);
        self.messagePhotoView.alpha = YES;
        self.messageLabel.alpha = NO;
    }
    
    self.leadingLabel.constant = self.isMine ? 10 : 15;
//    self.trailingLabel.constant = self.isMine ? 15 : 10;
}

- (void)setupUserName:(NSString*)userName date:(NSDate*)date
{
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    self.name.text = [NSString stringWithFormat:@"%@ %@", self.isMine ? @"" : userName, dateString];
    self.name.textAlignment = self.isMine ? NSTextAlignmentRight : NSTextAlignmentLeft;
}

- (void)setMessage:(NSDictionary *)message
           myPhoto:(UIImage*)myPhoto
         userPhoto:(UIImage*)userPhoto
          userName:(NSString*)userName
            myName:(NSString*) myName
{
    _message = message;
    _isMine = [message[@"fromUser"] isEqualToString:[PFUser currentUser].objectId];
    [self.balloon setIsMine:self.isMine];
    self.myPhoto.alpha = self.isMine;
    self.photo.alpha = !self.isMine;

    [self setupUserName:userName date:message[@"updatedAt"]];
    [self setupMyPhoto:myPhoto userPhoto:userPhoto];
    [self setupMessage:message];
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
