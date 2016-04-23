//
//  ViewController.m
//  testTaskForLabelUp
//
//  Created by Stanislav Starjevschi on 23.04.16.
//  Copyright © 2016 starxor. All rights reserved.
//

#import "ContactsViewController.h"

#import "Utils.h"
#import "ContactCell.h"
#import "EditContactInfoController.h"
#import "MockAPIComunicator.h"

@interface ContactsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *contactsArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSDictionary *contactToDelete;

@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self contactsArray];
    
    self.title = @"Contacts";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - 

- (NSArray *)contactsArray
{
    return [Utils contactsArray];
}

#pragma mark - Table View Delegate/Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contactsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.numberLabel.text =
    cell.firstNameLabel.text = cell.lastNameLabel.text =
    cell.phoneNumberLabel.text = cell.emailLabel.text = nil;
    
    
//    {
//        "name": {
//            "first": "Mills",
//            "last": "Curtis"
//        },
//        "phone": "+1 (926) 562-3354",
//        "company": "FOSSIEL",
//        "email": "mills.curtis@fossiel.io"
//    }
    NSDictionary *contactInfo = self.contactsArray[indexPath.row];
    
    NSDictionary *nameDict = contactInfo[@"name"];
    
    cell.numberLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
    
    cell.firstNameLabel.text = nameDict[@"first"];
    cell.lastNameLabel.text = nameDict[@"last"];
    cell.phoneNumberLabel.text = contactInfo[@"phone"];
    cell.emailLabel.text = contactInfo[@"email"];
    
    return cell;
}

#pragma mark - Save

- (IBAction)save
{
    [self presentViewController:[self saveActionSheet] animated:YES completion:nil];
}

- (UIAlertController *)saveActionSheet
{
   UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Save"
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[self saveSUCCESS]];
    [alert addAction:[self saveFAIL]];
    [alert addAction:[self cancelAction]];
    
    return alert;
}

- (UIAlertAction *)saveSUCCESS
{
    return [UIAlertAction actionWithTitle:@"Сохранить (успех)"
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * _Nonnull action) {
                                      
                                      [Utils saveContactsSUCCESSWithCompletion:^(BOOL success, NSDictionary *response) {
                                          NSLog(@"saveSUCCESS – response : %@",response);
                                      }];
                                      
                                  }];
}

- (UIAlertAction *)saveFAIL
{
    return [UIAlertAction actionWithTitle:@"Сохранить (ошибка)"
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * _Nonnull action) {
                                      
                                      [Utils saveContactsFAILWithCompletion:^(BOOL success, NSDictionary *response) {
                                          NSLog(@"saveFAIL – response : %@",response);
                                      }];
                                      
                                  }];
}

#pragma mark - Delete Contact

- (IBAction)delete:(UIButton *)sender
{
    UITableViewCell *cell = nil;
    cell = (id)((UIButton *)sender).superview;
    while (![cell isKindOfClass:[UITableViewCell class]]) {
        cell = (id)cell.superview;
    }
    
    NSUInteger index = [self.tableView indexPathForCell:cell].row;
    
    _contactToDelete = self.contactsArray[index];
    
    [self presentViewController:[self deleteActionSheet]
                       animated:YES completion:nil];
}

- (UIAlertController *)deleteActionSheet
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Save"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[self deleteAction]];
    [alert addAction:[self cancelAction]];
    
    return alert;
}

- (UIAlertAction *)deleteAction
{
    return [UIAlertAction actionWithTitle:@"Удалить"
                                    style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction * _Nonnull action) {
                                      
                                      NSUInteger index = [self.contactsArray indexOfObject:_contactToDelete];
                                      
                                      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                                      
                                      [Utils removeContact:_contactToDelete];
                                      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                      
                                  }];
}

- (UIAlertAction *)cancelAction
{
    return [UIAlertAction actionWithTitle:@"Отмена"
                                    style:UIAlertActionStyleCancel
                                  handler:nil];
}

#pragma mark - Edit Contact

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditContactInfo"]) {
        
        UITableViewCell *cell = nil;
        cell = (id)((UIButton *)sender).superview;
        while (![cell isKindOfClass:[UITableViewCell class]]) {
            cell = (id)cell.superview;
        }
        
        NSUInteger index = [self.tableView indexPathForCell:cell].row;
        
        EditContactInfoController *editController = segue.destinationViewController;
        
        editController.contactInfo = self.contactsArray[index];
    }
}

@end
