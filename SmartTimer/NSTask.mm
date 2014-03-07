//
//  NSTask.m
//  SmartTimer
//
//  Created by baowei on 14-2-25.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "NSTask.h"
#import "NSPlan.h"
#include "common/Convert.h"

@implementation NSTask

- (id)initWithPlan:(NSPlan*)plan task:(const Task*)task{
    NSInteger planId = task->PlanId;
    NSDate *startTime = [[NSDate alloc] initWithTimeIntervalSince1970:task->StartTime];
    
    NSTask *nstask = [[NSTask alloc] initWithTaskId:task->Id];
    nstask.planId = planId;
    nstask.plan = plan;
    nstask.startTime = startTime;
    const Array<time_t>* intervals = task->getIntervals();
    nstask.intervals = [NSMutableArray arrayWithObjects:nil];
    for(int i=0;i<intervals->count();i++){
        time_t interval = intervals->at(i);
        [nstask.intervals addObject:[NSNumber numberWithInteger:interval]];
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

+ (NSString*)getTimeStr:(NSDate*)time{
    NSDate *now = [NSDate date];
    NSDateComponents *nowComps = [[NSCalendar currentCalendar]
                                  components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitEra
                                  fromDate:now];
    NSDateComponents *ctComps = [[NSCalendar currentCalendar]
                                 components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitEra
                                 fromDate:time];
    NSDateFormatter *ft = [[NSDateFormatter alloc] init];
    
    if (nowComps.year == ctComps.year &&
        nowComps.month == ctComps.month &&
        nowComps.day == ctComps.day &&
        nowComps.era == ctComps.era) {
        [ft setDateFormat:@"HH:mm"];
    }
    else if (nowComps.year == ctComps.year &&
             nowComps.month == ctComps.month &&
             nowComps.day - 1 == ctComps.day &&
             nowComps.era == ctComps.era) {
        return NSLocalizedString(@"yesterday", @"");
    }
    else if (nowComps.year == ctComps.year &&
             nowComps.month == ctComps.month &&
             nowComps.day - 7 <= ctComps.day &&
             nowComps.era == ctComps.era) {
        [ft setDateFormat:@"cccc"];
    }
    else{
        [ft setDateFormat:@"yy-MM-dd"];
    }
    
    return [ft stringFromDate:time];
}
+ (NSString*)getHMTimeStr:(int)time{
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    return [NSString stringWithFormat:@"%02i:%02i", hours, minutes];
}

- (NSString*)getNameStr{
    return [NSString stringWithFormat:@"%@%d", NSLocalizedString(@"task", @""), self.taskId];
}

- (NSString*)getPlanTimeStr{
    assert(self.plan != nil);
    return [self.plan getIntervalStr];
}

- (NSInteger)getValidTime{
    time_t value = 0;
    for(int i=0;i<self.intervals.count;i++){
        time_t interval = [self.intervals[i] intValue];
        time_t prevInterval = i > 0 ? [self.intervals[i-1] intValue] : 0;
        if((i % 2) == 0){     // pause
            assert(interval > prevInterval);
            value += interval - prevInterval;
        }
        else{                // resume or stop
        }
    }
    return value;
}
- (NSString*)getValidTimeStr{
    return [NSTask getHMTimeStr:[self getValidTime]];
}

- (NSInteger)getTotalTime{
    if(self.intervals.count == 0){
        return 0;
    }
    else{
        return [self.intervals[self.intervals.count-1] intValue];
    }
}
- (NSString*)getTotalTimeStr{
    return [NSTask getHMTimeStr:[self getTotalTime]];
}

- (NSDate*)getStartTime{
    return self.startTime;
}
- (NSString*)getStartTimeStr{
    return [NSTask getTimeStr:[self getStartTime]];
}

- (NSInteger)getPauseTime{
    time_t value = 0;
    for(int i=0;i<self.intervals.count;i++){
        time_t interval = [self.intervals[i] intValue];
        time_t prevInterval = i > 0 ? [self.intervals[i-1] intValue] : 0;
        if((i % 2) == 0){     // pause
            
        }
        else{                // resume or stop
            assert(interval > prevInterval);
            value += interval - prevInterval;
        }
    }
    return value;
}
- (NSString*)getPauseTimeStr{
    return [NSTask getHMTimeStr:[self getPauseTime]];
}

- (NSDate*)getStopTime{
    time_t interval = [self getTotalTime];
    if(interval == 0){
        return nil;
    }
    else{
        return [self.startTime dateByAddingTimeInterval:interval];
    }
}
- (NSString*)getFullStartTimeStr{
    string str = Convert::getDateTimeStr([self.startTime timeIntervalSince1970]);
    return [NSString stringWithUTF8String:str.c_str()];
}
- (NSString*)getFullStopTimeStr{
    NSDate* date = [self getStopTime];
    if(date == nil){
        return @"";
    }
    else{
        string str = Convert::getDateTimeStr([date timeIntervalSince1970]);
        return [NSString stringWithUTF8String:str.c_str()];
    }
}

- (NSInteger)getPauseCount{
    return self.intervals.count / 2;
}
- (NSString*)getPauseCountStr{
    return [NSString stringWithFormat:@"%d", [self getPauseCount]];
}

@end
