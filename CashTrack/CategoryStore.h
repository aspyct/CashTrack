//
//  CategoryStore.h
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 08/06/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CATEGORY_STORE_DEFAULTS_KEY @"CATEGORY_STORE_DEFAULTS_KEY"

@interface CategoryStore : NSObject

+ (void)initializeStore;

- (void)listCategories:(void (^)(NSArray *categories))completion;

- (void)addCategory:(NSString *)category completion:(void (^)(BOOL success))completion;

- (void)deleteCategory:(NSString *)category completion:(void (^)(BOOL success))completion;

@end
