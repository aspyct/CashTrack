//
//  CashTableViewController.h
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 22/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MovementStore.h"

@interface HistoryTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet MovementStore *movementStore;

@end
