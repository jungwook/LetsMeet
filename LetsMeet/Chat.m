//
//  Chat.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 17..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Chat.h"
#import "AppEngine.h"
#import "PFUser+Attributes.h"
#import "CachedFile.h"
#import "ImagePicker.h"
#import "Preview.h"
#import "Progress.h"

#define meId self.me.objectId
#define userId self.user.objectId

@interface Chat()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MessageBar *bar;
@property (nonatomic, strong, readonly) PFUser *me;
@property (nonatomic, weak, readonly) AppEngine *engine;
@property (nonatomic, strong) PFUser* user;
@property (nonatomic, strong) UIImage* myPhoto;
@property (nonatomic, strong) UIImage* userPhoto;
@end

@implementation Chat

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.definesPresentationContext = YES;
        _me = [PFUser currentUser];
        _engine = [AppEngine engine];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bar.barDelegate = self;
    
    NSLog(@"INITIALIZING DATA");
    [[AppEngine appEngineMessagesWithUserId:userId] enumerateObjectsUsingBlock:^(NSMutableDictionary* _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        if (message.isDataAvailable) {
//            message.data = nil;
        }
    }];
}

- (void)dealloc
{
}

- (void)setChatUser:(PFUser *)user
{
    _user = user;
    
    [AppEngine appEngineSetReadAllMyMessagesWithUserId:userId];
    [self.tableView reloadData];
    
    [CachedFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        self.userPhoto = [UIImage imageWithData:data];
        [self.tableView reloadData];
    } fromFile:user.profilePhoto];

    [CachedFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error, BOOL fromCache) {
        self.myPhoto = [UIImage imageWithData:data];
        [self.tableView reloadData];
    } fromFile:self.me.profilePhoto];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMessageReceived:)
                                                 name:AppUserNewMessageReceivedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserNewMessageReceivedNotification
                                                  object:nil];
}


- (void) newMessageReceived:(NSNotification*)notification
{
    // SUPPOSED TO BE USER CHANNEL
    //
    // 1. Message From ME           TO ME.      POSSIBLE FOR TESTING BUT CANNOT SINCE I CANNOT BE FOUND FROM SEARCH
    //                              TO USER     NOT DO ANYTHING
    //                              TO UNKNOWN  BY PASS IN THIS VC (CHAT SCREEN) AND LET INBOX HANDLE (ACTUALLY NOT POSSIBLE)
    // 2. Message From USER         TO ME.      HANDLE BY RESETING ISREAD TO YES AND RELOADING TABLE
    //                              TO USER     BY PASS IN THIS VC (CHAT SCREEN) AND LET INBOX HANDLE OR NOT
    //                              TO UNKNOWN  BY PASS IN THIS VC (CHAT SCREEN) AND LET INBOX HANDLE OR NOT
    // 3. Message From UNKNOWN      TO ME.      BY PASS IN THIS VC (CHAT SCREEN) AND LET INBOX HANDLE OR NOT
    //                              TO USER     BY PASS IN THIS VC (CHAT SCREEN) AND LET INBOX HANDLE OR NOT
    //                              TO UNKNOWN  BY PASS IN THIS VC (CHAT SCREEN) AND LET INBOX HANDLE OR NOT
    //
    // WHAT AM I HANDLING
    //
    id message = notification.object;
    id fromUser = message[AppKeyFromUserField];
    id toUser = message[AppKeyToUserField];
    
    if ([fromUser isEqualToString:meId] && [toUser isEqualToString:userId]) {
        if ([userId isEqualToString:meId]) {
            [AppEngine appEngineSetReadAllMyMessagesWithUserId:fromUser]; // ME = FROM = TO %% SPECIAL CASE
        }
        [self.tableView reloadData];
    }
    else if ([fromUser isEqualToString:userId] && [toUser isEqualToString:meId]) {
        [AppEngine appEngineSetReadAllMyMessagesWithUserId:fromUser];
        [self.tableView reloadData];
    }
    else {
        return;
    }
    [self scrollToBottomAnimated:YES];
}

// From MessageBarDelegate. A message was sent from the messageBar.


- (void)sendMedia
{
    [ImagePicker proceedWithParentViewController:self withPhotoSelectedBlock:^(id data, ImagePickerMediaType type, NSString* stringSize, NSURL* url) {
        switch (type) {
            case kImagePickerMediaPhoto: {
                CGRect frame = [[UIApplication sharedApplication] keyWindow].bounds;
                UIView *black = [UIView new];
                [black setFrame:frame];
                [black setBackgroundColor:[UIColor blackColor]];
                black.alpha = 0;
                [[[UIApplication sharedApplication] keyWindow] addSubview:black];
                
                Progress *progress = [[Progress alloc] initWithFrame:frame];
                [black addSubview:progress];
                
                [UIView animateWithDuration:1 animations:^{
                    black.alpha = 1;
                    [progress startLoading];
                } completion:^(BOOL finished) {
                
                }];
                
                [CachedFile saveData:data named:@"ChatImage.jpg" inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
                    [self sendMessageOfType:[NSMutableDictionary typeStringForType:kMessageTypePhoto] contentFile:file info:stringSize];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [progress completeLoading:YES block:^{
                            [black removeFromSuperview];
                        }];
                    });
                } progressBlock:^(int percentDone) {
                    progress.progress = percentDone / 100.0f;
//                    NSLog(@"SAVING IN PROGRESS:%d", percentDone);
                }];
            }
                break;
            case kImagePickerMediaMovie: {
                [CachedFile saveData:data named:@"ChatMovie.mov" inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
                    [self sendMessageOfType:[NSMutableDictionary typeStringForType:kMessageTypeVideo] contentFile:file info:stringSize];
                } progressBlock:^(int percentDone) {
//                    NSLog(@"SAVING IN PROGRESS:%d", percentDone);
                }];
            }
                break;
            case kImagePickerMediaVoice:
            case kImagePickerMediaNone:
            default:
                break;
        }
        
    } featuring:kImagePickerSourceCamera | kImagePickerSourceLibrary | kImagePickerSourceVoice | kImagePickerSourceURL];
}

- (MessageObject*) message
{
    MessageObject *message = [MessageObject new];
    message.fromUser = self.me;
    message.toUser = self.user;
    message.isRead = NO;
    message.isSyncFromUser = YES;
    
    if ([self.me.objectId isEqualToString:self.user.objectId]) {
        message.isSyncToUser = YES;
    }
    
    return message;
}

////////////////////////////////////
// SEND MEDIA CONTENT PHOTO + VIDEO
////////////////////////////////////

- (void)sendMessageOfType:(NSString*)type contentFile:(PFFile*)content info:(NSString*)sizeInfo
{
    MessageObject *message = [self message];
    message.msgType = type;
    message.msgContent = @"Media Content";
    message.file = content;
    message.mediaInfo = sizeInfo;

    [AppEngine appEngineSendMessage:message toUser:self.user];
}

////////////////////////////////////
// SEND STRING CONTENT
////////////////////////////////////

- (void)sendMessage:(NSMutableDictionary*)barMessage
{
    MessageObject *message = [self message];
    message.msgType = barMessage.typeString;
    message.msgContent = barMessage.text;
    
    [AppEngine appEngineSendMessage:message toUser:self.user];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AppEngine appEngineMessagesWithUserId:userId].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];

    id message = [AppEngine appEngineMessagesWithUserId:userId][indexPath.row];
    [cell setMessage:message
             myPhoto:self.myPhoto
           userPhoto:self.userPhoto
            userName:self.user.nickname
              myName:self.me.nickname];
    
    cell.delegate = self;
    return cell;
}

typedef void (^MessageCellBlock)(MessageCell *cell);

- (void)updateCellForMessageId:(id)messageId block:(MessageCellBlock)block
{
    NSArray *visible = [self.tableView visibleCells];
    [visible enumerateObjectsUsingBlock:^(MessageCell* cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell.message.objectId isEqualToString:messageId]) {
            if (block)
                block(cell);
            *stop = YES;
        }
    }];
}

- (void) redrawCell:(NSMutableDictionary*)message
{
    [self updateCellForMessageId:message.objectId block:^(MessageCell *cell) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cell setMessage:message
                     myPhoto:self.myPhoto
                   userPhoto:self.userPhoto
                    userName:self.user.nickname
                      myName:self.me.nickname];
        });
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"SELECTED ROW");
}

- (CGFloat) appropriateLineHeightForMessage:(NSMutableDictionary*)message
{
    CGFloat width = [[[UIApplication sharedApplication] keyWindow] bounds].size.width * 0.7f;
    
    if (message.type == kMessageTypeText) {
        const CGFloat inset = 10;
        NSString *string = [message.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        UIFont *font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        CGRect frame = rectForString(string, font, width);
        return frame.size.height+inset*2.5;
    }
    else if (message.type == kMessageTypePhoto) {
        CGSize size = CGSizeFromString(message.mediaInfo);
        return size.width ? width * size.height / size.width : 200;
    }
    else {
        return 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id message = [AppEngine appEngineMessagesWithUserId:userId][indexPath.row];
    return [self appropriateLineHeightForMessage:message];
}

- (IBAction)tappedOutside:(id)sender {
    [self.bar pullDownKeyBoard];
}

- (void)keyBoardEvent:(CGRect)kbFrame duration:(double)duration animationType:(UIViewAnimationOptions)animation
{
    float m = self.bar.frame.size.height;
    float h = kbFrame.origin.y-m;
    [UIView animateWithDuration:duration animations:^{
        [self.bar setFrame:CGRectMake(self.bar.frame.origin.x, h, self.bar.frame.size.width, m)];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, 0, self.tableView.frame.size.width, h)];
    } completion:^(BOOL finished) {
        [self.bar setFrame:CGRectMake(self.bar.frame.origin.x, h, self.bar.frame.size.width, m)];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, 0, self.tableView.frame.size.width, h)];
        [self scrollToBottomAnimated:NO];
//        [self scrollToBottomAnimated:YES];
    }];
}

- (void) scrollToBottomAnimated:(BOOL) animated
{
    NSUInteger count = [self.tableView numberOfRowsInSection:0];

    if (count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count ? count-1 : 0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)tappedPhoto:(NSMutableDictionary *)message image:(UIImage *)image view:(UIView *)view
{
    NSLog(@"TAPPED BY DELEGATE");
    [self performSegueWithIdentifier:@"Preview" sender:message];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Preview"]) {
        NSLog(@"MESSAGE:%@", sender[@"fromUser"]);
//        PhotoDetail *vc = segue.destinationViewController;
//        vc.message = sender;
    }
}


@end
