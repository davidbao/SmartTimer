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
    }
    
    return self;
}

- (NSString*)getNameStr{
    return [NSString stringWithFormat:@"%d - %@", self.planId, self.name];
}

- (NSString*)getIntervalStr{
    NSInteger ti = [self.interval integerValue];
    NSInteger hours = (ti / 3600);
    NSInteger minutes = (ti / 60) % 60;
    return [NSString stringWithFormat:@"%02i:%02i", hours, minutes];
}

- (NSString*)getCurrentTimeStr{
    return [NSPlan getTimeStr:self.currentTime];
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

@end
