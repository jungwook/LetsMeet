//
//  ListPicker.m
//  LetsMeet
//
//  Created by 한정욱 on 2016. 5. 21..
//  Copyright © 2016년 SMARTLY CO. All rights reserved.
//

#import "ListPicker.h"
@interface ListPicker()
@property (nonatomic, strong) NSArray* array;
@property (nonatomic, weak) UITextField* textField;
@property (strong, nonatomic) void (^dataSelectedBlock)(id data);
@end

@implementation ListPicker

+(instancetype) pickerWithArray:(NSArray*)array onTextField:(UITextField*)textField selection:(void(^)(id data))actionBlock
{
    return [[ListPicker alloc] initPickerWithArray:array onTextField:(UITextField*)textField selection:actionBlock];
}

- (void) action
{
    NSLog(@"lalala");
}

- (instancetype) initPickerWithArray:(NSArray*)array onTextField:(UITextField*)textField selection:(void(^)(id data))actionBlock
{
    self = [super init];
    if (self) {
        self.array = array;
        self.delegate = self;
        self.dataSource = self;
        self.textField = textField;
        self.dataSelectedBlock = actionBlock;
        self.showsSelectionIndicator = YES;
        self.textField.inputView = self;
        
        [self selectRow:[array indexOfObject:textField.text] inComponent:0 animated:NO];
    }
    return self;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.array.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.array[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.textField resignFirstResponder];
    self.textField.text = self.array[row];
    if (self.dataSelectedBlock) {
        self.dataSelectedBlock(self.array[row]);
    }
}

@end
