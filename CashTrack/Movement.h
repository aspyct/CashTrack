//
//  Movement.h
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 22/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movement : NSObject

@property NSNumber *pk;
@property NSString *category;
@property NSDecimalNumber *amount;
@property NSDate *date;

@end
