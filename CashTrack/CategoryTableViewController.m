//
//  CategoryTableViewController.m
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 22/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import "CategoryTableViewController.h"

@interface CategoryTableViewController ()

@property NSArray *categories;

@end

@implementation CategoryTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.categories = @[@"Lunch",
                        @"Food",
                        @"Friends",
                        @"Company",
                        @"Recreation",
                        @"Miscellaneous",
                        @"Sport",
                        @"Health",
                        @"Home"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categories count];
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

@end
