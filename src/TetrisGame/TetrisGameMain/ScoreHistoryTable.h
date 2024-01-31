#pragma once

#include "ITableManage.h"

class ScoreHistoryTable :public ITableManage
{
public:
	ScoreHistoryTable(const QString& db) :ITableManage(SqlBaseInfo({ SqlTypes::eSQLITE, "localhost", "root", "root", db, "3306" }))
	{
		CreateTable();
	}

	virtual ~ScoreHistoryTable()
	{
	}

public:
	virtual bool CreateTable(); 
	virtual bool InsertData(const vector<string>& para);
	virtual bool DeleteData(const vector<string>& para);
	virtual bool SelectData(const vector<string>& para, DataTable& outputData);
};