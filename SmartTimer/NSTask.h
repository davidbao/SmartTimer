//
//  NSTask.h
//  SmartTimer
//
//  Created by baowei on 14-2-25.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Plan.h"

@class NSPlan;

@interface NSTask : NSObject

@property (nonatomic) NSInteger taskId;
@property (nonatomic) NSInteger planId;
@property (nonatomic,strong) NSDate *startTime;
@property (nonatomic,weak) NSPlan *plan;

@property (nonatomic, strong) NSMutableArray *intervals;

+ (NSString*)getTimeStr:(NSDate*)time;
+ (NSString*)getHMTimeStr:(int)time;

- (id)initWithPlan:(NSPlan*)plan task:(const Task*)task;
- (id)initWithTaskId:(int)taskId;

- (NSString*)getNameStr;
- (NSString*)getPlanTimeStr;

- (NSInteger)getValidTime;
- (NSString*)getValidTimeStr;

- (NSInteger)getTotalTime;
- (NSString*)getTotalTimeStr;

- (NSDate*)getStartTime;
- (NSString*)getStartTimeStr;

- (NSInteger)getPauseTime;
- (NSString*)getPauseTimeStr;

- (NSDate*)getStopTime;
- (NSString*)getFullStartTimeStr;
- (NSString*)getFullStopTimeStr;

- (NSInteger)getPauseCount;
- (NSString*)getPauseCountStr;

@end