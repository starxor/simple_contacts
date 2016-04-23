//
//  EditContactInfoController.m
//  TestTaskForLabelUp
//
//  Created by Stanislav Starjevschi on 23.04.16.
//  Copyright © 2016 starxor. All rights reserved.
//

#import "EditContactInfoController.h"

typedef NS_ENUM(NSUInteger, InputFieldsTag) {
    FirstNameInputFieldTag,
    LastNameInputFieldTag,
    PhoneInputFieldTag,
    EmailInputFieldTag,
};

@interface EditContactInfoController () <UITextFieldDelegate>

@property (strong, nonatomic) UIBarButtonItem *saveButton;

@end

@implementation EditContactInfoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tempContactInfo = [self.contactInfo copy];
    
    self.firstNameField.tag = FirstNameInputFieldTag;
    self.lastNameField.tag = LastNameInputFieldTag;
    self.phoneField.tag = PhoneInputFieldTag;
    self.emailField.tag = EmailInputFieldTag;
    
    self.title = @"Edit Contact Info";
    
    self.saveButton.enabled = NO;
    
    [self subscribeForNotifications];
    
    [self showContactinfo];
}

- (void)subscribeForNotifications
{
    __weak typeof(self) wself = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [wself keyboardWillAppear:note];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [wself keyboardWillDissapear:note];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [wself keyboardWillAppear:note];
                                                  }];
}

- (NSLayoutConstraint *)stackViewConstraintToTop
{
    
    if (!_stackViewTopConstraint) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(firstItem=%@)OR(secondItem!=nil)AND(constant==10)",self.stackView];
        
        NSArray *array = [self.stackView constraintsAffectingLayoutForAxis:UILayoutConstraintAxisVertical];
        
        array = [array filteredArrayUsingPredicate:pred];
        
        _stackViewTopConstraint = array.firstObject;
    }
    
    
    return _stackViewTopConstraint;
}

- (void)keyboardWillAppear:(NSNotification *)notification
{
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = CGRectZero;
    
    if ([self.phoneField isFirstResponder]) {
        
        frame = [self.view convertRect:self.phoneField.frame fromView:self.phoneField];
        
    }else if ([self.emailField isFirstResponder]){
        
        frame = [self.view convertRect:self.emailField.frame fromView:self.emailField];
    }else if ([self.lastNameField isFirstResponder]){
        frame = [self.view convertRect:self.lastNameField.frame fromView:self.lastNameField];
    }
    
    if (frame.origin.y > endFrame.origin.y-30) {
        [self stackViewConstraintToTop].constant -= (frame.origin.y + 30 - endFrame.origin.y);
    }
    
    
    
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)keyboardWillDissapear:(NSNotification *)notification
{
    [self stackViewConstraintToTop].constant = 10;
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)showContactinfo
{
    NSDictionary *nameDict = _tempContactInfo[@"name"];
    
    self.firstNameField.text = nameDict[@"first"];
    self.lastNameField.text = nameDict[@"last"];
    self.phoneField.text = self.tempContactInfo[@"phone"];
    self.emailField.text = self.tempContactInfo[@"email"];
}

- (UIBarButtonItem *)saveButton
{
    if (!_saveButton) {
        _saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    }
    
    return _saveButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setRightBarButtonItem:self.saveButton];
}

- (IBAction)save
{
    NSMutableArray *marr = [Utils contactsArray];
    
    NSUInteger index = [marr indexOfObject:self.contactInfo];
    
    [marr replaceObjectAtIndex:index withObject:self.tempContactInfo];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [Utils logEventEditContact:@{
                                 @"beforeEditing" : self.contactInfo,
                                 @"afterEditing" : self.tempContactInfo
                                 }];
    
    [Utils saveChangesToDisk];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSMutableDictionary *dict = [_tempContactInfo mutableCopy];
    NSMutableDictionary *nameDict = [dict[@"name"] mutableCopy];
    
    InputFieldsTag tag = textField.tag;
    
//    _firstNameField.text = nameDict[@"first"];
//    _lastNameField.text = nameDict[@"last"];
//    _phoneField.text = _tempContactInfo[@"phone"];
//    _emailField.text = _tempContactInfo[@"email"];
    
    
    switch (tag) {
        case FirstNameInputFieldTag:
            nameDict[@"first"] = textField.text;
            break;
        case LastNameInputFieldTag:
            nameDict[@"last"] = textField.text;;
            break;
        case PhoneInputFieldTag:
            dict[@"phone"] = textField.text;
            break;
        case EmailInputFieldTag:
            dict[@"email"] = textField.text;
            break;
            
        default:
            break;
    }
    
    dict[@"name"] = nameDict;
    
    self.tempContactInfo = dict;
    
    if (![self.tempContactInfo isEqualToDictionary:_contactInfo]) {
        self.saveButton.enabled = YES;
    }else{
        self.saveButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    InputFieldsTag tag = textField.tag;
    
    switch (tag) {
        case FirstNameInputFieldTag:
            [self.lastNameField becomeFirstResponder];
            break;
        case LastNameInputFieldTag:
            [self.phoneField becomeFirstResponder];
            break;
        case PhoneInputFieldTag:
            [self.emailField becomeFirstResponder];
            break;
        case EmailInputFieldTag:
            [self.emailField resignFirstResponder];
            break;
            
        default:
            break;
    }
    
    return YES;
}

@end
