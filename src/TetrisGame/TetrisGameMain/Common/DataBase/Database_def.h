#pragma once

#include <QString>
#include <QVector>
#include <QList>
#include <QDebug>
#include "DatabaseBaseClass.h"

typedef enum
{
	//eMYSQL,
	//eORACLE,
	eSQLITE,
	//ePostgreSQL,
	//eMSSQL,
}SqlTypes;

typedef struct _SqlBaseInfo_
{
	SqlTypes type = SqlTypes::eSQLITE;
	QString host;
	QString user;
	QString passwd;
	QString dbName;
	QString port;

    _SqlBaseInfo_(SqlTypes _type,
                  const QString& _host,
                  const QString& _user,
                  const QString& _passwd,
                  const QString& _dbName,
                  const QString& _port)
        : type(_type)
        , host(_host)
        , user(_user)
        , passwd(_passwd)
        , dbName(_dbName)
        , port(_port)
    {

    }

	QString toString()
	{
		return QString::fromStdWString(L"IP地址:%1;端口:%2;用户名:%3;数据库名:%4;")
			.arg(host).arg(port).arg(user).arg(dbName);
	}
}SqlBaseInfo, *pSqlBaseInfo;

typedef struct _SqlTableInfo_
{
	SqlBaseInfo baseInfo;
	QString tableName;

    /*_SqlTableInfo_(const SqlBaseInfo& info, const QString& tabName = "")
        : baseInfo(info)
        , tableName(tabName)
    {

    }*/

	QString toString()
	{
		return QString::fromStdWString(L"%1表名:%2;")
			.arg(baseInfo.toString()).arg(tableName);
	}
}SqlTableInfo, * pSqlTableInfo;

typedef enum _DbDataCellOperate_
{
	DbDataCell_NOP,
	DbDataCell_Insert,
	DbDataCell_Delete,
	DbDataCell_Update,
}DbDataCellOperate;

typedef struct _DbDataCell_
{
private:
	DbDataCellOperate eOperate;
	QString strValue;

public:
	_DbDataCell_(const QString& value) {
		init();
		strValue = value;
	}

	_DbDataCell_(){
		init();
	}
	void init()
	{
		eOperate = DbDataCellOperate::DbDataCell_NOP;
		strValue = "";
	}
	QString value() const {
		return strValue;
	}
	void setValue(const QString& value){
		strValue = value;
	}
	bool isWaitingOperate() {
		return eOperate != DbDataCellOperate::DbDataCell_NOP;
	}
	void setUnOperate() {
		eOperate = DbDataCellOperate::DbDataCell_NOP;
	}
	bool isWaitingUpdate() const{
		return DbDataCellOperate::DbDataCell_Update == eOperate;
	}
	void setWaitingUpdate(){
		eOperate = DbDataCellOperate::DbDataCell_Update;
	}
	bool isWaitingDelete() const {
		return DbDataCellOperate::DbDataCell_Delete == eOperate;
	}
	void setWaitingDelete() {
		eOperate = DbDataCellOperate::DbDataCell_Delete;
	}
	bool isWaitingInsert() const {
		return DbDataCellOperate::DbDataCell_Insert == eOperate;
	}
	void setWaitingInsert() {
		eOperate = DbDataCellOperate::DbDataCell_Insert;
	}
}DbDataCell, * pDbDataCell;

typedef struct _DbFieldGroup_
{
	QVector<DbDataCell> fields;

	_DbFieldGroup_()
	{
		clear();
	}
	~_DbFieldGroup_()
	{
		clear();
	}
	_DbFieldGroup_(const _DbFieldGroup_& src)
	{
		this->copy(src);
	}
	_DbFieldGroup_& operator=(const _DbFieldGroup_& src)
	{
		if (this == &src)
		{
			return *this;
		}
		this->copy(src);
		return *this;
	}
	void copy(const _DbFieldGroup_& src)
	{
		this->clear();
		for each (auto var in src.fields)
		{
			this->fields.push_back(var);
		}
	}
	_DbFieldGroup_(const FieldList& src)
	{
		*this = src;
	}
	_DbFieldGroup_& operator=(const FieldList& src)
	{
		this->clear();
		foreach (std::string var, src.FieldListValue)
		{
			DbDataCell cell;
			cell.setValue(QString::fromStdString(var));
			this->fields.push_back(cell);
		}
		return *this;
	}
	void clear()
	{
		this->fields.clear();
	}
}DbFieldGroup, * pDbFieldGroup;

typedef struct _DbData_
{
	DbFieldGroup fieldGroup;
	QList<pDbFieldGroup> rows;

	_DbData_()
	{
		clear();
	}
	~_DbData_()
	{
		clear();
	}
	_DbData_(const _DbData_& src)
	{
		this->copy(src);
	}
	_DbData_& operator=(const _DbData_& src)
	{
		if (this == &src)
		{
			return *this;
		}
		this->copy(src);
		return *this;
	}
	void copy(const _DbData_& src)
	{
		this->clear();
		this->fieldGroup = src.fieldGroup;
		foreach(pDbFieldGroup var, src.rows)
		{
			this->rows.push_back(new DbFieldGroup(*var));
		}
	}
	_DbData_(const DataTable& src)
	{
		*this = src;
	}
	_DbData_& operator=(const DataTable& src)
	{
		this->clear();
		this->fieldGroup = src.FieldName;
		foreach (FieldList var, src.RowList)
		{
			this->rows.push_back(new DbFieldGroup(var));
		}
		return *this;
	}
	void clear()
	{
		this->fieldGroup.fields.clear();
		for each (auto var in rows)
		{
			delete var;
			var = nullptr;
		}
		this->rows.clear();
	}
}DbData, * pDbData;
