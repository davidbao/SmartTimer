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

struct Task{
public:
    int Id;
    int PlanId;
    time_t StartTime;
    
    Task(){
        Id = 0;
        PlanId = 0;
        _intervalCount = 0;
        memset(_intervals, 0, sizeof(_intervals));
    }
    
    void addInterval(time_t interval)
    {
        _intervals[_intervalCount++] = interval;
    }
    
private:
    time_t _intervals[32];
    int _intervalCount;
};

typedef Vector<Task> Tasks;

struct Plan{
public:
    int Id;
    string Name;
    time_t Interval;
    time_t CurrentTime;
    
    Plan()
    {
        Id = 0;
        Interval = 0;
        CurrentTime = 0;
    }
    Plan(const string& name, const time_t interval, time_t currentTime)
    {
        static int _currentId = 0;
        
        Id = ++_currentId;
        Name = name;
        Interval = interval;
        CurrentTime = currentTime;
    }
    Plan(int planId, const string& name, const time_t interval, time_t currentTime)
    {
        Id = planId;
        Name = name;
        Interval = interval;
        CurrentTime = currentTime;
    }
    
    void copyFrom(const Plan* plan)
    {
        Id = plan->Id;
        Name = plan->Name;
        Interval = plan->Interval;
        CurrentTime = plan->CurrentTime;
    }
    
    void addTask(const Task* task)
    {
        _tasks.add(task);
    }
    Task* getTask(int taskId) const
    {
        for(int i=0;i<_tasks.count();i++)
        {
            Task* task = _tasks.at(i);
            if(task->Id == taskId)
            {
                return task;
            }
        }
        return NULL;
    }
    
private:
    Tasks _tasks;
};

typedef Vector<Plan> Plans;

#endif
