//
//  MovementStore.h
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 22/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Movement.h"

@interface MovementStore : NSObject

- (void)saveMovement:(Movement *)movement completion:(void (^)(BOOL success))completion;

- (void)deleteMovement:(Movement *)movement completion:(void (^)(BOOL success))completion;

- (void)countMovements:(void (^)(NSUInteger count))completion;

- (NSArray *)listMovementsFrom:(NSUInteger)offset limit:(NSUInteger)max;

- (void)listMovementsFrom:(NSUInteger)offset limit:(NSUInteger)max completion:(void (^)(NSArray *))completion;

@end
