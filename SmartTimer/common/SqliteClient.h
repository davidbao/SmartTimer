#ifndef SQLITECLIENT_H
#define SQLITECLIENT_H

#include <stdio.h>
#include <sqlite3.h>
#include <mutex>
#include "../Common/Convert.h"
#include "../Common/Vector.h"
#include "DataTable.h"

namespace Storage
{
	class SqliteClient
	{
	public:
		SqliteClient(void);
		~SqliteClient(void);

		int open(const string& filename);
		int close();
		int executeSql(const string& sql);
		int executeSqlQuery(const string& sql, DataTable& table);
		int executeSqlInsert(const DataTable& table);
		const char* getErrorMsg();

	private:
		int execute(const string& sql);

		void printErrorInfo(const string& methodName, const string& sql);

	private:
		sqlite3* _sqliteDb;
		mutex _sqliteDbMutex;
	};
}
#endif // SQLITECLIENT_H