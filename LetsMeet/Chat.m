//
//  Chat.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 6. 13..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Chat.h"
#import "ChatRight.h"
#import "ChatLeft.h"
#import "MessageBar.h"
#import "NSMutableDictionary+Bullet.h"
#import "FileSystem.h"
#import "Notifications.h"
#import "S3File.h"

#define kInitialTextViewHeight 34
#define kMaxTextViewHeight 200
#define kNavigationBarHeight 64
#define photoViewHeight 40
#define balloonOffet 8

@interface Chat ()
{
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bar;

@property (weak, nonatomic) IBOutlet UITextView *messageView;
@property (nonatomic) CGFloat textViewHeight;
@property (nonatomic, strong) FileSystem* system;
@property (nonatomic, strong) Notifications* notifications;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *barTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *barBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *barHeight;
@end

@implementation Chat

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.system = [FileSystem new];
        self.textViewHeight = kInitialTextViewHeight;
    }
    return self;
}

- (void)setUser:(User *)user
{
    __LF
    _user = user;
    self.navigationItem.title = user.nickname;
    self.notifications = [Notifications notificationWithMessage:^(id bullet) {
        [self.system readUnreadBulletsWithUserId:self.user.objectId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self scrollToBottomAnimated:YES];
        });
    } broadcast:^(id senderId, NSString *message, NSTimeInterval duration) {
        
    } refresh:nil];
    [self.system readUnreadBulletsWithUserId:self.user.objectId];
    
    [[self.system messagesWith:self.user.objectId] enumerateObjectsUsingBlock:^(Bullet*  _Nonnull msg, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Message:%@", msg.objectId);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.notifications on];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollToBottomAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.notifications off];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObservers];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    __LF
    return [self.system messagesWith:self.user.objectId].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Bullet *bullet = [[self.system messagesWith:self.user.objectId] objectAtIndex:indexPath.row];
    
    if (bullet.isFromMe) {
        ChatRight *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatRight" forIndexPath:indexPath];
        [cell setMessage:bullet user:[User me] tableView:self.tableView];
        return cell;
    }
    else {
        ChatLeft *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatLeft" forIndexPath:indexPath];
        [cell setMessage:bullet user:self.user tableView:self.tableView];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Bullet *bullet = [[self.system messagesWith:self.user.objectId] objectAtIndex:indexPath.row];
    MediaTypes type = bullet.mediaType;
    
    switch (type) {
        case kMediaTypePhoto:
        case kMediaTypeVideo: {
            if (bullet.mediaSize.width) {
                CGFloat height = balloonOffet + 2 * balloonOffet + kThumbnailWidth * bullet.mediaSize.height / bullet.mediaSize.width;
                return height;
            }
            else {
                return kThumbnailWidth;
            }
        }
        case kMediaTypeText: {
            CGRect rect = rectForString(bullet.message, self.messageView.font, kThumbnailWidth);
            return MAX(rect.size.height + balloonOffet + balloonOffet*2, photoViewHeight+balloonOffet);
        }
        default:
            return photoViewHeight+balloonOffet;
    }
}

- (void) dealloc
{
    [self removeObservers];
}

- (void)clearTextView
{
    self.messageView.text = @"";
    self.textViewHeight = kInitialTextViewHeight;
    [self doKeyBoardEvent:nil];
}

- (IBAction)sendMessage:(id)sender {
    __LF
    NSString *string = [self.messageView.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    Bullet* bullet = [Bullet bulletWithText:string];
    [self.system add:bullet for:self.user.objectId];
    [self clearTextView];
}

- (IBAction)sendMedia:(id)sender {
    __LF
    if (![self.messageView.text isEqualToString:@""]) {
        [self sendMessage:nil];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"라이브러리" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"카메라" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectMediaFromSource:UIImagePickerControllerSourceTypeCamera];
    }];
    UIAlertAction *audio = [UIAlertAction actionWithTitle:@"오디오" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectAudioMedia];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        [alert addAction:library];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [alert addAction:camera];
    [alert addAction:audio];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void) selectMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.videoMaximumDuration = 10;
    picker.sourceType = sourceType;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    NSURL *url = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        [self handlePhoto:info url:url source:picker.sourceType];
    }
    else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)== kCFCompareEqualTo) {
        [self handleVideo:info url:url source:picker.sourceType];
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}
/*
 typedef NS_ENUM(NSInteger, UIImagePickerControllerSourceType) {
 UIImagePickerControllerSourceTypePhotoLibrary,
 UIImagePickerControllerSourceTypeCamera,
 UIImagePickerControllerSourceTypeSavedPhotosAlbum
 } __TVOS_PROHIBITED;

 */
- (void) handlePhoto:(NSDictionary<NSString*, id>*)info url:(NSURL*)url source:(UIImagePickerControllerSourceType)sourceType
{
    UIImage *image = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSData *thumbnailData = compressedImageData(imageData, kThumbnailWidth);
    
    NSString *thumbnailFile = [S3File saveImageData:thumbnailData completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        if (succeeded) {
            
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    } progress:nil];
    
    NSString *mediaFile = [S3File saveImageData:imageData completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        if (succeeded) {
            
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    } progress:nil];
    
    NSLog(@"source type:%ld", sourceType);

    Bullet* bullet = [Bullet bulletWithPhoto:mediaFile thumbnail:thumbnailFile mediaSize:image.size  realMedia:(sourceType == UIImagePickerControllerSourceTypeCamera)];
    [self.system add:bullet for:self.user.objectId];
    [self clearTextView];
}

- (void) handleVideo:(NSDictionary<NSString*, id>*)info url:(NSURL*)url source:(UIImagePickerControllerSourceType)sourceType
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    UIImage *thumbnailImage = [self thumbnailFromVideoAsset:asset source:sourceType];
    NSData *thumbnailData = compressedImageData(UIImageJPEGRepresentation(thumbnailImage, kJPEGCompressionFull), kThumbnailWidth);
    
    NSString *thumbnailFile = [S3File saveImageData:thumbnailData completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"UPLOADED THUMBNAIL TO:%@", file);
        }
        else {
            NSLog(@"ERROR:%@", error.localizedDescription);
        }
    } progress:nil];

    NSString *tempId = randomObjectId();
    NSURL *outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:tempId]];
    
    __block NSString *mediaFile = nil;

    [self convertVideoToLowQuailtyWithInputURL:url outputURL:outputURL handler:^(AVAssetExportSession *exportSession) {
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
            
            mediaFile = [S3File saveMovieData:videoData completedBlock:^(NSString *file, BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"source type:%ld", sourceType);

                    Bullet* bullet = [Bullet bulletWithVideo:mediaFile thumbnail:thumbnailFile mediaSize:thumbnailImage.size realMedia:(sourceType == UIImagePickerControllerSourceTypeCamera)];
                    NSLog(@"UPLOADED VIDEO TO:%@ %@", file, bullet);
                    [self.system add:bullet for:self.user.objectId];
                    [self clearTextView];
                }
                else {
                    NSLog(@"ERROR:%@", error.localizedDescription);
                }
                [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
            } progress:nil];
        }
     }];
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL handler:(void (^)(AVAssetExportSession*))handler {
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset1920x1080]; 
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        handler(exportSession);
    }];
}

- (UIImage*) thumbnailFromVideoAsset:(AVAsset*)asset source:(UIImagePickerControllerSourceType)sourceType
{
    __LF
    AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generateImg.appliesPreferredTrackTransform = YES;
    
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:[generateImg copyCGImageAtTime:CMTimeMake(1, 1) actualTime:NULL error:nil]];
    return thumbnail;
}

- (void) selectAudioMedia
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doKeyBoardEvent:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
}

- (void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

#define Height(__X__) __X__.bounds.size.height


- (void)doKeyBoardEvent:(NSNotification *)notification
{
    static CGRect keyboardEndFrameWindow;
    static CGRect keyboardBeginFrameWindow;
    static double keyboardTransitionDuration;
    static UIViewAnimationCurve keyboardTransitionAnimationCurve;

    if (notification) {
        [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBeginFrameWindow];
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
        [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
        [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    }

    self.messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize kbSize = keyboardBeginFrameWindow.size;
        BOOL isUp = (keyboardBeginFrameWindow.origin.y > keyboardEndFrameWindow.origin.y);
        UIEdgeInsets zeroInsets = UIEdgeInsetsMake(kNavigationBarHeight, 0, 0, 0);
        UIEdgeInsets contentInsets = isUp ? UIEdgeInsetsMake(kNavigationBarHeight, 0.0, kbSize.height, 0.0) : zeroInsets;
        self.barBottom.constant = isUp ? kbSize.height : 0;
        self.barHeight.constant = self.textViewHeight + self.messageTop.constant + self.messageBottom.constant;
        
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
        [self.bar setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:keyboardTransitionDuration delay:0.0f options:(keyboardTransitionAnimationCurve << 16) animations:^{
            [self.bar layoutIfNeeded];
            [self moveDownTextView:self.messageView];
        } completion:^(BOOL finished) {
            [self scrollToBottomAnimated:YES];
        }];
    });
}

- (void) moveDownTextView:(UITextView*)textView
{
    if (![textView.text isEqualToString:@""]) {
        [textView setContentOffset:CGPointMake(0.0, textView.contentSize.height - Height(textView)) animated:NO];
    }
}

- (void) scrollToBottomAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height-1, 1, 1) animated:animated];
}


- (IBAction)tappedOutside:(id)sender {
    __LF
    [self.messageView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGRect rect = CGRectIntegral([textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width, 0)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{
                                                                       NSFontAttributeName: textView.font,
                                                                       } context:nil]);

    self.textViewHeight = MIN(kMaxTextViewHeight, MAX(rect.size.height+balloonOffet*2.f, kInitialTextViewHeight));
    [self doKeyBoardEvent:nil];
}

@end
