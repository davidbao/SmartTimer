//
//  TimeLineChartViewController.mm
//  SmartTimer
//
//  Created by baowei on 14-3-6.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "TimeLineChartViewController.h"

@interface TimeLineChartViewController ()

@end

@implementation TimeLineChartViewController

- (IBAction)DoneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Initialization and teardown

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initPlot];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *y = axisSet.yAxis;
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75f;
    majorGridLineStyle.lineColor = [CPTColor darkGrayColor];
    y.majorGridLineStyle = majorGridLineStyle;
    
//    // Create a blue plot area
//    CPTScatterPlot *baselinePlot  = [[CPTScatterPlot alloc] init];
//    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
//    lineStyle.miterLimit        = 1.0f;
//    lineStyle.lineWidth         = 0.75f;
//    lineStyle.lineColor         = self.validTimeColor;
//    baselinePlot.dataLineStyle = lineStyle;
//    baselinePlot.identifier    = @"Baseline";
//    baselinePlot.dataSource    = self;
//    [graph addPlot:baselinePlot];
    
    // Create a blue plot area
    CPTScatterPlot *validTimePlot  = [[CPTScatterPlot alloc] init];
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit        = 1.0f;
    lineStyle.lineWidth         = 3.0f;
    lineStyle.lineColor         = self.validTimeColor;
    validTimePlot.dataLineStyle = lineStyle;
    validTimePlot.identifier    = @"ValidTimeInterval";
    validTimePlot.dataSource    = self;
    [graph addPlot:validTimePlot];
    
//    // Do a blue gradient
//    CPTColor *areaColor1       = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
//    CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:areaColor1 endingColor:[CPTColor clearColor]];
//    areaGradient1.angle = -90.0f;
//    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient1];
//    validTimePlot.areaFill      = areaGradientFill;
//    validTimePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
    
    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:validTimePlot.dataLineStyle.lineColor];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(10.0, 10.0);
    validTimePlot.plotSymbol = plotSymbol;
    
    // Create a green plot area
    CPTScatterPlot *totalTimePlot   = [[CPTScatterPlot alloc] init];
    lineStyle                       = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit            = 1.0f;
    lineStyle.lineWidth             = 3.f;
    lineStyle.lineColor             = self.totalTimeColor;
//    lineStyle.dashPattern           = [NSArray arrayWithObjects:[NSNumber numberWithFloat:5.0f], [NSNumber numberWithFloat:5.0f], nil];
    totalTimePlot.dataLineStyle     = lineStyle;
    totalTimePlot.identifier        = @"TotalTimeInterval";
    totalTimePlot.dataSource        = self;
    [graph addPlot:totalTimePlot];
    
    // Put an area gradient under the plot above
//    CPTColor *areaColor       = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
//    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
//    areaGradient.angle               = -90.0f;
//    areaGradientFill                 = [CPTFill fillWithGradient:areaGradient];
//    totalTimePlot.areaFill      = areaGradientFill;
//    totalTimePlot.areaBaseValue = CPTDecimalFromString(@"1.75");
    
    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle2 = [CPTMutableLineStyle lineStyle];
    symbolLineStyle2.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol2 = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol2.fill          = [CPTFill fillWithColor:totalTimePlot.dataLineStyle.lineColor];
    plotSymbol2.lineStyle     = symbolLineStyle2;
    plotSymbol2.size          = CGSizeMake(10.0, 10.0);
    totalTimePlot.plotSymbol = plotSymbol2;
    
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
    NSNumber *num = nil;
    
    // Green plot gets shifted above the blue
    if ( fieldEnum == CPTScatterPlotFieldY ) {
        assert(index >= 0 && index < [TimeChartViewController selectedTasks].count);
        NSTask* task = [TimeChartViewController selectedTasks][index];
        
        if ( [plot.identifier isEqual:@"ValidTimeInterval"] ) {
            num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:[task getValidTime]];
        }
//        else if ( [plot.identifier isEqual:@"Baseline"] ) {
//            num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:self.maxYAxisTime/2.f];
//        }
        else if ( [plot.identifier isEqual:@"TotalTimeInterval"] ) {
            num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:[task getTotalTime]];
        }
    }
    else if(fieldEnum == CPTScatterPlotFieldX){
        num = [NSNumber numberWithFloat:index+1];
    }

    return num;
}

@end
