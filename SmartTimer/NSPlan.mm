//
//  NPlan.m
//  SmartTimer
//
//  Created by baowei on 14-2-22.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import "NSPlan.h"

@implementation NSPlan

- (id)initWithPlan:(const struct Plan*)plan{
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

- (NSString*)getIntervalStr{
    NSInteger ti = [self.interval integerValue];
    NSInteger hours = (ti / 3600);
    NSInteger minutes = (ti / 60) % 60;
    return [NSString stringWithFormat:@"%02i:%02i", hours, minutes];
}

- (NSString*)getCurrentTimeStr{
    NSDate *now = [NSDate date];
    NSDateComponents *nowComps = [[NSCalendar currentCalendar]
                                 components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitEra
                                 fromDate:now];
    NSDateComponents *ctComps = [[NSCalendar currentCalendar]
                                 components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitEra
                                 fromDate:_currentTime];
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
    
    return [ft stringFromDate:_currentTime];
}

@end
