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
#import "CachedFile.h"

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
@property (nonatomic, strong) UIImage *image;
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



- (void)setupMessage:(NSMutableDictionary *)message
{
    const CGFloat offset = 45;
    const CGFloat inset = 10;
    
    CGFloat width = [[[UIApplication sharedApplication] keyWindow] bounds].size.width * 0.7f;
    
    if (message.type == kMessageTypeText) {
        NSString *string = [message.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        CGRect frame = rectForString(string, self.messageLabel.font, width);
        CGFloat w = frame.size.width+2.5*inset;
        
        self.leading.constant = self.isMine ? self.bounds.size.width-w-offset-20 : offset;
        self.trailing.constant = self.isMine ? offset : self.bounds.size.width-w-offset-20;
        self.messageLabel.text = string;
        self.messagePhotoView.alpha = NO;
        self.messageLabel.alpha = YES;
    }
    else if (message.type == kMessageTypePhoto) {
        NSData *data = message.data ? message.data : [CachedFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error, BOOL fromCache) {
            if (!error) {
                message.data = data;
                data = message.data;
                [message save];
                if ([self.delegate respondsToSelector:@selector(redrawCell:)]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.delegate redrawCell:message];
                    });
                }
            }
            else {
                NSLog(@"ERROR GETTING DATA:%@", error.localizedDescription);
            }
        } name:message.fileName andURL:[NSURL URLWithString:message.fileURL]];
        
        self.image = [UIImage imageWithData:data];
        
        CGFloat w = width;
        if (!self.image) {
            self.image = [UIImage imageNamed:@"guy"]; //Loading Image...
        }
        
        CGFloat h = w * self.image.size.height / self.image.size.width;
        UIImage *image = scaleImage(self.image, CGSizeMake(w, h));
        
        drawImage(image, self.messagePhotoView);
        self.leading.constant = self.isMine ? self.bounds.size.width-w-offset-20 : offset;
        self.trailing.constant = self.isMine ? offset : self.bounds.size.width-w-offset-20;
        self.messagePhotoView.alpha = YES;
        self.messageLabel.alpha = NO;

        self.balloon.gestureRecognizers = nil;
        [self.balloon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)]];
    }
    self.leadingLabel.constant = self.isMine ? 10 : 15;
}

- (void) imageTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tappedPhoto:image:view:)]) {
        [self.delegate tappedPhoto:self.message image:self.image view:self.balloon];
    }
}

- (void)setupUserName:(NSString*)userName date:(NSDate*)date
{
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    self.name.text = [NSString stringWithFormat:@"%@ %@", self.isMine ? @"" : userName, dateString];
    self.name.textAlignment = self.isMine ? NSTextAlignmentRight : NSTextAlignmentLeft;
}

- (void)setMessage:(NSMutableDictionary *)message
           myPhoto:(UIImage*)myPhoto
         userPhoto:(UIImage*)userPhoto
          userName:(NSString*)userName
            myName:(NSString*) myName
{
    _message = message;
    _isMine = message.isFromMe;
    [self.balloon setIsMine:self.isMine];
    self.myPhoto.alpha = self.isMine;
    self.photo.alpha = !self.isMine;

    [self setupUserName:userName date:message.updatedAt];
    [self setupMyPhoto:myPhoto userPhoto:userPhoto];
    [self setupMessage:message];
}

- (void)dealloc
{
    NSLog(@"DEALLOC CELL");
}

@end
