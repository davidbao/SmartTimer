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
    void addPlan(const Plan& plan);
    
    const Plans* getPlans() const;
    
    void updatePlan(const Plan& plan);
    
    void deletePlan(const Plan& plan);
    
    bool getPlan(int planId, Plan& plan);
    
    const Tasks* getTasks(int planId);
    
    void updateTasks(int planId, const Tasks& tasks);
    
private:
    DECLARE_SINGLETON_CLASS(PlanService);
};

#endif /* defined(__SmartTimer__PlanService__) */
