//
//  CSVExporter.m
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 24/04/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import "CSVExporter.h"

@implementation CSVExporter

- (instancetype)init
{
    self = [super initWithPlaceholderItem:[NSURL fileURLWithPath:[self pathToExport]]];
    
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:[self pathToExport]]) {
            [fileManager createFileAtPath:[self pathToExport] contents:nil attributes:nil];
        }
    }
    
    return self;
}

- (id)item
{
    NSArray *movements = [self.movementStore listMovementsFrom:0 limit:999999];
    
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:[self pathToExport]];
    
    for (Movement *movement in movements) {
        NSString *csv = [NSString stringWithFormat:@"%@,%@,%@,%@\n",
                         movement.pk,
                         movement.category,
                         movement.amount,
                         movement.date];
        
        [fh writeData:[csv dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [fh closeFile];
    
    return [NSURL fileURLWithPath:[self pathToExport]];
}

- (NSString *)pathToExport
{
    return [@"~/Library/Caches/export.csv" stringByExpandingTildeInPath];
}

@end
