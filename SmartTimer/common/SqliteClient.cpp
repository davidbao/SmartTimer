#include "../Common/Stopwatch.h"
#include "../Common/Locker.h"
#include "SqliteClient.h"

using namespace Common;

namespace Storage
{
	SqliteClient::SqliteClient(void) : _sqliteDb(NULL)
	{
	}

	SqliteClient::~SqliteClient(void)
	{
		if(_sqliteDb != NULL)
		{
			close();
		}
	}

	int SqliteClient::open(const string& filename)
	{
		Locker locker(&_sqliteDbMutex);

		int result = sqlite3_open(filename.c_str(), &_sqliteDb);
		if(result == SQLITE_OK)
		{
			// http://blog.quibb.org/2010/08/fast-bulk-inserts-into-sqlite/

			//int result;
			//DataTable table;
			//const int length = 8;
			//string names[length] = {"PRAGMA synchronous", "PRAGMA count_changes", "PRAGMA journal_mode",
			//	"PRAGMA temp_store", "PRAGMA locking_mode", "PRAGMA fullfsync", "PRAGMA read_uncommitted", "PRAGMA recursive_triggers"};
			//for (int i = 0; i < length; i++)
			//{
			//	table.clear();
			//	result = executeSqlQuery(names[i].c_str(), table);
			//	if(result == SQLITE_OK && table.getRows()->count() > 0)
			//	{
			//		Debug::WriteFormatLine("PRAGMA %s = %d", table.getColumns()->at(0)->getName().c_str(), table.getRows()->at(0)->getCells()->at(0)->getValue().nValue);
			//	}
			//}

			//executeSql("PRAGMA synchronous=OFF");
			//executeSql("PRAGMA count_changes=OFF");
			//executeSql("PRAGMA journal_mode=MEMORY");
			//executeSql("PRAGMA temp_store=MEMORY");
		}
		return result;
	}

	int SqliteClient::close()
	{
		Locker locker(&_sqliteDbMutex);

		int result = sqlite3_close(_sqliteDb);
		_sqliteDb = NULL;
		return result;
	}

	int SqliteClient::executeSql(const string& sql)
	{
		Locker locker(&_sqliteDbMutex);

		int result;
		result = execute("BEGIN TRANSACTION");
		if(result != SQLITE_OK)
		{
			return result;
		}
		result = execute(sql);
		if(result != SQLITE_OK)
		{
			return result;
		}
		result = execute("COMMIT TRANSACTION");
		if(result != SQLITE_OK)
		{
			return result;
		}
		return SQLITE_OK;
	}

	int SqliteClient::executeSqlQuery(const string& sql, DataTable& table)
	{
		Locker locker(&_sqliteDbMutex);

#if DEBUG
		Stopwatch sw("executeSqlQuery", 100);
#endif
		sqlite3_stmt *stmt;
		int result = sqlite3_prepare_v2(_sqliteDb, sql.c_str(),  sql.length(), &stmt, 0);  
		if(result != SQLITE_OK)
		{
			printErrorInfo("sqlite3_prepare_v2", sql);
			return result;
		}

		//const char* name = sqlite3_column_table_name(stmt, 0);
		//table.setName(name != NULL ? name : "temp");
        // todo: linke error for sqlite3_column_table_name.
        table.setName("temp");

#if DEBUG
		sw.setInfo(Convert::convertStr("executeSqlQuery, the table name is '%s'", table.getName().c_str()));
#endif

		int columnCount = sqlite3_column_count(stmt);
		for (int i = 0; i < columnCount; i++)
		{
			char* nameStr = (char*)sqlite3_column_name(stmt, i);
			string name;
			if(nameStr != NULL)
			{
				name = nameStr;
			}
			else
			{
				char temp[32];
				sprintf(temp, "tempCol%d", i);
				name = temp;
			}
			const char* typeStr = sqlite3_column_decltype(stmt, i);
			string type = typeStr != NULL ? typeStr : "int";
			DataColumn* column = new DataColumn(name, type);
			table.addColumn(column);
		}

		while(sqlite3_step(stmt) == SQLITE_ROW)
		{
			DataRow* row = new DataRow();
			for (int i = 0; i < columnCount; i++)
			{
				DataColumn* column = table.getColumns()->at(i);
				DataCell* cell = NULL;
				Value value;
				memset(&value, 0, sizeof(value));
				ValueTypes type = column->getType();
				switch (type)
				{
				case Null:
					break;
				case Integer:
					value.nValue = sqlite3_column_int(stmt, i);
					break;
				case String:
				case DateTime:
					{
						char* str = (char*)sqlite3_column_text(stmt, i);
						DataCell::setStringValue(value, str);
					}
					break;
				case Float:
					value.dValue = sqlite3_column_double(stmt, i);
					break;
				default:
					assert(false);
					break;
				}

				cell = new DataCell(column, value);
				row->addCell(cell);
			}
			table.addRow(row);
		}
		result = sqlite3_finalize(stmt);
		if(result != SQLITE_OK)
		{
			printErrorInfo("sqlite3_finalize", sql);
			return result;
		}

		return SQLITE_OK;
	}

	int SqliteClient::executeSqlInsert(const DataTable& table)
	{
		Locker locker(&_sqliteDbMutex);

		if(table.getName().empty())
			return -1;
		if(table.columnCount() == 0)
			return -2;
		if(table.rowCount() == 0)
			return -3;

		// such like '"INSERT INTO example VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)";'
		string valuesStr = "";
		int columnCount = table.columnCount();
		for (int i = 0; i < columnCount; i++)
		{
			if(i != 0)
			{
				valuesStr += ", ";
			}
			valuesStr += Convert::convertStr("?%d", i + 1);
		}
		string sql = Convert::convertStr("INSERT INTO [%s] VALUES (%s)", table.getName().c_str(), valuesStr.c_str());
		sqlite3_stmt *stmt;
		int result = sqlite3_prepare_v2(_sqliteDb, sql.c_str(),  sql.length(), &stmt, 0);  
		if(result != SQLITE_OK)
		{
			printErrorInfo("sqlite3_prepare_v2", sql);
			return result;
		}

		result = execute("BEGIN TRANSACTION");
		if(result != SQLITE_OK)
		{
			return result;
		}
		int rowCount = table.rowCount();
		for (int i = 0; i < rowCount; i++)
		{
			const DataRow* row = table.getRows()->at(i);
			for (int j = 0; j < columnCount; j++)
			{
				const DataCell* cell = row->getCells()->at(j);
				if(cell != NULL)
				{
					ValueTypes type = cell->getType();
					const Value value = cell->getValue();
					switch (type)
					{
					case Null:
						sqlite3_bind_null(stmt, j + 1);
						break;
					case Integer:
						sqlite3_bind_int(stmt, j + 1, value.nValue);
						break;
					case DateTime:
					case String:
						result = sqlite3_bind_text(stmt, j + 1, value.strValue, strlen(value.strValue), SQLITE_TRANSIENT);
						break;
					case Float:
						sqlite3_bind_double(stmt, j + 1, value.dValue);
						break;
					default:
						assert(false);
						break;
					}
				}
			}

			result = sqlite3_step(stmt);
			if (result != SQLITE_DONE)
			{
				printErrorInfo("sqlite3_step", sql);
			}

			result = sqlite3_reset(stmt);
			if(result != SQLITE_OK)
			{
				printErrorInfo("sqlite3_reset", sql);
			}
		}

		result = execute("COMMIT TRANSACTION");
		if(result != SQLITE_OK)
		{
			return result;
		}
		sqlite3_finalize(stmt);
		if(result != SQLITE_OK)
		{
			printErrorInfo("sqlite3_finalize", sql);
			return result;
		}

		return SQLITE_OK;
	}

	const char* SqliteClient::getErrorMsg()
	{
		return _sqliteDb != NULL ? sqlite3_errmsg(_sqliteDb) : NULL;
	}

	int SqliteClient::execute(const string& sql)
	{
		int result = sqlite3_exec(_sqliteDb, sql.c_str(), NULL, NULL, NULL);
		if(result != SQLITE_OK)
		{
			printErrorInfo("sqlite3_exec", sql);
		}
		return result;
	}

	void SqliteClient::printErrorInfo(const string& methodName, const string& sql)
	{
#if DEBUG
		Debug::WriteFormatLine("%s error, msg: %s, sql: %s", methodName.c_str(), getErrorMsg(), sql.c_str());
#endif
	}
}
