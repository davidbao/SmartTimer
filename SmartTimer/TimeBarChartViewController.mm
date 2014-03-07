//
//  TimeBarChartViewController
//  SmartTimer
//
//  Created by baowei on 14-2-23.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "TimeBarChartViewController.h"
#include "NSTask.h"

static NSMutableArray* selectedTasks = [NSMutableArray arrayWithObjects:nil];

@interface TimeBarChartViewController ()

@property (nonatomic) NSInteger maxYAxisTime;

@end

@implementation TimeBarChartViewController

@synthesize timer;

- (void)viewDidLoad
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)setSelectedTasks:(NSMutableArray*) tasks {
    [selectedTasks removeAllObjects];
    [selectedTasks addObjectsFromArray:tasks];
}

- (IBAction)DoneAction:(id)sender {
    [selectedTasks removeAllObjects];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self timerFired];
#ifdef MEMORY_TEST
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                                selector:@selector(timerFired) userInfo:nil repeats:YES];
#endif
}

-(void)timerFired
{
#ifdef MEMORY_TEST
    static NSUInteger counter = 0;
    
    NSLog(@"\n----------------------------\ntimerFired: %lu", counter++);
#endif
    
    // Create barChart from theme
    barChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [barChart applyTheme:theme];
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.hostedGraph = barChart;
    
    // Border
    barChart.plotAreaFrame.borderLineStyle = nil;
    barChart.plotAreaFrame.cornerRadius    = 0.0f;
    barChart.plotAreaFrame.masksToBorder   = NO;
    
    // Paddings
    barChart.paddingLeft   = 0.0f;
    barChart.paddingRight  = 0.0f;
    barChart.paddingTop    = 0.0f;
    barChart.paddingBottom = 0.0f;
    
    barChart.plotAreaFrame.paddingLeft   = 45.0;
    barChart.plotAreaFrame.paddingTop    = 20.0;
    barChart.plotAreaFrame.paddingRight  = 20.0;
    barChart.plotAreaFrame.paddingBottom = 50.0;
    
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
//        barChart.attributedTitle = graphTitle;
//    }
//    else {
//        CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
//        titleStyle.color         = [CPTColor whiteColor];
//        titleStyle.fontName      = @"Helvetica-Bold";
//        titleStyle.fontSize      = 16.0;
//        titleStyle.textAlignment = CPTTextAlignmentCenter;
//        
//        barChart.title          = [NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo];
//        barChart.titleTextStyle = titleStyle;
//    }
    
//    barChart.titleDisplacement        = CGPointMake(0.0f, -20.0f);
//    barChart.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)barChart.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromInteger(self.maxYAxisTime)];
    int xAxisLength = selectedTasks.count * 2;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(xAxisLength)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)barChart.axisSet;
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
    for(int i=0;i<selectedTasks.count;i++) {
        NSTask* task = selectedTasks[i];
        [xAxisLabels addObject:[task getNameStr]];
        int value = i == 0 ? 1 : i * 2;
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
    
    // First bar plot
    CPTBarPlot *barPlot     = [CPTBarPlot tubularBarPlotWithColor:[CPTColor darkGrayColor] horizontalBars:NO];
    barPlot.baseValue       = CPTDecimalFromString(@"0");
    barPlot.dataSource      = self;
    barPlot.barOffset       = CPTDecimalFromFloat(1.f);
    barPlot.identifier      = @"ValidTimeInterval";
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
    
    // Second bar plot
    barPlot                 = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.baseValue       = CPTDecimalFromString(@"0");
    barPlot.barOffset       = CPTDecimalFromFloat(1.5f);
    barPlot.barCornerRadius = 2.0f;
    barPlot.identifier      = @"TotalTimeInterval";
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return selectedTasks.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = nil;
    
    if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:index];
                break;
                
            case CPTBarPlotFieldBarTip:
                assert(index >= 0 && index < selectedTasks.count);
                NSTask* task = selectedTasks[index];
                
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
