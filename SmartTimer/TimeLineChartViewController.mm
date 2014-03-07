//
//  TimeLineChartViewController.mm
//  SmartTimer
//
//  Created by baowei on 14-3-6.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "TimeLineChartViewController.h"
#import "NSTask.h"

static NSMutableArray* selectedTasks = [NSMutableArray arrayWithObjects:nil];

@interface TimeLineChartViewController ()

@property (nonatomic) NSInteger maxYAxisTime;

@end

@implementation TimeLineChartViewController

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (IBAction)DoneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (void)setSelectedTasks:(NSMutableArray*) tasks {
    [selectedTasks removeAllObjects];
    [selectedTasks addObjectsFromArray:tasks];
}

#pragma mark -
#pragma mark Initialization and teardown

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    int maxTime = 0;
    for (int i=0; i<selectedTasks.count; i++) {
        NSTask* task = selectedTasks[i];
        int time = [task getTotalTime];
        if(time > maxTime){
            maxTime = time;
        }
    }
    
    self.maxYAxisTime = maxTime * 120 / 100;
    
    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph     = graph;
    
    // Border
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.cornerRadius    = 0.0f;
    graph.plotAreaFrame.masksToBorder   = NO;
    
    // Paddings
    graph.paddingLeft   = 0.0f;
    graph.paddingRight  = 0.0f;
    graph.paddingTop    = 0.0f;
    graph.paddingBottom = 0.0f;
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    graph.plotAreaFrame.paddingLeft   = version < 7.0 ? 45.0 : 98.0;
    graph.plotAreaFrame.paddingTop    = 20.0;
    graph.plotAreaFrame.paddingRight  = 20.0;
    graph.plotAreaFrame.paddingBottom = version < 7.0 ? 50.0 : 98.0;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromInteger(self.maxYAxisTime)];
    int xAxisLength = selectedTasks.count + 1;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(xAxisLength)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    //    x.axisLineStyle               = nil;
    //    x.majorTickLineStyle          = nil;
    //    x.minorTickLineStyle          = nil;
    x.majorIntervalLength         = CPTDecimalFromString(@"1");
    //    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    //    x.title                       = NSLocalizedString(@"task", nil);
    //    x.titleLocation               = CPTDecimalFromFloat(7.5f);
    //    x.titleOffset                 = 55.0f;
    
    // Define some custom labels for the data elements
    x.labelRotation  = M_PI / 4;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    CPTXYAxis *y = axisSet.yAxis;
    //    y.axisLineStyle               = nil;
    //    y.majorTickLineStyle          = nil;
    //    y.minorTickLineStyle          = nil;
    y.majorIntervalLength           = CPTDecimalFromFloat(self.maxYAxisTime/5.0f);
    y.minorTicksPerInterval         = 0;
    y.labelOffset                   = 0;
    //    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    //    y.title                         = NSLocalizedString(@"Time", nil);
    //    y.titleOffset                   = 45.0f;
    //    y.titleLocation               = CPTDecimalFromFloat(1500.0f);
    NSDateFormatter *dateformatter  = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:mm"];
    NSDate *now = [NSDate date];
    NSDateComponents *nowComps = [[NSCalendar currentCalendar]
                                  components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear
                                  fromDate:now];
    NSDate* refDate = [[NSCalendar currentCalendar] dateFromComponents:nowComps];
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateformatter];
    timeFormatter.referenceDate     = refDate;
    y.labelFormatter                = timeFormatter;
    
    // Create a blue plot area
    CPTScatterPlot *boundLinePlot  = [[CPTScatterPlot alloc] init];
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit        = 1.0f;
    lineStyle.lineWidth         = 3.0f;
    lineStyle.lineColor         = [CPTColor blueColor];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.identifier    = @"ValidTimeInterval";
    boundLinePlot.dataSource    = self;
    [graph addPlot:boundLinePlot];
    
//    // Do a blue gradient
//    CPTColor *areaColor1       = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
//    CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:areaColor1 endingColor:[CPTColor clearColor]];
//    areaGradient1.angle = -90.0f;
//    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient1];
//    boundLinePlot.areaFill      = areaGradientFill;
//    boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
    
    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:boundLinePlot.dataLineStyle.lineColor];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(10.0, 10.0);
    boundLinePlot.plotSymbol = plotSymbol;
    
    // Create a green plot area
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    lineStyle                        = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit             = 1.0f;
    lineStyle.lineWidth              = 3.f;
    lineStyle.lineColor              = [CPTColor greenColor];
//    lineStyle.dashPattern            = [NSArray arrayWithObjects:[NSNumber numberWithFloat:5.0f], [NSNumber numberWithFloat:5.0f], nil];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.identifier    = @"TotalTimeInterval";
    dataSourceLinePlot.dataSource    = self;
    [graph addPlot:dataSourceLinePlot];
    
    // Put an area gradient under the plot above
//    CPTColor *areaColor       = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
//    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
//    areaGradient.angle               = -90.0f;
//    areaGradientFill                 = [CPTFill fillWithGradient:areaGradient];
//    dataSourceLinePlot.areaFill      = areaGradientFill;
//    dataSourceLinePlot.areaBaseValue = CPTDecimalFromString(@"1.75");
    
    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle2 = [CPTMutableLineStyle lineStyle];
    symbolLineStyle2.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol2 = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol2.fill          = [CPTFill fillWithColor:dataSourceLinePlot.dataLineStyle.lineColor];
    plotSymbol2.lineStyle     = symbolLineStyle2;
    plotSymbol2.size          = CGSizeMake(10.0, 10.0);
    dataSourceLinePlot.plotSymbol = plotSymbol2;
    
//    // Animate in the new plot, as an example
//    dataSourceLinePlot.opacity = 0.0f;
//    
//    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    fadeInAnimation.duration            = 1.0f;
//    fadeInAnimation.removedOnCompletion = NO;
//    fadeInAnimation.fillMode            = kCAFillModeForwards;
//    fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
//    [dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return selectedTasks.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;
    
    // Green plot gets shifted above the blue
    if ( fieldEnum == CPTScatterPlotFieldY ) {
        assert(index >= 0 && index < selectedTasks.count);
        NSTask* task = selectedTasks[index];
        
        if ( [plot.identifier isEqual:@"ValidTimeInterval"] ) {
            num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:[task getValidTime]];
        }
        else if ( [plot.identifier isEqual:@"TotalTimeInterval"] ) {
            num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:[task getTotalTime]];
        }
    }
    else if(fieldEnum == CPTScatterPlotFieldX){
        num = [NSNumber numberWithFloat:index+1];
    }

    return num;
}

#pragma mark -
#pragma mark Axis Delegate Methods

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    static CPTTextStyle *positiveStyle = nil;
    static CPTTextStyle *negativeStyle = nil;
    
    NSFormatter *formatter = axis.labelFormatter;
    CGFloat labelOffset    = axis.labelOffset;
    NSDecimalNumber *zero  = [NSDecimalNumber zero];
    
    NSMutableSet *newLabels = [NSMutableSet set];
    
    for ( NSDecimalNumber *tickLocation in locations ) {
        CPTTextStyle *theLabelTextStyle;
        
        if ( [tickLocation isGreaterThanOrEqualTo:zero] ) {
            if ( !positiveStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor greenColor];
                positiveStyle  = newStyle;
            }
            theLabelTextStyle = positiveStyle;
        }
        else {
            if ( !negativeStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor redColor];
                negativeStyle  = newStyle;
            }
            theLabelTextStyle = negativeStyle;
        }
        
        NSString *labelString       = [formatter stringForObjectValue:tickLocation];
        CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
        newLabel.tickLocation = tickLocation.decimalValue;
        newLabel.offset       = labelOffset;
        
        [newLabels addObject:newLabel];
    }
    
    axis.axisLabels = newLabels;
    
    return NO;
}

@end
