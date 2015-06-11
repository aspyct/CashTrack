//
//  CategoryStore.m
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 08/06/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import "CategoryStore.h"

@implementation CategoryStore

+ (void)initializeStore
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *categories = [defaults arrayForKey:CATEGORY_STORE_DEFAULTS_KEY];
    
    if (categories == nil) {
        categories = @[@"Food & Household",
                       @"Friends & Fun",
                       @"Health",
                       @"Sport",
                       @"Savings",
                       @"Transportation",
                       @"Donations",
                       @"Rent"];
        
        [defaults setObject:categories forKey:CATEGORY_STORE_DEFAULTS_KEY];
        [defaults synchronize];
    }
}

- (void)listCategories:(void (^)(NSArray *))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        completion([self listCategories]);
    });
}

- (void)addCategory:(NSString *)category completion:(void (^)(BOOL))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *current = [self listCategories];
        NSArray *updated = [current arrayByAddingObject:category];
        
        completion([self setCategories:updated]);
    });
}

- (void)deleteCategory:(NSString *)category completion:(void (^)(BOOL))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *current = [self listCategories];
        
        NSMutableArray *updated = [NSMutableArray arrayWithArray:current];
        [updated removeObject:category];
        
        completion([self setCategories:updated]);
    });
}

- (NSArray *)listCategories
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:CATEGORY_STORE_DEFAULTS_KEY];
}

- (BOOL)setCategories:(NSArray *)categories
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:categories forKey:CATEGORY_STORE_DEFAULTS_KEY];
    
    return [defaults synchronize];
}

@end
