//
//  MovementStore.m
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 22/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import "MovementStore.h"

@implementation MovementStore

- (void)saveMovement:(Movement *)movement completion:(void (^)(BOOL))completion
{
    [self inBackground:^{
        NSInteger rows = 0;
        
        if (movement.pk == nil) {
            // Does not exist in database yet, let's insert it
            rows = [self runSQL:@"INSERT INTO movements (category, amount, date) VALUES (?, ?, ?)"
                      arguments:@[movement.category,
                                  movement.amount,
                                  movement.date]];
            
            if (rows == 1) {
                movement.pk = [self lastInsertID];
                
                [self onMainThread:^{
                    completion(YES);
                }];
            }
            else {
                [self onMainThread:^{
                    completion(NO);
                }];
            }
        }
        else {
            // Exists in the database. Update it
            rows = [self runSQL:@"UPDATE movements SET category = ?, amount = ?, date = ? WHERE pk = ?"
                      arguments:@[movement.category,
                                  movement.amount,
                                  movement.date,
                                  movement.pk]];
            
            if (rows == 1) {
                [self onMainThread:^{
                    completion(YES);
                }];
            }
            else {
                if (rows > 1) {
                    NSLog(@"Too many rows affected: %li", rows);
                }
                
                [self onMainThread:^{
                    completion(NO);
                }];
            }
        }
    }];
}

- (void)listMovementsFrom:(NSUInteger)from to:(NSUInteger)to completion:(void (^)(NSArray *))completion
{
    
}

- (void)countMovements:(void (^)(NSUInteger))completion
{
    
}

#pragma mark - Boilerplate

- (NSInteger)runSQL:(NSString *)sql arguments:(NSArray *)arguments
{
    return 0;
}

- (NSNumber *)lastInsertID
{
    return nil;
}

- (void)inBackground:(void (^)())block
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), block);
}

- (void)onMainThread:(void (^)())block
{
    dispatch_async(dispatch_get_main_queue(), block);
}

@end
