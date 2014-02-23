//
//  PlanService.cpp
//  SmartTimer
//
//  Created by baowei on 14-2-21.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#include "PlanService.h"
#include "StorageService.h"

using namespace Storage;

void PlanService::addPlan(const string& name, const time_t interval, const time_t currentTime)
{
    StorageService* sservice = Singleton<StorageService>::instance();
    assert(sservice);
    Plan plan(name, interval, currentTime);
    sservice->addPlan(plan);
}

const Plans* PlanService::getPlans() const
{
    StorageService* sservice = Singleton<StorageService>::instance();
    assert(sservice);
    return sservice->getPlans();
}

void PlanService::editPlan(int planId, const string& name, const time_t interval, const time_t currentTime)
{
    StorageService* sservice = Singleton<StorageService>::instance();
    assert(sservice);
    Plan plan(planId, name, interval, currentTime);
    sservice->updatePlan(plan);
}