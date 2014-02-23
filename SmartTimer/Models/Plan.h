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
    int Id;
    string Name;
    time_t Interval;
    time_t CurrentTime;
    
    Plan(const string& name, const time_t interval, time_t currentTime)
    {
        static int _currentId = 0;
        
        Id = _currentId;
        Name = name;
        Interval = interval;
        CurrentTime = currentTime;
    }
};

typedef Vector<Plan> Plans;

#endif
