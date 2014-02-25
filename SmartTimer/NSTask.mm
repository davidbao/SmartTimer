//
//  NSTask.m
//  SmartTimer
//
//  Created by baowei on 14-2-25.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "NSTask.h"
#import "NSPlan.h"

@implementation NSTask

- (id)initWithTask:(const Task*)task{
    NSInteger planId = task->PlanId;
    NSDate *startTime = [[NSDate alloc] initWithTimeIntervalSince1970:task->StartTime];
    
    NSTask *nstask = [[NSTask alloc] initWithTaskId:task->Id];
    nstask.planId = planId;
    nstask.startTime = startTime;
    const Array<time_t>* intervals = task->getIntervals();
    for(int i=0;i<intervals->count();i++){
        time_t interval = intervals->at(i);
        [self.intervals addObject:[NSNumber numberWithInteger:interval]];
    }
    
    return nstask;
}
- (id)initWithTaskId:(int)taskId{
    self = [super init];
    
    if (self)
    {
        _taskId = taskId;
    }
    
    return self;
}

- (NSInteger)getTotalTime{
    return 0;
}

- (NSString*)getNameStr{
    return [NSString stringWithFormat:@"%@%d", NSLocalizedString(@"task", @""), self.taskId];
}

- (NSString*)getTotalTimeStr{
    NSInteger ti = [self getTotalTime];
    NSInteger hours = (ti / 3600);
    NSInteger minutes = (ti / 60) % 60;
    return [NSString stringWithFormat:@"%02i:%02i", hours, minutes];
}

- (NSString*)getStartTimeStr{
    return [NSPlan getTimeStr:self.startTime];
}

@end
