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
