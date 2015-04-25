//
//  EntryTableViewController.m
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 22/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import "EntryTableViewController.h"

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "CategoryTableViewController.h"

@interface EntryTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation EntryTableViewController

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.amountTextField becomeFirstResponder];
}

- (IBAction)unwindAndSetCategory:(UIStoryboardSegue *)segue
{
    NSAssert([segue.sourceViewController isKindOfClass:[CategoryTableViewController class]],
             @"Only the CategoryTableViewController can use this unwind");
    
    CategoryTableViewController *categoryTable = segue.sourceViewController;
    self.categoryLabel.text = categoryTable.categoryName;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"save"]) {
        [self updateMovement];
    }
}

- (void)updateMovement
{
    self.movement.amount = [NSDecimalNumber decimalNumberWithString:self.amountTextField.text
                                                             locale:[NSLocale currentLocale]];
    DDLogVerbose(@"Updating movement");
    self.movement.category = self.categoryLabel.text;
}

@end
