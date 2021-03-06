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

@interface EntryTableViewController () <UIAlertViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *plusMinusSegment;

@property UIDatePicker *datePicker;

@property NSDateFormatter *dateFormatter;

@end

@implementation EntryTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.dateField.inputView = self.datePicker;
}

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
    self.movement.category = categoryTable.categoryName;
}

- (IBAction)unwindAndSetDate:(UIStoryboardSegue *)segue
{
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    [self updateMovement];
    
    if ([identifier isEqualToString:@"save"]) {
        // Can't save an invalid form
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
    
    if (self.movement.category != nil) {
        self.categoryLabel.text = self.movement.category;
    }
    
    if (self.movement.date != nil) {
        self.datePicker.date = self.movement.date;
        self.dateField.text = [self.dateFormatter stringFromDate:self.movement.date];
    }
    
    // Remove the "delete" button if the movement is not saved yet
    if (![self.movement existsInDatabase]) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)updateMovement
{
    self.movement.amount = ({
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:self.amountTextField.text
                                                                    locale:[NSLocale currentLocale]];
        
        if (isnan(amount.doubleValue)) {
            amount = nil;
        }
        
        amount;
    });
    
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

- (void)datePickerValueChanged:(id)sender
{
    if (sender == self.datePicker) {
        self.movement.date = self.datePicker.date;
        [self updateForm];
    }
}

@end
