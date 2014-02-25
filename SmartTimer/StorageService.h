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
        
        inline void initDbInfo(const string& path, const string& sql)
        {
            assert(!path.empty());
            assert(!sql.empty());
            
            _path = path;
            _sql = sql;
        }
        void openDb();
        void closeDb();
        
        void selectPlans();
        void addPlan(const Plan& plan);
        void addPlan(const Plans& plans);
        void updatePlan(const Plan& plan);
        void deletePlan(const Plan& plan);
		inline Plans* getPlans()
		{
			if(_needUpdatePlans)
			{
				selectPlans();
			}
            
			return &_plans;
		}
        bool getPlan(int planId, Plan& plan);

    private:
        DECLARE_SINGLETON_CLASS(StorageService);
        
        bool fileExists(const string& fileName) const;
        int getFileLength(const string& fileName) const;
        
#if DEBUG
        void insertDebugData();
#endif
        
        SqliteClient* _sqliteClient;
        
		Plans _plans;
		bool _needUpdatePlans;
		mutex _plansMutex;
        
        string _path;
        string _sql;
    };
}
    
#endif /* defined(__SmartTimer__StorageService__) */
