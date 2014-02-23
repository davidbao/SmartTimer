//
//  PlanService.h
//  SmartTimer
//
//  Created by baowei on 14-2-21.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#ifndef __SmartTimer__PlanService__
#define __SmartTimer__PlanService__

#include <iostream>
#include "Common/Singleton.h"
#include "Plan.h"

using namespace Common;

class PlanService
{
public:
    void addPlan(const string& name, const time_t interval, const time_t currentTime);
    
    const Plans* getPlans() const;
    
    void editPlan(int planId, const string& name, const time_t interval, const time_t currentTime);
    
private:
    DECLARE_SINGLETON_CLASS(PlanService);
};

#endif /* defined(__SmartTimer__PlanService__) */
