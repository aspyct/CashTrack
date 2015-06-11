//
//  CSVExporter.h
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 24/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MovementStore.h"

@interface CSVExporter : UIActivityItemProvider

@property MovementStore *movementStore;

- (instancetype)init;

@end
