//
//  TimeChartViewController.mm
//  SmartTimer
//
//  Created by baowei on 14-3-8.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "TimeChartViewController.h"

@interface TimeChartViewController ()

@end

@implementation TimeChartViewController

static NSMutableArray* selectedTasks = [NSMutableArray arrayWithObjects:nil];

+ (void)setSelectedTasks:(NSMutableArray*) tasks {
    [selectedTasks removeAllObjects];
    [selectedTasks addObjectsFromArray:tasks];
}
+ (NSMutableArray*) selectedTasks {
    return selectedTasks;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return selectedTasks.count;
}

- (void)calcMaxYAxisTime {
    int maxTime = 0;
    for (int i=0; i< selectedTasks.count; i++) {
        NSTask* task =  selectedTasks[i];
        int time = [task getTotalTime];
        if(time > maxTime){
            maxTime = time;
        }
    }
    
    self.maxYAxisTime = maxTime * 120 / 100;
    
    self.validTimeColor = [CPTColor colorWithComponentRed:130.f/225.f green:255.f/255.f blue:90.f/255.f alpha:1.f];
    self.totalTimeColor = [CPTColor colorWithComponentRed:90.f/225.f green:130.f/255.f blue:255.f/255.f alpha:1.f];
    self.themeName = kCPTPlainWhiteTheme;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self calcMaxYAxisTime];
}

- (void)initPlot {
    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:self.themeName];
    [graph applyTheme:theme];
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.hostedGraph = graph;
    
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
    graph.plotAreaFrame.paddingLeft   = 45.0;
    graph.plotAreaFrame.paddingRight  = 20;
    graph.plotAreaFrame.paddingTop    = version < 7.0 ? 20.0 : 98.0;
    graph.plotAreaFrame.paddingBottom = version < 7.0 ? 20.0 : 98.0;
    
    // Graph title
    //    NSString *lineOne = NSLocalizedString(@"Total&AllTimeStat", nil);
    //    NSString *lineTwo = @"Line 2";
    
    //    BOOL hasAttributedStringAdditions = (&NSFontAttributeName != NULL) &&
    //    (&NSForegroundColorAttributeName != NULL) &&
    //    (&NSParagraphStyleAttributeName != NULL);
    //
    //    if ( hasAttributedStringAdditions ) {
    //        NSMutableAttributedString *graphTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo]];
    //        [graphTitle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, lineOne.length)];
    //        [graphTitle addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
    //        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //        paragraphStyle.alignment = (NSTextAlignment)CPTTextAlignmentCenter;
    //        [graphTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, graphTitle.length)];
    //        UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    //        [graphTitle addAttribute:NSFontAttributeName value:titleFont range:NSMakeRange(0, lineOne.length)];
    //        titleFont = [UIFont fontWithName:@"Helvetica" size:12.0];
    //
    //        [graphTitle addAttribute:NSFontAttributeName value:titleFont range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
    //
    //        graph.attributedTitle = graphTitle;
    //    }
    //    else {
    //        CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    //        titleStyle.color         = [CPTColor whiteColor];
    //        titleStyle.fontName      = @"Helvetica-Bold";
    //        titleStyle.fontSize      = 16.0;
    //        titleStyle.textAlignment = CPTTextAlignmentCenter;
    //
    //        graph.title          = [NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo];
    //        graph.titleTextStyle = titleStyle;
    //    }
    
    //    graph.titleDisplacement        = CGPointMake(0.0f, -20.0f);
    //    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromInteger(self.maxYAxisTime)];
    int xAxisLength =  selectedTasks.count + 1;
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
    NSMutableArray *customTickLocations = [NSMutableArray arrayWithObjects:nil];
    NSMutableArray *xAxisLabels         = [NSMutableArray arrayWithObjects:nil];
    for(int i=0;i< selectedTasks.count;i++) {
        NSTask* task =  selectedTasks[i];
        [xAxisLabels addObject:[task getNameStr]];
        int value = i + 1;
        [customTickLocations addObject:[NSDecimalNumber numberWithInt:value]];
    }
    NSUInteger labelLocation     = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    for ( NSNumber *tickLocation in customTickLocations ) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[xAxisLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset       = x.labelOffset + x.majorTickLength;
        newLabel.rotation     = M_PI / 4;
        [customLabels addObject:newLabel];
    }
    
    x.axisLabels = [NSSet setWithArray:customLabels];
    
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
}

@end
