//
//  TimeChartViewController.h
//  SmartTimer
//
//  Created by baowei on 14-3-8.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "NSTask.h"

@interface TimeChartViewController : UIViewController<CPTPlotDataSource, CPTAxisDelegate>
{
    @protected
    CPTXYGraph *graph;
}

@property (nonatomic) NSInteger maxYAxisTime;
@property (nonatomic, strong) CPTColor* validTimeColor;
@property (nonatomic, strong) CPTColor* totalTimeColor;
@property (nonatomic, strong) NSString* themeName;

+ (void)setSelectedTasks:(NSMutableArray*) tasks;
+ (NSMutableArray*) selectedTasks;

- (void)initPlot;

@end
