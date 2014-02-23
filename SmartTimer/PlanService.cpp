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

void PlanService::addPlan(const Plan& plan)
{
    StorageService* sservice = Singleton<StorageService>::instance();
    assert(sservice);
    sservice->addPlan(plan);
}

const Plans* PlanService::getPlans() const
{
    StorageService* sservice = Singleton<StorageService>::instance();
    assert(sservice);
    return sservice->getPlans();
}

void PlanService::updatePlan(const Plan& plan)
{
    StorageService* sservice = Singleton<StorageService>::instance();
    assert(sservice);
    sservice->updatePlan(plan);
}