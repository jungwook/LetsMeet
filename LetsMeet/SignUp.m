//
//  SignUp.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 14..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "SignUp.h"
#import "AppEngine.h"

@interface SignUp ()
@property (weak, nonatomic) IBOutlet UITextField *nickname;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *why;

@property (strong, nonatomic) UIPickerView *agePicker;
@property (strong, nonatomic) UIPickerView *whyPicker;
@property (weak, nonatomic) IBOutlet UIButton *butMan;
@property (weak, nonatomic) IBOutlet UIButton *butWoman;
@property (weak, nonatomic) IBOutlet UILabel *labelSex;
@property (weak, nonatomic) IBOutlet UIButton *butStart;
@end

@implementation SignUp

- (UIView *)applyBlurToView:(UIView *)view withEffectStyle:(UIBlurEffectStyle)style andConstraints:(BOOL)addConstraints
{
    //only apply the blur if the user hasn't disabled transparency effects
    if(!UIAccessibilityIsReduceTransparencyEnabled())
    {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:style];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = view.bounds;
        
        [view addSubview:blurEffectView];
        
        if(addConstraints)
        {
            //add auto layout constraints so that the blur fills the screen upon rotating device
            [blurEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:view
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:0]];
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1
                                                              constant:0]];
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1
                                                              constant:0]];
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:view
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1
                                                              constant:0]];
        }
    }
    else
    {
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    }
    
    return view;
}

- (UIImage*) blur:(UIImage*)theImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:24.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);

    return returnImage;
}


- (void)setupPickerViews
{
    self.agePicker = [[UIPickerView alloc] init];
}

- (void)setupTextFields:(UITextField*) textField with:(NSString*) value
{
    textField.layer.cornerRadius = textField.frame.size.height/2.0f;
    textField.layer.cornerRadius = 2.0f;
    textField.layer.masksToBounds = YES;
//    textField.layer.borderColor = [UIColor blackColor].CGColor;
//    textField.layer.borderWidth = 1.0f;
    
    textField.delegate = self;
    textField.text = value;
    textField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPickerViews];
    
    self.view.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.view.layer.contents = (id) [UIImage imageNamed:@"bg"].CGImage;
    self.view.layer.masksToBounds = YES;
    
    [self setupTextFields:self.nickname with:[[PFUser currentUser] valueForKey:@"nickname"]];
    [self setupTextFields:self.age with:[[PFUser currentUser] valueForKey:@"age"]];
    [self setupTextFields:self.why with:[[PFUser currentUser] valueForKey:@"why"]];
}

- (IBAction)start:(id)sender {
    if (![self.nickname.text isEqualToString:@""] && ![self.age.text isEqualToString:@""]) {
        PFUser *user = [PFUser currentUser];
        
        [user setObject:self.nickname.text forKey:@"nickname"];
        [user setObject:self.age.text forKey:@"age"];
        [user setObject:self.why.text forKey:@"why"];
        
        [user saveInBackground];
        [self dismissViewControllerAnimated:YES completion:^{
           
        }];
    }
}

- (IBAction)selectSex:(id)sender {
    UIButton *but = sender;
    UIButton *other;
    
    other = but.tag ? self.butMan : self.butWoman;
    but.selected = YES;
    other.selected = NO;

    self.labelSex.text = !but.tag ? @"남자" : @"여자";
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

@end
