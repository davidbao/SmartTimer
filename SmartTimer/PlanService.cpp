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

void PlanService::deletePlan(const Plan& plan)
{
    StorageService* sservice = Singleton<StorageService>::instance();
    assert(sservice);
    sservice->deletePlan(plan);
}

bool PlanService::getPlan(int planId, Plan& plan)
{
    StorageService* sservice = Singleton<StorageService>::instance();
    assert(sservice);
    return sservice->getPlan(planId, plan);
}

const Tasks* PlanService::getTasks(int planId)
{
    const Plans* plans = getPlans();
    for(int i=0;i<plans->count();i++)
    {
        const Plan* plan = plans->at(i);
        if(plan->Id == planId)
        {
            return plan->getTasks();
        }
    }
    return NULL;
}

void PlanService::updateTasks(int planId, const Tasks& tasks)
{
    const Plans* plans = getPlans();
    for(int i=0;i<plans->count();i++)
    {
        Plan* plan = plans->at(i);
        if(plan->Id == planId)
        {
            plan->clearTask();
            plan->addTasks(tasks);
        }
    }
}

