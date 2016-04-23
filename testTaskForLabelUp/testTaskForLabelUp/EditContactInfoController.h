//
//  EditContactInfoController.h
//  TestTaskForLabelUp
//
//  Created by Stanislav Starjevschi on 23.04.16.
//  Copyright © 2016 starxor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Utils.h"

@interface EditContactInfoController : UIViewController

@property (strong, nonatomic) NSDictionary *contactInfo;
@property (strong, nonatomic) NSDictionary *tempContactInfo;

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (strong, nonatomic) NSLayoutConstraint *stackViewTopConstraint;

- (void)showContactinfo;
- (IBAction)save;

@end
