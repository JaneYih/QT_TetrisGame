#pragma once
#include "DatabaseBaseClass.h"
#include "DatabaseFactory.h"
#include <stdio.h>
#include <vector>
using namespace std;

class ITableManage
{
public:
	ITableManage(const SqlBaseInfo& info)
	{
		DatabaseInstence = CDatabaseFactory::CreatDatabase(info);
	}

	virtual ~ITableManage()
	{
		delete DatabaseInstence;
	}

public:
	virtual bool TestConnect(string& errMsg);
	virtual bool IsExistTable(const char* TableName);
	virtual bool GetTableFullFields(const char* TableName, FieldList& Fields);
	virtual bool CreateTable();
	virtual bool InsertData(vector<string> para);
	virtual bool DeleteData(vector<string> para);
	virtual bool UpdateData(vector<string> para);
	virtual bool SelectData(vector<string> para, DataTable& outputData);

protected:
	IDatabase* DatabaseInstence;
	bool AnalysisPara(list<string> para, const int paraNum, string Sqlpara[]);
};
