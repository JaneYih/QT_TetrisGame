#pragma once

#include "ITableManage.h"

class CDataTableTest :public ITableManage
{
public:
	explicit CDataTableTest(const SqlBaseInfo& info) 
		:ITableManage(info)
	{
		CreateTable();
	}

	virtual ~CDataTableTest()
	{
	}

public:
	virtual bool CreateTable(); 
	virtual bool InsertData(vector<string> para); 
	virtual bool DeleteData(vector<string> para); 
	virtual bool UpdateData(vector<string> para); 
	virtual bool SelectData(vector<string> para, DataTable& outputData);  
};