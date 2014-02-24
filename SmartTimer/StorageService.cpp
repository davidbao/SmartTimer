//
//  StorageService.cpp
//  SmartTimer
//
//  Created by baowei on 14-2-23.
//  Copyright (c) 2014年 TicktockLib. All rights reserved.
//

#include <stdio.h>
#include "Common/Stopwatch.h"
#include "StorageService.h"
#include "Common/Stopwatch.h"

namespace Storage
{
    StorageService::StorageService(void)
    {
        _needUpdatePlans = true;
        _sqliteClient = NULL;
    }

    StorageService::~StorageService(void)
    {
        closeDb();
    }
    
    bool StorageService::fileExists(const string& fileName) const
    {
        FILE* fp = fopen(fileName.c_str(), "r+b");
        if(fp != NULL)
        {
            fclose(fp);
            return true;
        }
        return false;
    }
    int StorageService::getFileLength(const string& fileName) const
    {
        FILE* fp = fopen(fileName.c_str(), "r+b");
        if(fp != NULL)
        {
            fseek(fp, 0L, SEEK_END);
            long length = ftell(fp);
            fclose(fp);
            return length;
        }
        return 0;
    }

    void StorageService::openDb()
    {
    #if DEBUG
        Stopwatch sw("Create or open database file");
    #endif
        
        // /Users/baowei/Library/Application Support/iPhone Simulator/7.0.3/Applications/38C384D2-9C25-4150-9282-04BAD990917C
        string fileName = _path + "/smartTimer.db";
        
        bool error = false;
        const char* errorMsg = NULL;
        
        _sqliteClient = new SqliteClient();
        int result = _sqliteClient->open(fileName.c_str());
        if(result == SQLITE_OK)
        {
            long length = getFileLength(fileName.c_str());
            if(length == 0)
            {
                // create some tables from resource.
                result = _sqliteClient->executeSql(_sql);
                if(result == SQLITE_OK)
                {
#if DEBUG
                    insertDebugData();
#endif
//                        result = insertInitializationData();
                    
//                        _createNewDBFile = true;
                }
            }
        }
        if(result != SQLITE_OK)
        {
            error = true;
            errorMsg = _sqliteClient->getErrorMsg();
        }
        
        if(error)
        {
            // can not open the db file, so exit.
            Debug::WriteFormatLine("Can not open the db file, reason: %s", errorMsg);
//            _exitFlag = true;
        }
    }
    
	void StorageService::closeDb()
	{
		if(_sqliteClient != NULL)
		{
			_sqliteClient->close();
			delete _sqliteClient;
			_sqliteClient = NULL;
		}
	}
    
#if DEBUG
    void StorageService::insertDebugData()
    {
		int result;
		char str[1024];
        
		// GradeInfo
		sprintf(str, "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s",
                "INSERT INTO [Plans] (Id,Name,Interval,CurrentTime) values(1,'plan1',1800,'2014-02-23 20:52:45');",
                "INSERT INTO [Plans] (Id,Name,Interval,CurrentTime) values(2,'plan2',3600,'2014-02-22 21:52:45');",
                "INSERT INTO [Plans] (Id,Name,Interval,CurrentTime) values(3,'plan3',4500,'2014-02-21 22:52:45');",
                "INSERT INTO [Plans] (Id,Name,Interval,CurrentTime) values(4,'plan4',1000,'2014-02-20 23:52:45');",
                "INSERT INTO [Plans] (Id,Name,Interval,CurrentTime) values(5,'plan5',6800,'2014-02-19 00:52:45');",
                "INSERT INTO [Plans] (Id,Name,Interval,CurrentTime) values(6,'plan6',5400,'2014-02-18 01:52:45');",
                "INSERT INTO [Plans] (Id,Name,Interval,CurrentTime) values(7,'plan7',1200,'2014-02-17 02:52:45');",
                "INSERT INTO [Plans] (Id,Name,Interval,CurrentTime) values(8,'plan8',9800,'2014-02-16 03:52:45');",
                "INSERT INTO [Plans] (Id,Name,Interval,CurrentTime) values(9,'plan9',6400,'2014-02-10 04:52:45');"
                );
		result = _sqliteClient->executeSql(str);
		if(result != SQLITE_OK)
		{
			const char* error = _sqliteClient->getErrorMsg();
            Debug::Write(error);
		}
    }
#endif
    
    void StorageService::selectPlans()
	{
#if DEBUG
		Stopwatch sw("StorageService::selectPlans", 100);
#endif
        
		Locker locker(&_plansMutex);
        
        openDb();
        
		string sql = "SELECT * FROM [Plans]";
        
		DataTable table;
		int result = _sqliteClient->executeSqlQuery(sql, table);
		if(result == SQLITE_OK)
		{
			_needUpdatePlans = false;
			_plans.clear();
            
			const DataRows* rows = table.getRows();
			for (uint i = 0; i < rows->count(); i++)
			{
				DataRow* row = rows->at(i);
				const DataCells* cells = row->getCells();
				Plan* plan = new Plan();
				for (uint j = 0; j < cells->count(); j++)
				{
					DataCell* cell = cells->at(j);
					if(cell->matchColumnName("Id"))
					{
						plan->Id = cell->getValue().nValue;
					}
					else if(cell->matchColumnName("Name"))
					{
						plan->Name = cell->getValue().strValue;
					}
					else if(cell->matchColumnName("Interval"))
					{
						plan->Interval = cell->getValue().nValue;
					}
					else if(cell->matchColumnName("CurrentTime"))
					{
						plan->CurrentTime = Convert::parseDateTime(cell->getValue().strValue);
					}
					else
					{
						assert(false);
					}
				}
                
				_plans.add(plan);
			}
		}
        else
        {
			const char* error = _sqliteClient->getErrorMsg();
            Debug::Write(error);
        }
        
        closeDb();
	}
    void StorageService::addPlan(const Plans& plans)
    {
#if DEBUG
		string mess = Convert::convertStr("StorageService::addPlans, count = %d", (int)plans.count());
		Stopwatch sw(mess, 100);
#endif
        
        Locker locker(&_plansMutex);
        
        openDb();
        
		DataTable table("Plans");
		table.addColumn(new DataColumn("Id", Integer));
		table.addColumn(new DataColumn("Name", String));
		table.addColumn(new DataColumn("Interval", Integer));
		table.addColumn(new DataColumn("CurrentTime", DateTime));
        
		const DataColumns* columns = table.getColumns();
		uint count = plans.count();
		for (uint i = 0; i < count; i++)
		{
			Plan* plan = plans.at(i);
            
			DataRow* row = new DataRow();
			row->addCell(new DataCell(columns->at(0), plan->Id));
			row->addCell(new DataCell(columns->at(1), plan->Name));
			row->addCell(new DataCell(columns->at(2), (int)plan->Interval));
			row->addCell(new DataCell(columns->at(3), plan->CurrentTime));
			table.addRow(row);
		}
        
		int result = _sqliteClient->executeSqlInsert(table);
		if(result == SQLITE_OK)
		{
			_needUpdatePlans = true;
		}
        else
        {
			const char* error = _sqliteClient->getErrorMsg();
            Debug::Write(error);
        }
        
        closeDb();
    }
    void StorageService::addPlan(const Plan& plan)
    {
        Plans plans(false);
        plans.add(&plan);
        addPlan(plans);
    }
    void StorageService::updatePlan(const Plan& plan)
    {
#if _DEBUG
		Stopwatch sw("StorageService::updatePlan", 100);
#endif
        Locker locker(&_plansMutex);
        
        openDb();

        char str[256];
        memset(str, 0, sizeof(str));
        
        string sql = "UPDATE [Plans] SET [Name]='%s',[Interval]=%d,[CurrentTime]='%s' where [Id]=%d";
        
        sprintf(str, sql.c_str(), plan.Name.c_str(), plan.Interval, Convert::getDateTimeStr(plan.CurrentTime).c_str(), plan.Id);
        
        int result = _sqliteClient->executeSql(str);
        if(result == SQLITE_OK)
        {
            _needUpdatePlans = true;
        }
        else
        {
			const char* error = _sqliteClient->getErrorMsg();
            Debug::Write(error);
        }
        
        closeDb();
    }
    void StorageService::deletePlan(const Plan& plan)
    {
#if DEBUG
		Stopwatch sw("StorageService::deletePlan", 100);
#endif
		Locker locker(&_plansMutex);
        
        openDb();
        
        char str[256];
        memset(str, 0, sizeof(str));
        
		string sql = "DELETE FROM [Plans] where Id=%d;";
        sprintf(str, sql.c_str(), plan.Id);
        
		int result = _sqliteClient->executeSql(str);
		if(result == SQLITE_OK)
		{
			_needUpdatePlans = true;
		}
        else
        {
			const char* error = _sqliteClient->getErrorMsg();
            Debug::Write(error);
        }
        
        closeDb();
    }
}

