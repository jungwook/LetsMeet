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

@interface Chat ()
{
    CGRect keyboardEndFrameWindow;
    double keyboardTransitionDuration;
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bar;

@property (strong, nonatomic) UITextView *messageView;
@property (nonatomic) CGFloat textViewHeight;
@property (nonatomic, strong) FileSystem* system;
@property (nonatomic, strong) Notifications* notifications;
@end

@implementation Chat

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.system = [FileSystem new];
    }
    return self;
}

- (void)setUser:(User *)user
{
    __LF
    _user = user;
    self.notifications = [Notifications notificationWithMessage:^(id bullet) {
        [self.system readUnreadBulletsWithUserId:self.user.objectId];
        [self refreshContents];
    } broadcast:^(id senderId, NSString *message, NSTimeInterval duration) {
        
    } refresh:nil];
    [self.system readUnreadBulletsWithUserId:self.user.objectId];
}

- (void) scrollToBottomAnimated:(BOOL)animated
{
    const NSInteger section = 0;
    NSInteger count = [self tableView:self.tableView numberOfRowsInSection:section];
    if (count>0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)refreshContents
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self scrollToBottomAnimated:YES];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.notifications on];
    [self refreshContents];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.notifications off];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (!self.messageView) {
        float m = self.bar.frame.size.height+30;
        float h = keyboardEndFrameWindow.origin.y-m;
        [self.bar setFrame:CGRectMake(self.bar.frame.origin.x, h, self.bar.frame.size.width, m)];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, 0, self.tableView.frame.size.width, h)];
        [self addTextView];
    }
    [self addObservers];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:NO];
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
    BulletTypes type = bullet.bulletType;
    
    switch (type) {
        case kBulletTypePhoto:
        case kBulletTypeVideo: {
            return 240+16;
        }
            break;
        case kBulletTypeText: {
            UIFont *font = [UIFont boldSystemFontOfSize:17];
            CGRect rect = rectForString(bullet.message, font, 280);
            return rect.size.height + 40;
        }
            break;
        default:
            break;
    }
    return 40;
}

#define LEFTBUTSIZE 45
#define TOPINSET 8

- (void) addTextView
{
    CGSize size = self.bar.frame.size;
    self.messageView = [[UITextView alloc] initWithFrame:CGRectMake(LEFTBUTSIZE+TOPINSET, TOPINSET, size.width-2*(LEFTBUTSIZE+TOPINSET), size.height-2*TOPINSET)];
    self.messageView.delegate = self;
    self.messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.messageView.font = [UIFont systemFontOfSize:16];
    self.messageView.backgroundColor = [UIColor whiteColor];
    self.textViewHeight = 30;
    self.messageView.keyboardType = UIKeyboardTypeDefault;
    self.messageView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.messageView.returnKeyType = UIReturnKeyNext;
    self.messageView.enablesReturnKeyAutomatically = YES;
    self.messageView.layer.cornerRadius = 2.0;
    self.messageView.layer.borderWidth = 0.5;
    self.messageView.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    
    [self.bar addSubview:self.messageView];
}

- (void) dealloc
{
    [self removeObservers];
}

- (void)doEndEditingEvent:(NSString *)string
{
    __LF
}

- (void)clearTextView
{
    self.messageView.text = @"";
    self.textViewHeight = 30;
}

- (IBAction)sendMessage:(id)sender {
    __LF

    Bullet* bullet = [Bullet bulletWithText:self.messageView.text];
    [self.system add:bullet for:self.user.objectId];
    [self clearTextView];
    [self keyBoardEventWithRefresh:YES];
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
        [self handlePhoto:info url:url];
    }
    else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)== kCFCompareEqualTo) {
        [self handleVideo:info url:url];
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) handlePhoto:(NSDictionary<NSString*, id>*)info url:(NSURL*)url
{
    UIImage *image = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSData *thumbnailData = compressedImageData(imageData, 240);
    
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

    Bullet* bullet = [Bullet bulletWithPhoto:mediaFile thumbnail:thumbnailFile];
    [self.system add:bullet for:self.user.objectId];
    [self clearTextView];
    [self keyBoardEventWithRefresh:YES];
}

NSString* randomObjectId();

- (void) handleVideo:(NSDictionary<NSString*, id>*)info url:(NSURL*)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSData *thumbnailData = compressedImageData(UIImageJPEGRepresentation([self thumbnailFromVideoAsset:asset], kJPEGCompressionFull), 240);
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
                    NSLog(@"UPLOADED VIDEO TO:%@", file);
                }
                else {
                    NSLog(@"ERROR:%@", error.localizedDescription);
                }
                [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
            } progress:nil];
        }
        Bullet* bullet = [Bullet bulletWithVideo:mediaFile thumbnail:thumbnailFile];
        [self.system add:bullet for:self.user.objectId];
        [self clearTextView];
        [self keyBoardEventWithRefresh:YES];
     }];
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL handler:(void (^)(AVAssetExportSession*))handler {
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPreset640x480];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        handler(exportSession);
    }];
}


- (UIImage*) thumbnailFromVideoAsset:(AVAsset*)asset
{
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doKeyBoardEvent:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doEndEditingEvent:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];
}

- (void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:nil];
}

- (void)doKeyBoardEvent:(NSNotification *)notification
{
    __LF
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    
    [self keyBoardEventWithRefresh:YES];
}


- (IBAction)tappedOutside:(id)sender {
    __LF
    [self.messageView resignFirstResponder];
}

- (void)keyBoardEventWithRefresh:(BOOL)refresh
{
    __LF
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:keyboardTransitionAnimationCurve];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:keyboardTransitionDuration];
        
        float m = self.bar.frame.size.height;
        m = self.textViewHeight + 18;
        float h = keyboardEndFrameWindow.origin.y-m;
        [self.bar setFrame:CGRectMake(self.bar.frame.origin.x, h, self.bar.frame.size.width, m)];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, 0, self.tableView.frame.size.width, h)];
        [UIView commitAnimations];
        CGPoint offsetPoint = CGPointMake(0.0, self.messageView.contentSize.height - self.messageView.bounds.size.height);
        [self.messageView setContentOffset:offsetPoint animated:YES];
        
        if (refresh) {
            [self refreshContents];
        }
    });
}

- (void)textViewDidChange:(UITextView *)textView
{
    __LF
    CGRect rect = rectForString([textView.text stringByAppendingString:@"x"], textView.font, textView.frame.size.width);
    self.textViewHeight = MIN(200, MAX(rect.size.height+12,30));
    [self keyBoardEventWithRefresh:NO];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self keyBoardEventWithRefresh:YES];
    }
    return YES;
}


@end
