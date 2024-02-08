#include "SQLiteDatabase.h"
#include <QSqlDatabase>
#include <QSqlError>
#include <QDebug>
#include <QMessageBox>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlResult>


CSQLiteDatabase::CSQLiteDatabase(const QString& dbName, QObject *parent)
	: QObject(parent),
	m_strDataBaseName(dbName)
{
	m_InitErr = Init();
}

bool CSQLiteDatabase::IsInit()
{
	return !m_InitErr;
}

int CSQLiteDatabase::Init()
{
	QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
	db.setDatabaseName(m_strDataBaseName);
	if (!db.open())
	{
		QSqlError err = db.lastError();
		QString errMsg = tr("SQLite Database open  failure(%2): %1").arg(err.text()).arg(err.type());
		qDebug() << errMsg;
		//QMessageBox::critical(nullptr, tr("critical"), errMsg);

		return  static_cast<int>(err.type());
	}
	return 0;
}

int CSQLiteDatabase::UnInit()
{
	if (!m_InitErr)
	{
		QSqlDatabase db = QSqlDatabase::database();
		db.close();
		QSqlDatabase::removeDatabase(m_strDataBaseName);
	}
	return 0;
}

string CSQLiteDatabase::GetLastError()
{
	QSqlDatabase db = QSqlDatabase::database();
	return db.lastError().text().toStdString();
}

string CSQLiteDatabase::GetQueryLastError()
{
	return m_queryLastError.text().toStdString();
}

bool CSQLiteDatabase::IsExistTable(const char* TableName)
{
	QStringList tableList;
	tableList = QSqlDatabase::database().tables(QSql::Tables);
	for each (QString table in tableList)
	{
		if (table == QString(TableName))
		{
			return true;
		}
	}
	return false;
}

bool CSQLiteDatabase::GetTableFullFields(const char* TableName, FieldList& Fields)
{
	Fields.clear();
	QSqlQuery query(QSqlDatabase::database());
	QString strTableNmae(TableName);
	QString str = "PRAGMA table_info(" + strTableNmae + ")";
	query.prepare(str);
	if (query.exec())
	{
		while (query.next())
		{
			Fields.FieldListValue.push_back(query.value(1).toString().toStdString());
			//qDebug() << QString(QString::fromLocal8Bit("字段数:%1     字段名:%2     字段类型:%3")).arg(query.value(0).toString()).arg(query.value(1).toString()).arg(query.value(2).toString());
		}
		return true;
	}
	else 
	{
		qDebug() << query.lastError();
		return false;
	}
	return false;
}

int CSQLiteDatabase::ExcuteCommand(const char*  command)
{
	QSqlQuery query(QSqlDatabase::database());
	if (query.exec(QString(command)))
	{
		return 0;   //success
	}
	m_queryLastError = query.lastError();
	return -1;
}

int CSQLiteDatabase::GetResultData(const char*  command, DataTable& ResultData)
{
	QSqlQuery query(command);
	QSqlRecord record = query.record();
	int FieldCount = record.count();

	if (!query.isActive())
	{
		FieldCount = 0;
	}

	if (FieldCount)
	{
		//字段行
		ResultData.FieldName.FieldListValue.clear();
		for (int i = 0; i < FieldCount; i++)   //字段值
		{
			ResultData.FieldName.FieldListValue.push_back(record.fieldName(i).toStdString());
		}

		//数据表装载
		ResultData.RowList.clear();
		while (query.next())
		{
			FieldList RowValue;
			RowValue.FieldListValue.clear();
			for (int i = 0; i < FieldCount; i++)   //字段值
			{
				RowValue.FieldListValue.push_back(query.value(i).toString().toStdString());
			}
			ResultData.RowList.push_back(RowValue);
		}

		query.clear();
	}
	else
	{
		QSqlError err = QSqlDatabase::database().lastError();
		QString errMsg = tr("SQLite Database read failure(%2): %1").arg(err.text()).arg(err.type());
		qDebug() << errMsg;
		//QMessageBox::critical(nullptr, tr("critical"), errMsg);
		return -1;
	}

	return 0;
}

int CSQLiteDatabase::BeginTransaction()
{
	return QSqlDatabase::database().transaction() ? 0 : -1;
}

int CSQLiteDatabase::RollBackTransaction(const char* PointName)
{
	return QSqlDatabase::database().rollback() ? 0 : -1;
}

int CSQLiteDatabase::SetRollBackPoint(const char* PointName)
{
	return -1;
}

int CSQLiteDatabase::CommitTransaction()
{
	return QSqlDatabase::database().commit() ? 0 : -1;
}

int CSQLiteDatabase::CreateIndex(const char* TableName, const char* FieldName, const char* IndexName)
{
	QString command = QString("CREATE INDEX %1  ON %2(%3)").arg(QString(IndexName))
															.arg(QString(TableName))
															.arg(QString(FieldName));
	return ExcuteCommand(command.toStdString().c_str());
}

int CSQLiteDatabase::DeleteIndex(const char* TableName, const char* FieldName, const char* IndexName)
{
	QString command = QString("DROP INDEX %1  ON %2(%3)").arg(QString(IndexName))
		.arg(QString(TableName))
		.arg(QString(FieldName));
	return ExcuteCommand(command.toStdString().c_str());
}

int CSQLiteDatabase::ShowIndex(const char* TableName)
{
	return -1;
}
