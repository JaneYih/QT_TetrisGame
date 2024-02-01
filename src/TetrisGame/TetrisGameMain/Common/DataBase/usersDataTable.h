#pragma once

#include "ITableManage.h"

class CUsersDataTable :public ITableManage
{
public:
    CUsersDataTable(const QString& db)
        :ITableManage(SqlBaseInfo(SqlTypes::eSQLITE, "localhost", "root", "root", db, "3306"))
	{
		CreateTable();
	}

	virtual ~CUsersDataTable()
	{
	}

public:
	virtual bool CreateTable(); 
	virtual bool InsertData(const vector<string>& para);
	virtual bool DeleteData(const vector<string>& para);
	virtual bool UpdateData(const vector<string>& para);
	virtual bool SelectData(const vector<string>& para, DataTable& outputData);
};
