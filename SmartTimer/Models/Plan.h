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
#include "../common/Array.h"

using namespace std;
using namespace Common;

struct Task{
public:
    int Id;
    int PlanId;
    time_t StartTime;
    
    Task(){
        Id = 0;
        PlanId = 0;
        clearIntervals();
    }
    
    inline void addInterval(time_t interval)
    {
        _intervals.add(interval);
    }
    inline void clearIntervals()
    {
        _intervals.clear();
    }
    inline const Array<time_t>* getIntervals() const
    {
        return (const Array<time_t>*)&_intervals;
    }
    
private:
    Array<time_t> _intervals;
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
    
    inline void copyFrom(const Plan* plan)
    {
        Id = plan->Id;
        Name = plan->Name;
        Interval = plan->Interval;
        CurrentTime = plan->CurrentTime;
        _tasks.addRange(&plan->_tasks);
    }
    
    inline void addTask(const Task* task)
    {
        _tasks.add(task);
    }
    inline Task* getTask(int taskId) const
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
    inline int getTaskCount() const
    {
        return _tasks.count();
    }
    inline const Tasks* getTasks() const
    {
        return &_tasks;
    }
    
    inline bool enabled() const
    {
        return Interval > 0;
    }
    
private:
    Tasks _tasks;
};

typedef Vector<Plan> Plans;

#endif
