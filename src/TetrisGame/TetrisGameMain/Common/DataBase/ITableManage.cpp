#include "ITableManage.h"

bool ITableManage::IsExistTable(const char* TableName)
{
	if (DatabaseInstence->IsExistTable(TableName))
	{
		return true;    //数据表已存在
	}
	return false;
}

bool ITableManage::AnalysisPara(list<string> para, const int paraNum, string Sqlpara[])
{
	if (para.size() != paraNum) 
	{
		return false;
	}

	list<string>::iterator iter = para.begin();
	for (int index = 0; index < paraNum; index++)
	{
		Sqlpara[index] = *(iter++);
	}

	return true;
}

bool ITableManage::TestConnect(string& errMsg)
{
	if (DatabaseInstence)
	{
		if (!DatabaseInstence->IsInit())
		{
			errMsg = DatabaseInstence->GetLastError();
			return false;
		}
		return true;
	}
	errMsg = "DatabaseInstence is null.";
	return false;
}

bool ITableManage::GetTableFullFields(const char* TableName, FieldList& Fields)
{
	if (DatabaseInstence)
	{
		if (!DatabaseInstence->GetTableFullFields(TableName, Fields))
		{
			string errMsg = DatabaseInstence->GetLastError();
			return false;
		}
		return true;
	}
	return false;
}

bool ITableManage::CreateTable()
{
	return false;
}

bool ITableManage::InsertData(vector<string> para)
{
	return false;
}

bool ITableManage::DeleteData(vector<string> para)
{
	return false;
}

bool ITableManage::UpdateData(vector<string> para)
{
	return false;
}

bool ITableManage::SelectData(vector<string> para, DataTable& outputData)
{
	return false;
}