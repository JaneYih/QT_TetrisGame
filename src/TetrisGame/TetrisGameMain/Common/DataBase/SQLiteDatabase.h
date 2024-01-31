#ifndef SQLISTDB_H
#define SQLISTDB_H

#include <QObject>
#include <QSqlError>
#include "DatabaseBaseClass.h"

class CSQLiteDatabase : public QObject, public IDatabase
{
	Q_OBJECT
public:
	explicit CSQLiteDatabase(const QString& dbName, QObject *parent = nullptr);
	virtual ~CSQLiteDatabase() { UnInit(); }

private:
	int m_InitErr;
	QString m_strDataBaseName;
	QSqlError m_queryLastError;

public:
	virtual bool IsInit();
	virtual int Init();
	virtual int UnInit();
	virtual std::string GetLastError();
	virtual std::string GetQueryLastError();
	virtual int ExcuteCommand(const char*  command);
	virtual int GetResultData(const char*  command, DataTable& ResultData);
	virtual int BeginTransaction();
	virtual int RollBackTransaction(const char* PointName);
	virtual int SetRollBackPoint(const char* PointName);
	virtual int CommitTransaction();
	virtual int CreateIndex(const char* TableName, const char* FieldName, const char* IndexName);
	virtual int DeleteIndex(const char* TableName, const char* FieldName, const char* IndexName);
	virtual int ShowIndex(const char* TableName);
	virtual bool IsExistTable(const char* TableName);
	virtual bool GetTableFullFields(const char* TableName, FieldList& Fields);

	

signals:

public slots:

};

#endif 
