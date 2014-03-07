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

bool PlanService::hasSamePlanId(const Tasks* tasks, int planId)
{
    for(int i=0;i<tasks->count();i++) {
        Task* task = tasks->at(i);
        if(task->PlanId == planId) {
            return true;
        }
    }
    return false;
}

void PlanService::updateTasks(const Tasks& allTasks)
{
    Vector<Tasks> tasks;
    for (int i =0;i<allTasks.count();i++) {
        Task* task = allTasks.at(i);
        
        Tasks* addTasks = NULL;
        for (int j=0; j<tasks.count(); j++) {
            Tasks* temps = tasks.at(j);
            if(hasSamePlanId(temps, task->PlanId)) {
                addTasks = temps;
            }
        }
        
        if(addTasks == NULL)
        {
            addTasks = new Tasks();
            tasks.add(addTasks);
        }
        Task* newTask = new Task();
        newTask->copyFrom(task);
        addTasks->add(newTask);
    }

    const Plans* plans = getPlans();
    for (int j=0; j<tasks.count(); j++) {
        Tasks* temps = tasks.at(j);
        if(temps->count() > 0) {
            for(int i=0;i<plans->count();i++)
            {
                Plan* plan = plans->at(i);
                if(plan->Id == temps->at(0)->PlanId)
                {
//                    plan->clearTask();
                    plan->addTasks(*temps);
                    break;
                }
            }
        }
    }
}

