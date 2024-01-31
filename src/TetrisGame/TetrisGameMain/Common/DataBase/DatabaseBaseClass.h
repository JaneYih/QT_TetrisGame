#pragma  once

#include <windows.h>
#include <iostream>
#include <string.h>
#include <vector>
#include <list>
using namespace std;

typedef struct _FieldList_
{
	vector<std::string> FieldListValue;
	void clear()
	{
		FieldListValue.clear();
	}
}FieldList, * pFieldList;

typedef struct _DataTable_
{
	FieldList FieldName;
	vector<FieldList> RowList;
	void clear()
	{
		FieldName.clear();
		RowList.clear();
	}
}DataTable, * pDataTable;

class IDatabase
{
public:
	IDatabase(){}
	virtual ~IDatabase(){}

public:
	virtual bool IsInit() = 0;    //初始化完成
	virtual int Init() = 0;    //初始化
	virtual int UnInit() = 0;  //反初始化

	virtual int ExcuteCommand(const char*  command) = 0;
	virtual int GetResultData(const char*  command, DataTable& ResultData) = 0;

	virtual int BeginTransaction() = 0;
	virtual int RollBackTransaction(const char* PointName) = 0;
	virtual int SetRollBackPoint(const char* PointName) = 0;
	virtual int CommitTransaction() = 0;

	virtual int CreateIndex(const char* TableName, const char* FieldName, const char* IndexName) = 0;
	virtual int DeleteIndex(const char* TableName, const char* FieldName, const char* IndexName) = 0;
	virtual int ShowIndex(const char* TableName) = 0;

	virtual bool IsExistTable(const char* TableName) = 0;
	virtual bool GetTableFullFields(const char* TableName, FieldList& Fields) = 0;
	virtual std::string GetLastError() = 0;
	virtual std::string GetQueryLastError(){
		return "";
	}
};
