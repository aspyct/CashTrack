//
//  CashTableViewController.m
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 22/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import "HistoryTableViewController.h"

#import "EntryTableViewController.h"

@interface HistoryTableViewController ()

@end

@implementation HistoryTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self openNewEntryScreen];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToSleep:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

#pragma mark - Application lifecycle

- (void)goToSleep:(NSNotification *)notification
{
    [self openNewEntryScreen];
}

- (void)openNewEntryScreen
{
    // Directly open the "new entry" screen, and don't load the movement list
    EntryTableViewController *entry = [self.storyboard instantiateViewControllerWithIdentifier:@"entryViewController"];
    [self prepareEntryForNewMovement:entry];
    [self.navigationController pushViewController:entry animated:NO];
}

#pragma mark - Segue preparation

- (void)prepareEntryForNewMovement:(EntryTableViewController *)entryViewController
{
    entryViewController.movement = [[Movement alloc] init];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"add"]) {
        [self prepareEntryForNewMovement:segue.destinationViewController];
    }
    else if ([segue.identifier isEqualToString:@"edit"]) {
        
    }
}

- (IBAction)unwindAndSaveMovement:(UIStoryboardSegue *)segue
{
    NSAssert([segue.sourceViewController isKindOfClass:[EntryTableViewController class]],
             @"Only EntryTableViewController can use this segue");
    
    EntryTableViewController *entry = segue.sourceViewController;
    NSLog(@"Saving movement: %@", entry.movement);
    [self.movementStore saveMovement:entry.movement completion:^(BOOL success) {
        if (success) {
            NSLog(@"Movement saved");
        }
        else {
            NSLog(@"Could not save movement");
        }
    }];
}

@end
