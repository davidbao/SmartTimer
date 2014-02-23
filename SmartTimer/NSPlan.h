//
//  NPlan.h
//  SmartTimer
//
//  Created by baowei on 14-2-22.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Plan.h"

@interface NSPlan : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic) NSInteger planId;
@property (nonatomic,strong) NSNumber *internal;
@property (nonatomic,strong) NSDate *currentTime;

- (id)initWithPlan:(const Plan*)plan;
- (id)initWithName:(NSInteger) planId name:(NSString *)name internal:(NSNumber *)internal currentTime:(NSDate *)currentTime;

- (NSString*)getInternalStr;
- (NSString*)getCurrentTimeStr;

@end
