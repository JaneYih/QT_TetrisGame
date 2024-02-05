#include "ScoreHistoryTable.h"

static const char TableName[] = "scoreHistory";

//表结构：用户，时间，分数
static const char _createSql[] = "CREATE TABLE  scoreHistory\
					  			(USER_NAME varchar(20) NOT NULL,\
								OPERATOR_ID varchar(20) NOT NULL,\
								PASSWORD varchar(20) NOT NULL,\
								PRIMARY KEY (USER_NAME)\
								)";

static const char _selectSql[] = "SELECT USER_NAME,OPERATOR_ID,PASSWORD \
								 FROM scoreHistory \
								 LIMIT 60;";

static const char _select1Sql[] = "SELECT USER_NAME,OPERATOR_ID,PASSWORD \
								  FROM scoreHistory \
								  WHERE USER_NAME = \"%s\" \
								  LIMIT 60;";

static const char _updataSql[] = "UPDATE scoreHistory\
								 SET PASSWORD = \"%s\" \
								 WHERE USER_NAME = \"%s\";";

static const char _insertSql[] = "INSERT INTO scoreHistory(USER_NAME,OPERATOR_ID,PASSWORD)\
								 VALUES(\"%s\",\"%s\",\"%s\");";

static const char _deleteSql[] = "DELETE FROM scoreHistory \
								  WHERE USER_NAME = \"%s\";";



bool ScoreHistoryTable::CreateTable()  //建表
{
	if (!DatabaseInstence->IsInit())
	{
		return false;
	}
	
	if (IsExistTable(TableName))
	{
		return true; 
	}

	int res = 0;
	res |= DatabaseInstence->BeginTransaction();
	res |= DatabaseInstence->ExcuteCommand(_createSql);
	res |= DatabaseInstence->CreateIndex(TableName, "USER_NAME", "scoreHistory_Index1");
	res |= DatabaseInstence->CreateIndex(TableName, "OPERATOR_ID", "scoreHistory_Index2");

	if (res)
	{
		DatabaseInstence->RollBackTransaction(NULL);
	}
	res |= DatabaseInstence->CommitTransaction();
	
	//插入初始用户列表
	InsertData({ "Engineer", "Engineer", "123456" });
	InsertData({ "FQC", "FQC", "123456" });
	InsertData({ "PRD", "PRD", "" });

	return !res;
}

bool ScoreHistoryTable::InsertData(const vector<string>& para) //增
{
	if (!DatabaseInstence->IsInit())
	{
		return false;
	}

	int res = 0;
	char command[5120] = { 0 };
	if (para.size() >= 3)
	{
		sprintf_s(command, _insertSql, para[0].c_str(), para[1].c_str(), para[2].c_str());
	}
	else
	{
		return false;
	}

	res |= DatabaseInstence->BeginTransaction();
	res |= DatabaseInstence->ExcuteCommand(command);
	res |= DatabaseInstence->CommitTransaction();

	return !res;
}

bool ScoreHistoryTable::SelectData(const vector<string>& para, DataTable& outputData) //查
{
	if (!DatabaseInstence->IsInit())
	{
		return false;
	}

	int res = 0;
	char command[1024] = { 0 };
	res |= DatabaseInstence->BeginTransaction();

	if (para.size() >= 1)
	{
		sprintf_s(command, _select1Sql, para[0].c_str());
	}
	else
	{
		strcpy(command, _selectSql);
	}
	
	if (!DatabaseInstence->GetResultData(command, outputData))
	{
		res |= DatabaseInstence->CommitTransaction();
	}
	else
	{
		DatabaseInstence->RollBackTransaction(NULL);
		DatabaseInstence->CommitTransaction();
		return false;
	}

	return !res;
}

bool ScoreHistoryTable::DeleteData(const vector<string>& para) //删
{
	if (!DatabaseInstence->IsInit())
	{
		return false;
	}

	int res = 0;
	char command[1024] = { 0 };
	if (para.size() >= 1)
	{
		sprintf_s(command, _deleteSql, para[0].c_str());
	}
	else
	{
		return false;
	}

	res |= DatabaseInstence->BeginTransaction();
	res |= DatabaseInstence->ExcuteCommand(command);
	res |= DatabaseInstence->CommitTransaction();

	return !res;
}
