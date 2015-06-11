//
//  CategoryTableViewController.m
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 22/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import "CategoryTableViewController.h"

#import "CategoryStore.h"

@interface CategoryTableViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet CategoryStore *categoryStore;

@property NSArray *categories;
@property UIBarButtonItem *addButtonItem;

@end

@implementation CategoryTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                       target:self
                                                                       action:@selector(doAddCategory:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reload];
}

- (void)reload
{
    [self.categoryStore listCategories:^(NSArray *categories) {
        self.categories = categories;
        [self.tableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categories count];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    UIBarButtonItem *leftButton;
    if (editing) {
        leftButton = self.addButtonItem;
    }
    else {
        leftButton = self.navigationItem.backBarButtonItem;
    }
    
    [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.text = self.categories[indexPath.row];
    
    return cell;
}

- (NSString *)categoryName
{
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    return self.categories[indexPath.row];
}

- (void)doAddCategory:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New category"
                                                    message:@"Please enter the name of the category"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString *categoryName = [alertView textFieldAtIndex:0].text;
        if (categoryName != nil && ![categoryName isEqualToString:@""]) {
            [self createCategory:categoryName];
        }
    }
}

- (void)createCategory:(NSString *)categoryName
{
    [self.categoryStore addCategory:categoryName completion:^(BOOL success) {
        if (success) {
            [self reload];
        }
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *categoryName = self.categories[indexPath.row];
        [self.categoryStore deleteCategory:categoryName completion:^(BOOL success) {
            if (success) {
                [self reload];
            }
        }];
    }
}

@end
