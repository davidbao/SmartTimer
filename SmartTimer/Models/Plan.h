//
//  PlanInfo.h
//  SmartTimer
//
//  Created by baowei on 14-2-21.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#ifndef SmartTimer_PlanInfo_h
#define SmartTimer_PlanInfo_h

#include <stdio.h>
#include <string>
#include "../common/Vector.h"

using namespace std;

struct Plan{
public:
    string Name;
    time_t Interval;
};

typedef Vector<Plan> Plans;

#endif
