//
//  Account.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 20..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "Account.h"
#import "AppEngine.h"
#import "IndentedLabel.h"
#import "ImagePicker.h"
#import "CachedFile.h"
#import "ListPicker.h"
#import "UserCell.h"
#import "Chat.h"

@interface Account()
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UITextField *intro;
@property (weak, nonatomic) IBOutlet UITextField *sex;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong, readonly) PFUser* me;
@property (nonatomic, weak, readonly) NSArray *users;
@property (nonatomic, weak, readonly) AppEngine *engine;
@property (nonatomic, strong) UIRefreshControl *refresh;

@end

@implementation Account

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _me = [PFUser currentUser];
        _engine = [AppEngine engine];
//        _users = self.engine.users;
    }
    return self;
}

- (void) additionalInits
{
    bool sex = [self.me[AppKeySexKey] boolValue];
    
    self.nickname.text = self.me[AppKeyNicknameKey];
    self.intro.text = self.me[AppKeyIntroKey] ? self.me[AppKeyIntroKey] : @"undefined";
    self.intro.inputView = [ListPicker pickerWithArray:AppProfileIntroductions withPhotoSelectedBlock:^(id data) {
        self.intro.text = data;
        [self.intro resignFirstResponder];
        self.me[AppKeyIntroKey] = data;
        [self.me saveInBackground];
    }];

    self.sex.inputView = [ListPicker pickerWithArray:AppProfileSexSelections withPhotoSelectedBlock:^(id data) {
        bool sex = [data isEqualToString:AppMaleUserString];
        self.sex.text = data;
        [self.sex resignFirstResponder];
        self.me[AppKeySexKey] = sex ? @(AppMaleUser) : @(AppFemaleUser);
        self.sex.backgroundColor = sex ? AppMaleUserColor : AppFemaleUserColor;
        [self.me saveInBackground];
    }];

    self.sex.text = sex == AppMaleUser ? AppMaleUserString : AppFemaleUserString;
    self.sex.backgroundColor = sex == AppMaleUser ? AppMaleUserColor : AppFemaleUserColor;
    
    self.age.inputView = [ListPicker pickerWithArray:AppProfileAgeSelections withPhotoSelectedBlock:^(id data) {
        self.age.text = data;
        [self.age resignFirstResponder];
        self.me[AppKeyAgeKey] = data;
        [self.me saveInBackground];
    }];
    
    self.age.text = [NSString stringWithFormat:@"%@", self.me[AppKeyAgeKey]];
    
    [CachedFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error, BOOL fromCache) {
        UIImage *profilePhoto = [UIImage imageWithData:data];
        drawImage(profilePhoto, self.photoView);
    } fromFile:self.me[AppProfilePhotoField]];
    
    circleizeView(self.age, 0.2f);
    circleizeView(self.sex, 0.2f);
    circleizeView(self.photoView, 0.5f);
    
    self.refresh = [UIRefreshControl new];
    [self.refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
    [self.tableView sendSubviewToBack:self.refresh];
}

- (void)refresh:(id)sender
{
//    [[AppEngine engine] reloadChatUsers];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self additionalInits];
    [self.tableView reloadData];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messagesLoaded:)
                                                 name:AppUserNewMessageReceivedNotification
                                               object:nil];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AppUserNewMessageReceivedNotification
                                                  object:nil];
}

- (void)messagesLoaded:(id)sender
{
    if ([self.refresh isRefreshing])
        [self.refresh endRefreshing];
    [self.tableView reloadData];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)editPhoto:(id)sender {
    [ImagePicker proceedWithParentViewController:self withPhotoSelectedBlock:^(id data, ImagePickerMediaType type) {
        UIImage *photo = [UIImage imageWithData:data];
        UIImage *small = scaleImage(photo, AppProfilePhotoSize);
        NSData *smallData = UIImageJPEGRepresentation(small, AppProfilePhotoCompression);
        NSData *largeData = UIImageJPEGRepresentation(photo, AppProfilePhotoCompression);
        
        drawImage(small, self.photoView);
        
        [CachedFile saveData:smallData named:AppProfilePhotoFileName inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
            self.me[AppProfilePhotoField] = file;
            [self.me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!succeeded) {
                    NSLog(@"ERROR UPDATING USER WITH PHOTO:%@", error.localizedDescription);
                }
            }];
            
        } progressBlock:^(int percentDone) {
            NSLog(@"SAVING IN PROGRESS:%d", percentDone);
        }];
        
        [CachedFile saveData:largeData named:AppProfileOriginalPhotoFileName inBackgroundWithBlock:^(PFFile *file, BOOL succeeded, NSError *error) {
            self.me[AppProfileOriginalPhotoField] = file;
            [self.me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!succeeded) {
                    NSLog(@"ERROR UPDATING USER WITH PHOTO:%@", error.localizedDescription);
                }
            }];
            
        } progressBlock:^(int percentDone) {
            NSLog(@"SAVING IN PROGRESS:%d", percentDone);
        }];
    } featuring:kImagePickerSourceCamera | kImagePickerSourceLibrary];
}

- (IBAction)chargePoints:(id)sender {
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InboxCell";
//    PFUser *user = self.users[indexPath.row];
    UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    [cell setUser:user andMessages:[self.engine messagesWithUser:user]];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    
    if ([[segue identifier] isEqualToString:@"GotoChat"])
    {
//        NSUInteger row = [self.tableView indexPathForSelectedRow].row;
//        PFUser *selectedUser = self.users[row];
//        Chat *vc = [segue destinationViewController];
//        [vc setChatUser:selectedUser];
    }
}

@end
