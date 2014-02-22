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
    NSNumber* internal = [[NSNumber alloc] initWithLong:plan->Interval];
    NSDate *currentTime = [[NSDate alloc] initWithTimeIntervalSince1970:plan->CurrentTime];
    
    NSPlan *nsplan = [[NSPlan alloc] initWithName:name internal:internal currentTime:currentTime];
    
    return nsplan;
}
- (id)initWithName:(NSString *)name internal:(NSNumber *)internal currentTime:(NSDate *)currentTime{
    self = [super init];
    
    if (self)
    {
        _name = name;
        _internal = internal;
        _currentTime = currentTime;
    }
    
    return self;
}

- (NSString*)getInternalStr{
    NSInteger ti = [self.internal integerValue];
    NSInteger hours = (ti / 3600);
    NSInteger minutes = (ti / 60) % 60;
    return [NSString stringWithFormat:@"%02i:%02i", hours, minutes];
}
@end
