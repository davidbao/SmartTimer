//
//  StorageService.h
//  SmartTimer
//
//  Created by baowei on 14-2-23.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#ifndef __SmartTimer__StorageService__
#define __SmartTimer__StorageService__

#include <iostream>
#include "Common/Singleton.h"
#include "Common/SqliteClient.h"
#include "Models/Plan.h"

using namespace Common;

namespace Storage
{
    class StorageService
    {
    public:
        StorageService(void);
        ~StorageService(void);
        
        void openDb(const string& path, const string& sql);
        void closeDb();
        
        void selectPlans();
        void addPlan(const Plan& plan);
        void addPlan(const Plans& plans);
        void updatePlan(const Plan& plan);
        void removePlan(const Plan& plan);
		inline Plans* getPlans()
		{
			if(_needUpdatePlans)
			{
				selectPlans();
			}
            
			return &_plans;
		}
        
    private:
        DECLARE_SINGLETON_CLASS(StorageService);
        
        bool fileExists(const string& fileName) const;
        int getFileLength(const string& fileName) const;
        bool isWritable(const string& fileName) const;
        
#if DEBUG
        void insertDebugData();
#endif
        
        SqliteClient* _sqliteClient;
        
		Plans _plans;
		bool _needUpdatePlans;
		mutex _plansMutex;
    };
}
    
#endif /* defined(__SmartTimer__StorageService__) */
