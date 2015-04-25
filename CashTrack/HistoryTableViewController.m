//
//  CashTableViewController.m
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 22/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import "HistoryTableViewController.h"

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "CSVExporter.h"
#import "EntryTableViewController.h"

@interface HistoryTableViewController ()

@property NSArray *movements;
@property (nonatomic) NSNumberFormatter *formatter;

@end

@implementation HistoryTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // When the app starts, we open the "new entry" screen immediately
    [self openNewEntryScreen];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DDLogVerbose(@"Loading cash history");
    [self refreshData];
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
    // Next time the app wakes up, we're on the "new entry" screen
    [self openNewEntryScreen];
}

- (void)openNewEntryScreen
{
    // Directly open the "new entry" screen, and don't load the movement list
    EntryTableViewController *entry = [self.storyboard instantiateViewControllerWithIdentifier:@"entryViewController"];
    [self prepareEntryForNewMovement:entry];
    [self.navigationController pushViewController:entry animated:NO];
}

#pragma mark - TableView stuff

- (void)refreshData
{
    [self.movementStore listMovementsFrom:0 limit:9999999 completion:^(NSArray *movements) {
        self.movements = movements;
        [self.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.movements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    Movement *movement = self.movements[indexPath.row];
    
    cell.textLabel.text = movement.category;
    cell.detailTextLabel.text = [self.formatter stringFromNumber:movement.amount];;
    
    return cell;
}

#pragma mark - Segue preparation

- (void)prepareEntryForNewMovement:(EntryTableViewController *)entryViewController
{
    entryViewController.movement = [[Movement alloc] init];
}

- (void)prepareEntryForEdit:(EntryTableViewController *)entryViewController
{
    Movement *movement = [self selectedMovement];
    entryViewController.movement = movement;
}

- (Movement *)selectedMovement
{
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    return self.movements[indexPath.row];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"add"]) {
        [self prepareEntryForNewMovement:segue.destinationViewController];
    }
    else if ([segue.identifier isEqualToString:@"edit"]) {
        [self prepareEntryForEdit:segue.destinationViewController];
    }
}

- (IBAction)unwindAndSaveMovement:(UIStoryboardSegue *)segue
{
    NSAssert([segue.sourceViewController isKindOfClass:[EntryTableViewController class]],
             @"Only EntryTableViewController can use this segue");
    
    EntryTableViewController *entry = segue.sourceViewController;
    DDLogVerbose(@"Saving movement: %@", entry.movement);
    [self.movementStore saveMovement:entry.movement completion:^(BOOL success) {
        if (success) {
            DDLogVerbose(@"Movement saved");
        }
        else {
            DDLogVerbose(@"Could not save movement");
        }
    }];
}

- (IBAction)unwindAndDeleteMovement:(UIStoryboardSegue *)segue
{
    NSAssert([segue.sourceViewController isKindOfClass:[EntryTableViewController class]],
             @"Only EntryTableViewController can use this segue");
    
    EntryTableViewController *entry = segue.sourceViewController;
    DDLogVerbose(@"Deleting movement: %@", entry.movement);
    
    [self.movementStore deleteMovement:entry.movement completion:^(BOOL success) {
        if (success) {
            DDLogVerbose(@"Movement deleted");
        }
        else {
            DDLogVerbose(@"Could not delete movement");
        }
    }];
}

- (IBAction)doOpenActivity:(id)sender
{
    CSVExporter *exporter = [[CSVExporter alloc] init];
    exporter.movementStore = self.movementStore;
    
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[exporter] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSNumberFormatter *)formatter
{
    if (_formatter == nil) {
        _formatter = [[NSNumberFormatter alloc] init];
        _formatter.maximumFractionDigits = 2;
        _formatter.minimumFractionDigits = 2;
    }
    
    return _formatter;
}

@end
