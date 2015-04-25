//
//  MovementStore.m
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 22/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import "MovementStore.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
#import <FMDB/FMDB.h>

@interface MovementStore ()

@property FMDatabaseQueue *queue;

@end

@implementation MovementStore

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.queue = [[FMDatabaseQueue alloc] initWithPath:[self pathToDatabase]];
        [self createTableIfNeeded];
    }
    
    return self;
}

#pragma mark - Public interface

- (void)saveMovement:(Movement *)movement completion:(void (^)(BOOL))completion
{
    [self inBackground:^{
        if (movement.pk == nil) {
            [self insertMovement:movement completion:completion];
        }
        else {
            [self updateMovement:movement completion:completion];
        }
    }];
}

- (void)listMovementsFrom:(NSUInteger)offset limit:(NSUInteger)max completion:(void (^)(NSArray *))completion
{
    [self inBackground:^{
        [self.queue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:@"SELECT pk, category, amount, date FROM movements LIMIT ? OFFSET ?",
                               @(max), @(offset)];
            
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:max];
            while ([rs next]) {
                Movement *movement = [[Movement alloc] init];
                movement.pk = @([rs longLongIntForColumnIndex:0]);
                movement.category = [rs stringForColumnIndex:1];
                movement.amount = [NSDecimalNumber decimalNumberWithString:[rs stringForColumnIndex:2]
                                                                    locale:[NSLocale currentLocale]];
                movement.date = [rs dateForColumnIndex:3];
                
                [array addObject:movement];
            }
            
            [self onMainThread:^{
                completion(array);
            }];
        }];
    }];
}

- (void)countMovements:(void (^)(NSUInteger))completion
{
    [self inBackground:^{
        [self.queue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:@"SELECT COUNT(*) FROM movements"];
            
            if ([rs next]) {
                int count = [rs intForColumnIndex:0];
                
                [self onMainThread:^{
                    completion(count);
                }];
            }
        }];
    }];
}

#pragma mark - Saving and updating

- (void)insertMovement:(Movement *)movement completion:(void (^)(BOOL))completion
{
    // Does not exist in database yet, let's insert it
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL success;
        
        success = [db executeUpdate:@"INSERT INTO movements (category, amount, date) VALUES (?, ?, ?)",
                   movement.category, movement.amount, movement.date];
        
        if (success) {
            int rows = [db changes];
            
            if (rows == 1) {
                movement.pk = @([db lastInsertRowId]);
                
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
        else /* if (!success) */ {
            DDLogError(@"Could not execute query: %@", [db lastErrorMessage]);
            [self onMainThread:^{
                completion(NO);
            }];
        }
    }];
}

- (void)updateMovement:(Movement *)movement completion:(void (^)(BOOL))completion
{
    // Exists in the database. Update it
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL success;
        
        success = [db executeUpdate:@"UPDATE movements SET category = ?, amount = ?, date = ? WHERE pk = ?",
                   movement.category, movement.amount, movement.date, movement.pk];
        
        if (success) {
            int rows = [db changes];
            
            if (rows == 1) {
                [self onMainThread:^{
                    completion(YES);
                }];
            }
            else {
                if (rows > 1) {
                    DDLogError(@"Too many rows affected: %i", rows);
                }
                
                [self onMainThread:^{
                    completion(NO);
                }];
            }
        }
        else /* if (!success) */ {
            DDLogError(@"Could not execute query: %@", [db lastErrorMessage]);
            [self onMainThread:^{
                completion(NO);
            }];
        }
    }];
}

#pragma mark - Threading

- (void)inBackground:(void (^)())block
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), block);
}

- (void)onMainThread:(void (^)())block
{
    dispatch_async(dispatch_get_main_queue(), block);
}

#pragma mark - Database and init

- (NSString *)pathToDatabase
{
    return [@"~/Documents/movements.sqlite3" stringByExpandingTildeInPath];
}

- (void)createTableIfNeeded
{
    [self inBackground:^{
        [self.queue inDatabase:^(FMDatabase *db) {
            [db executeStatements:@""
             "CREATE TABLE movements ("
             "pk INTEGER PRIMARY KEY AUTOINCREMENT,"
             "category TEXT,"
             "amount DECIMAL(10,2),"
             "date DATE"
             ")"];
        }];
    }];
}

@end
