//
//  Movement.m
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 22/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import "Movement.h"

@implementation Movement

- (BOOL)existsInDatabase
{
    return self.pk != nil;
}

@end
