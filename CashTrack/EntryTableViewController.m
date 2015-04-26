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

@interface EntryTableViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *plusMinusSegment;

@end

@implementation EntryTableViewController

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateForm];
    [self.amountTextField becomeFirstResponder];
}

#pragma mark - Navigation

- (IBAction)unwindAndSetCategory:(UIStoryboardSegue *)segue
{
    NSAssert([segue.sourceViewController isKindOfClass:[CategoryTableViewController class]],
             @"Only the CategoryTableViewController can use this unwind");
    
    CategoryTableViewController *categoryTable = segue.sourceViewController;
    self.categoryLabel.text = categoryTable.categoryName;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    [self updateMovement];
    if ([identifier isEqualToString:@"save"]) {
        if ([self.movement validate]) {
            return YES;
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid amount"
                                                            message:@"The entered amount is invalid"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            return NO;
        }
    }
    else {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self updateMovement];
}

- (void)updateForm
{
    if (self.movement.amount != nil) {
        self.amountTextField.text = ({
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.maximumFractionDigits = 2;
            formatter.minusSign = @"";
            formatter.plusSign = @"";
            
            [formatter stringFromNumber:self.movement.amount];
        });
        
        self.plusMinusSegment.selectedSegmentIndex = ({
            self.movement.amount.decimalValue._isNegative ? 1 : 0;
        });
    }
    
    // Remove the "delete" button if the movement is not saved yet
    if (![self.movement existsInDatabase]) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)updateMovement
{
    DDLogVerbose(@"Updating movement");
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:self.amountTextField.text
                                                                locale:[NSLocale currentLocale]];
    
    if (isnan(amount.doubleValue)) {
        amount = nil;
    }
    
    self.movement.amount = amount;
    BOOL positive = self.plusMinusSegment.selectedSegmentIndex == 0;
    [self.movement setSign:positive];
    
    self.movement.category = self.categoryLabel.text;
    
    if (self.movement.date == nil) {
        // Do not modify the date of an existing movement
        self.movement.date = [NSDate date];
    }
}

- (IBAction)doDelete:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                    message:@"Do you want to delete this entry?"
                                                   delegate:self
                                          cancelButtonTitle:@"No, keep"
                                          otherButtonTitles:@"Yes, delete", nil];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self performSegueWithIdentifier:@"delete" sender:self];
    }
}

@end
