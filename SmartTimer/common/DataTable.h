#ifndef DATATABLE_H
#define DATATABLE_H

#include <sqlite3.h>
#include <assert.h>

using namespace Common;

namespace Storage
{
	union Value
	{
		char* strValue;
		int nValue;
		double dValue;
		bool bValue;
	};

	enum ValueTypes
	{
		Null = SQLITE_NULL,
		Integer = SQLITE_INTEGER,
		String = SQLITE3_TEXT,
		Float = SQLITE_FLOAT,
		Blob = SQLITE_BLOB,
		DateTime = 6,
	};

	class DataColumn
	{
	public:
		DataColumn(const string& name, const string& type)
		{
			_name = name;
			_type = convertType(type);
		}
		DataColumn(const string& name, const ValueTypes& type)
		{
			_name = name;
			_type = type;
		}
		~DataColumn(){}

		inline ValueTypes getType() const
		{
			return _type;
		}

		inline int isInteger() const
		{
			return (_type == Integer);
		}

		inline int isDateTime() const
		{
			return (_type == DateTime);
		}

		inline int isString() const
		{
			return (_type == String);
		}

		inline const string& getName() const
		{
			return _name;
		}

	private:
		inline ValueTypes convertType(const string& type)
		{
			ValueTypes valueType = Null;
			if(type.find("int") != string::npos)
			{
				valueType = Integer;
			}
			else if(type.find("char") != string::npos ||
				type.find("varchar") != string::npos ||
				type.find("nvarchar") != string::npos)
			{
				valueType = String;
			}
			else if(type.find("datetime") != string::npos)
			{
				valueType = DateTime;
			}
			else if(type.find("float") != string::npos)
			{
				valueType = Float;
			}
			else
			{
			}
			return valueType;
		}

	protected:
		string _name;
		ValueTypes _type;
	};

	typedef Vector<DataColumn> DataColumns;

	class DataCell
	{
	public:
		DataCell(const DataColumn* column)
		{
			_column = column;
		}
		DataCell(const DataColumn* column, Value str)
		{
			_column = column;
			_value = str;
		}
		DataCell(const DataColumn* column, int str)
		{
			_column = column;
			_value.nValue = str;
		}
		DataCell(const DataColumn* column, uint str)
		{
			_column = column;
			_value.nValue = str;
		}
		DataCell(const DataColumn* column, double str)
		{
			_column = column;
			_value.dValue = str;
		}
		DataCell(const DataColumn* column, const char* str)
		{
			_column = column;
			setStringValue(str);
		}
		DataCell(const DataColumn* column, const string& str)
		{
			_column = column;
			setStringValue(str.c_str());
		}
		DataCell(const DataColumn* column, const time_t timep)
		{
			_column = column;
			setStringValue(Convert::getDateTimeStr(timep).c_str());
		}
		~DataCell()
		{
			ValueTypes type = getType();
			if(type == String ||
				type == DateTime)
			{
				assert(_value.strValue);
				delete[] _value.strValue;
				_value.strValue = NULL;
			}
			_column = NULL;
		}

		inline ValueTypes getType() const
		{
			return _column != NULL ? _column->getType() : Null;
		}

		inline const Value& getValue() const
		{
			return _value;
		}

		inline bool matchColumnName(const char* columnName) const
		{
			return (_column != NULL && columnName != NULL) ? _column->getName().compare(columnName) == 0 : false;
		}

		static void setStringValue(Value& value, const char* str)
		{
			if(str != NULL)
			{
				value.strValue = new char[strlen(str) + 1];
				strcpy(value.strValue, str);
			}
			else
			{
				value.strValue = new char[1];
				value.strValue[0] = '\0';
			}
		}

	private:
		inline void setStringValue(const char* str)
		{
			setStringValue(_value, str);
		}

	private:
		Value _value;
		const DataColumn* _column;
	};

	typedef Vector<DataCell> DataCells;

	class DataRow
	{
	public:
		DataRow(){}
		~DataRow(){}

		inline void addCell(const DataCell* cell)
		{
			_cells.add(cell);
		}

		inline const DataCells* getCells() const
		{
			return &_cells;
		}

	private:
		DataCells _cells;
	};

	typedef Vector<DataRow> DataRows;

	class DataTable
	{
	public:
		DataTable()
		{
			_name = "";
		}
		DataTable(const string& name)
		{
			setName(name);
		}
		~DataTable()
		{
			clear();
		}

		inline string getName() const
		{
			return _name;
		}

		inline void setName(const string& name)
		{
			_name = name;
		}

		inline void addRow(const DataRow* row)
		{
			_rows.add(row);
		}
		inline const DataRows* getRows() const
		{
			return &_rows;
		}
		inline int rowCount() const
		{
			return (int)_rows.count();
		}

		inline void addColumn(const DataColumn* column)
		{
			_columns.add(column);
		}
		inline const DataColumns* getColumns() const
		{
			return &_columns;
		}

		inline int columnCount() const
		{
			return (int)_columns.count();
		}

		inline void clear()
		{
			_name = "";
			_rows.clear();
			_columns.clear();
		}

	private:
		string _name;
		DataRows _rows;
		DataColumns _columns;
	};
}
#endif // DATATABLE_H