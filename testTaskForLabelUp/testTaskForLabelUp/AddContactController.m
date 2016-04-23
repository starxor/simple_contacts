//
//  AddContactController.m
//  TestTaskForLabelUp
//
//  Created by Stanislav Starjevschi on 23.04.16.
//  Copyright © 2016 starxor. All rights reserved.
//

#import "AddContactController.h"

@implementation AddContactController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Add New Contact";
    
    self.tempContactInfo = [self emptyContactDictionary];
}

- (NSDictionary *)emptyContactDictionary
{
    return @{
             @"name" : @{
                     @"first":@"",
                     @"last":@""
                     },
             @"phone":@"",
             @"email":@""
             };
}

- (void)showContactinfo
{
    
}

- (void)save
{
    if ([self.tempContactInfo isEqualToDictionary:[self emptyContactDictionary]]) {
        
        [self presentViewController:[self alertWithMessage:@"Empty contact"]
                           animated:YES
                         completion:nil];
        
        return;
    }
    
    [Utils addContact:self.tempContactInfo];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [Utils saveChangesToDisk];
}

- (UIAlertController *)alertWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alert addAction:[self okeyAction]];
    
    return alert;
}

- (UIAlertAction *)okeyAction
{
   return [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
   }];
}

@end
