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
    CPTXYGraph *graph;
    
    NSMutableArray *dataForPlot;
}

@property (readwrite, strong, nonatomic) NSMutableArray *dataForPlot;

@end
