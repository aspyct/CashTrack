//
//  PieChartTableViewCell.m
//  CashTrack
//
//  Created by Antoine d'Otreppe - Movify on 08/06/15.
//  Copyright (c) 2015 Aspyct. All rights reserved.
//

#import "PieChartTableViewCell.h"

#import "XYPieChart.h"
#import "SeriesItem.h"

@interface PieChartTableViewCell () <XYPieChartDataSource, XYPieChartDelegate>

@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;
@property NSArray *seriesNames;
@property NSArray *seriesValues;

@end

@implementation PieChartTableViewCell

- (void)setSeries:(NSArray *)series
{
    _series = series;
    
    self.pieChart.delegate = self;
    self.pieChart.dataSource = self;
    self.pieChart.showPercentage = NO;
    self.pieChart.showLabel = YES;
    self.pieChart.labelFont = [UIFont systemFontOfSize:11];
    
    [self.pieChart reloadData];
}

- (void)layoutSubviews
{
    self.pieChart.pieCenter = CGPointMake(self.pieChart.frame.size.width / 2,
                                          self.pieChart.frame.size.height / 2);
    self.pieChart.labelRadius = self.pieChart.frame.size.width * 0.35;
}

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    // At most 6 items
    return MIN(6, self.series.count);
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    NSDecimalNumber *amount;
    
    if (index < 5) {
        SeriesItem *item = self.series[index];
        amount = item.amount;
    }
    else {
        // Aggrerate the rest
        amount = [NSDecimalNumber zero];
        
        for (int i = 5; i < self.series.count; ++i) {
            SeriesItem *item = self.series[i];
            amount = [amount decimalNumberByAdding:item.amount];
        }
    }
    
    return [amount floatValue];
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index
{
    if (index < 5) {
        SeriesItem *item = self.series[index];
        return item.name;
    }
    else {
        // Aggregate the rest
        return @"Other";
    }
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    static NSArray *colors;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colors = @[[UIColor orangeColor],
                   [UIColor blueColor],
                   [UIColor redColor],
                   [UIColor brownColor],
                   [UIColor purpleColor],
                   [UIColor grayColor]];
    });
    
    return colors[index];
}

@end
