//
//  NSTask.h
//  SmartTimer
//
//  Created by baowei on 14-2-25.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Plan.h"

@interface NSTask : NSObject

@property (nonatomic) NSInteger taskId;
@property (nonatomic) NSInteger planId;
@property (nonatomic,strong) NSDate *startTime;

@property (nonatomic, strong) NSMutableArray *intervals;

- (id)initWithTask:(const Task*)task;
- (id)initWithTaskId:(int)taskId;

- (NSString*)getNameStr;
- (NSString*)getTotalTimeStr;
- (NSString*)getStartTimeStr;

- (NSInteger)getTotalTime;

@end