//
//  NPlan.h
//  SmartTimer
//
//  Created by baowei on 14-2-22.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSTask.h"
#include "Plan.h"

@interface NSPlan : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic) NSInteger planId;
@property (nonatomic,strong) NSNumber *interval;
@property (nonatomic,strong) NSDate *currentTime;

@property (nonatomic, strong) NSMutableArray *tasks;

- (id)initWithPlan:(const Plan*)plan;
- (id)initWithName:(NSInteger) planId name:(NSString *)name interval:(NSNumber *)interval currentTime:(NSDate *)currentTime;

- (NSString*)getNameStr;
- (NSString*)getIntervalStr;
- (NSString*)getCurrentTimeStr;

- (Boolean)equalTo:(NSPlan*) plan;
- (Boolean)equalTo:(NSString*) name interval:(NSNumber *)interval;

- (void)toPlan:(Plan&)plan;
- (void)fromPlan:(const Plan&)plan;

@end
