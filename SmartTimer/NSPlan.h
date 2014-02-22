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
@property (nonatomic,strong) NSNumber *internal;
@property (nonatomic,strong) NSDate *currentTime;

- (id)initWithPlan:(const Plan*)plan;
- (id)initWithName:(NSString *)name internal:(NSNumber *)internal currentTime:(NSDate *)currentTime;

- (NSString*)getInternalStr;

@end
