//
//  NPlan.m
//  SmartTimer
//
//  Created by baowei on 14-2-22.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "NSPlan.h"

@implementation NSPlan

- (id)initWithPlan:(const Plan*)plan{
    NSString* name = [NSString stringWithUTF8String:plan->Name.c_str()];
    NSNumber* interval = [[NSNumber alloc] initWithLong:plan->Interval];
    NSDate *currentTime = [[NSDate alloc] initWithTimeIntervalSince1970:plan->CurrentTime];
    
    NSPlan *nsplan = [[NSPlan alloc] initWithName:plan->Id name:name interval:interval currentTime:currentTime];
    
    const Tasks* tasks = plan->getTasks();
    for (int i=0;i<tasks->count();i++)
    {
        const Task* task = tasks->at(i);
        NSTask* nstask = [[NSTask alloc] initWithPlan:self task:task];
        [nsplan.tasks addObject:nstask];
    }
    
    return nsplan;
}
- (id)initWithName:(NSInteger) planId name:(NSString *)name interval:(NSNumber *)interval currentTime:(NSDate *)currentTime{
    self = [super init];
    
    if (self)
    {
        _planId = planId;
        _name = name;
        _interval = interval;
        _currentTime = currentTime;
        
        _tasks = [NSMutableArray arrayWithObjects:nil];
    }
    
    return self;
}

- (NSString*)getNameStr{
    NSString* name = [self enabled] ? self.name : NSLocalizedString(@"Empty", nil);
    return [NSString stringWithFormat:@"%d - %@", self.planId, name];
}

- (NSString*)getIntervalStr{
    NSInteger ti = [self.interval integerValue];
    NSInteger hours = (ti / 3600);
    NSInteger minutes = (ti / 60) % 60;
    return [self enabled] ? [NSString stringWithFormat:@"%02i:%02i", hours, minutes] : @"";
}

- (NSString*)getCurrentTimeStr{
    return [self enabled] ? [NSTask getTimeStr:self.currentTime] : @"";
}

- (void)toPlan:(Plan&)plan{
    plan.Id = self.planId;
    plan.Name = [self.name UTF8String];
    plan.Interval = [self.interval longValue];  // unit: sec
    plan.CurrentTime = [self.currentTime timeIntervalSince1970];
}
- (void)fromPlan:(const Plan&)plan{
    NSString* name = [NSString stringWithUTF8String:plan.Name.c_str()];
    NSNumber* interval = [[NSNumber alloc] initWithLong:plan.Interval];
    NSDate *currentTime = [[NSDate alloc] initWithTimeIntervalSince1970:plan.CurrentTime];
    
    self.planId = plan.Id;
    self.name = name;
    self.interval = interval;
    self.currentTime = currentTime;
}

- (Boolean)equalTo:(NSPlan*) plan{
    return [self.name isEqualToString:plan.name] && [self.interval isEqualToNumber:plan.interval];
}

- (Boolean)equalTo:(NSString*) name interval:(NSNumber *)interval{
    return [self.name isEqualToString:name] && [self.interval isEqualToNumber:interval];
}

- (BOOL)enabled{
    return [self.interval longValue] > 0;
}
@end
