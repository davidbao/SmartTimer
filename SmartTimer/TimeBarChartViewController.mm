//
//  TimeBarChartViewController
//  SmartTimer
//
//  Created by baowei on 14-2-23.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "TimeBarChartViewController.h"

@interface TimeBarChartViewController ()

@end

@implementation TimeBarChartViewController

- (IBAction)DoneAction:(id)sender {
    [[TimeChartViewController selectedTasks] removeAllObjects];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initPlot];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    // First bar plot
    CPTBarPlot *validTimePlot     = [CPTBarPlot tubularBarPlotWithColor:self.validTimeColor horizontalBars:NO];
    validTimePlot.baseValue       = CPTDecimalFromString(@"0");
    validTimePlot.dataSource      = self;
    validTimePlot.barOffset       = CPTDecimalFromFloat(1.f);
    validTimePlot.identifier      = @"ValidTimeInterval";
    [graph addPlot:validTimePlot toPlotSpace:plotSpace];
    
    // Second bar plot
    CPTBarPlot *totalTimePlot     = [CPTBarPlot tubularBarPlotWithColor:self.totalTimeColor horizontalBars:NO];
    totalTimePlot.dataSource      = self;
    totalTimePlot.baseValue       = CPTDecimalFromString(@"0");
    totalTimePlot.barOffset       = CPTDecimalFromFloat(1.5f);
    totalTimePlot.barCornerRadius = 2.0f;
    totalTimePlot.identifier      = @"TotalTimeInterval";
    [graph addPlot:totalTimePlot toPlotSpace:plotSpace];
    
    // Animate in the new plot, as an example
    totalTimePlot.opacity = 0.0f;
    validTimePlot.opacity = 0.0f;
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 1.0f;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
    [totalTimePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    [validTimePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = nil;
    
    if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:index];
                break;
                
            case CPTBarPlotFieldBarTip:
                assert(index >= 0 && index < [TimeChartViewController selectedTasks].count);
                NSTask* task = [TimeChartViewController selectedTasks][index];
                
                if ( [plot.identifier isEqual:@"ValidTimeInterval"] ) {
                    num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:[task getValidTime]];
                }
                else if ( [plot.identifier isEqual:@"TotalTimeInterval"] ) {
                    num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:[task getTotalTime]];
                }
                break;
        }
    }
    
    return num;
}

@end
