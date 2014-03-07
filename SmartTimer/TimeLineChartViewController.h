//
//  TimeLineChartViewController.h
//  SmartTimer
//
//  Created by baowei on 14-3-6.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface TimeLineChartViewController : UIViewController<CPTPlotDataSource, CPTAxisDelegate>
{
    @private
    CPTXYGraph *graph;
}

+ (void)setSelectedTasks:(NSMutableArray*) tasks;

@end
