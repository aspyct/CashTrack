//
//  SeriesItem.m
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 08/06/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import "SeriesItem.h"

@implementation SeriesItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"<SeriesItem name:\"%@\" amount=%@>", self.name, self.amount];
}

@end
