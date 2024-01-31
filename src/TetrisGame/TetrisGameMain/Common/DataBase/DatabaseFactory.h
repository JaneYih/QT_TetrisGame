#pragma once

#include "DatabaseBaseClass.h"
#include "Database_def.h"
//#include "MysqlDatabase.h"
#include "SQLiteDatabase.h"

class CDatabaseFactory
{
public:
	CDatabaseFactory(){}
	~CDatabaseFactory(){}

public:
	static IDatabase* CreatDatabase(const SqlBaseInfo& info)
	{
		switch (info.type)
		{
		//case eMYSQL:
		//	return new CMysqlDatabase(info.host.toStdString(), info.user.toStdString(),
		//		info.passwd.toStdString(), info.dbName.toStdString(), info.port.toInt());
		case eSQLITE:
			return new CSQLiteDatabase(info.dbName);
		default:
			return nullptr;
		}
	}
};