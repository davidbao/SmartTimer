//
//  PlanService.cpp
//  SmartTimer
//
//  Created by baowei on 14-2-21.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#include "PlanService.h"

void PlanService::addPlan(const string& name, const time_t interval, const time_t currentTime)
{
    _plans.add(new Plan(name, interval, currentTime));
}

void PlanService::editPlan(int planId, const string& name, const time_t interval, const time_t currentTime)
{
    for (int i=0; i<_plans.count(); i++) {
        Plan* plan = _plans.at(i);
        if(plan->Id == planId)
        {
            plan->Name = name;
            plan->Interval = interval;
            plan->CurrentTime = currentTime;
            return;
        }
    }
}