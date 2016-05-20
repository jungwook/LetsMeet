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


@interface Account()
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *intro;
@property (weak, nonatomic) IBOutlet IndentedLabel *sex;
@property (weak, nonatomic) IBOutlet IndentedLabel *age;
@property (weak, nonatomic) IBOutlet UILabel *points;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic, readonly) PFUser* me;

@end

@implementation Account

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _me = [PFUser currentUser];
    }
    return self;
}

- (void) additionalInits
{
    bool sex = [self.me[@"sex"] boolValue];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.nickname.text = self.me[@"nickname"];
    self.intro.text = self.me[@"intro"] ? self.me[@"intro"] : @"undefined";
    self.sex.text = sex == AppMaleUser ? AppMaleUserString : AppFemaleUserString;
    self.sex.backgroundColor = sex == AppMaleUser ? AppMaleUserColor : AppFemaleUserColor;
    self.age.text = [NSString stringWithFormat:@"%@세", self.me[@"age"]];
    [AppEngine drawImage:[UIImage imageNamed:@"add photo"] onView:self.photoView];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self additionalInits];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}


- (IBAction)editPhoto:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                                                                   message:@"This is an alert."
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Library" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {}];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)chargePoints:(id)sender {
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    return cell;
}

@end
