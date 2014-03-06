//
//  TimeBarChartViewController
//  SmartTimer
//
//  Created by baowei on 14-2-23.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface TimeBarChartViewController : UIViewController<CPTPlotDataSource>
{
    @private
    CPTXYGraph *barChart;
    NSTimer *timer;
}

@property (readwrite, strong, nonatomic) NSTimer *timer;

-(void)timerFired;

+ (void)setSelectedTasks:(NSMutableArray*) tasks;

@end
