#include "ScoreHistoryTable.h"

const QString ScoreHistoryTable::s_timeDbKey = "time"; //时间
const QString ScoreHistoryTable::s_userDbKey = "user"; //用户名
const QString ScoreHistoryTable::s_scoreDbKey = "score"; //分数


ScoreHistoryTable::ScoreHistoryTable(const QString& db)
    : ITableManage(SqlBaseInfo(SqlTypes::eSQLITE, "localhost", "root", "root", db, "3306"))
{
    m_tableName = "ScoreHistory";
    m_dbKeyNameMap.clear();
    m_dbKeyNameMap[s_timeDbKey] = QString::fromStdWString(L"时间");
    m_dbKeyNameMap[s_userDbKey] = QString::fromStdWString(L"用户");
    m_dbKeyNameMap[s_scoreDbKey] = QString::fromStdWString(L"分数");
    CreateTable();
}

ScoreHistoryTable::~ScoreHistoryTable()
{

}

QString ScoreHistoryTable::dbKeyName(const QString& key) {
	if (m_dbKeyNameMap.find(key) != m_dbKeyNameMap.end())
	{
		return m_dbKeyNameMap[key];
	}
	return key;
}

bool ScoreHistoryTable::CreateTable()
{
    //<表结构>：自增序号，时间，用户名，分数
    QString createCommand = QString("CREATE TABLE %1(\
ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,\
%2 TEXT NOT NULL,\
%3 varchar(60) NOT NULL,\
%4 INTEGER NOT NULL);")
.arg(m_tableName)
.arg(s_timeDbKey)
.arg(s_userDbKey)
.arg(s_scoreDbKey);

    if (!DatabaseInstence->IsInit())
    {
        return false;
    }

    QByteArray byteTableName = m_tableName.toLocal8Bit();
    if (IsExistTable(byteTableName))
    {
        return true;
    }

    int res = 0;
    res |= DatabaseInstence->BeginTransaction();
    res |= DatabaseInstence->ExcuteCommand(createCommand.toLocal8Bit());
    res |= DatabaseInstence->CreateIndex(byteTableName, s_timeDbKey.toLocal8Bit(), QString("%1__Index").arg(s_timeDbKey).toLocal8Bit());
    res |= DatabaseInstence->CreateIndex(byteTableName, s_userDbKey.toLocal8Bit(), QString("%1__Index").arg(s_userDbKey).toLocal8Bit());
    res |= DatabaseInstence->CreateIndex(byteTableName, s_scoreDbKey.toLocal8Bit(), QString("%1__Index").arg(s_scoreDbKey).toLocal8Bit());

    if (res)
    {
        DatabaseInstence->RollBackTransaction(NULL);
    }
    res |= DatabaseInstence->CommitTransaction();

    return !res;
}

bool ScoreHistoryTable::TestConnect(QString& strErrorMsg)
{
    DbFieldGroup Fields;
    return GetTableFullFields(Fields, strErrorMsg);
}

bool ScoreHistoryTable::CheckConnect(QString& strErrorMsg)
{
    if (!DatabaseInstence->IsInit())
    {
        strErrorMsg = QString::fromStdWString(L"数据库未连接");
        return false;
    }
    return true;
}

//获取字段列表
bool ScoreHistoryTable::GetTableFullFields(DbFieldGroup& outFields, QString& strErrorMsg)
{
    if (!CheckConnect(strErrorMsg))
    {
        return false;
    }

    outFields.clear();

    QByteArray byteTableName = m_tableName.toLocal8Bit();
    if (DatabaseInstence->IsExistTable(byteTableName))
    {
        FieldList Fields;
        DatabaseInstence->GetTableFullFields(byteTableName, Fields);
        outFields = Fields;
        return outFields.fields.size() > 0;
    }
    strErrorMsg = QString::fromStdWString(L"数据库表(%1)不存在").arg(m_tableName);
    return false;
}

bool ScoreHistoryTable::InsertData(const DbData& data, QString& strErrorMsg)
{
    return ExcuteDataOperateCommand(&ScoreHistoryTable::CreateInsertDataCommand, data, strErrorMsg);
}

bool ScoreHistoryTable::DeleteData(const DbData& data, QString& strErrorMsg)
{
    return ExcuteDataOperateCommand(&ScoreHistoryTable::CreateDeleteDataCommand, data, strErrorMsg);
}

bool ScoreHistoryTable::DeleteDataByTimeLimit(unsigned saveDays, QString& strErrorMsg)
{
    const QString deleteSql = QString("DELETE FROM %1 \
WHERE date(%2) <= date(\'now\', \'-%3 day\');")
.arg(m_tableName)
.arg(s_timeDbKey)
.arg(saveDays);

    return ExcuteDataOperateCommand(deleteSql, strErrorMsg);
}

bool ScoreHistoryTable::UpdateData(const DbData& data, QString& strErrorMsg)
{
    return ExcuteDataOperateCommand(&ScoreHistoryTable::CreateUpdateDataCommand, data, strErrorMsg);
}

bool ScoreHistoryTable::SelectData(DataTable& outputData, QString& strErrorMsg)
{
    return ExcuteDataSelectCommand(CreateSelectDataCommand(s_timeDbKey, Qt::DescendingOrder), outputData, strErrorMsg);
}

bool ScoreHistoryTable::SelectHighestScore(int& highestScore, QString& strErrorMsg)
{
    DataTable outputData;
	if (ExcuteDataSelectCommand(QString("SELECT %1 FROM %2 order by %1 desc LIMIT 1;")
		    .arg(s_scoreDbKey).arg(m_tableName).toLocal8Bit(), outputData, strErrorMsg))
    {
        if (outputData.RowList.size() == 1)
        {
            highestScore = QString::fromStdString(outputData.RowList.at(0).FieldListValue.at(0)).toInt();
        }
        return true;
    }
	return false;
}

QString ScoreHistoryTable::CreateInsertDataCommand(const DbFieldGroup& fields, const DbFieldGroup& values)
{
    QString strFields;
    foreach(auto var, fields.fields)
    {
        strFields += QString("%1,").arg(var.value());
    }
    strFields = strFields.mid(0, strFields.length() - 1);

    QString strValues;
    foreach(auto cell, values.fields)
    {
        strValues += QString("\'%1\',").arg(cell.value());
    }
    strValues = strValues.mid(0, strValues.length() - 1);

    return QString::fromLocal8Bit("insert into %1 (%2) values (%3);").arg(m_tableName).arg(strFields).arg(strValues);
}

QString ScoreHistoryTable::CreateDeleteDataCommand(const DbFieldGroup& fields, const DbFieldGroup& values)
{
    int fieldsCount = fields.fields.count();
    int valuesCount = values.fields.count();
    if (fieldsCount != valuesCount)
    {
        return "";
    }

    QString strPredicate;
    for (int i = 0; i < valuesCount; ++i)
    {
        strPredicate += QString("%1 = \'%2\' and ")
            .arg(fields.fields[i].value())
            .arg(values.fields[i].value());
    }
    strPredicate = strPredicate.mid(0, strPredicate.length() - 5);
    return QString("delete from %1 where %2;").arg(m_tableName).arg(strPredicate);
}

QString ScoreHistoryTable::CreateUpdateDataCommand(const DbFieldGroup& fields, const DbFieldGroup& values)
{
    int fieldsCount = fields.fields.count();
    int valuesCount = values.fields.count();
    if (fieldsCount != valuesCount)
    {
        return "";
    }

    QString strPredicate;
    QString strValues;
    for (int i = 0; i < valuesCount; ++i)
    {
        DbDataCell cell = values.fields[i];
        DbDataCell field = fields.fields[i];
        if (cell.isWaitingUpdate())
        {
            strValues += QString("%1 = \'%2\',")
                .arg(field.value())
                .arg(cell.value());
        }
        else
        {
            strPredicate += QString("%1 = \'%2\' and ")
                .arg(field.value())
                .arg(cell.value());
        }
    }
    strValues = strValues.mid(0, strValues.length() - 1);
    strPredicate = strPredicate.mid(0, strPredicate.length() - 5);

    return QString("update %1 set %2 where %3;").arg(m_tableName)
        .arg(strValues).arg(strPredicate);
}

bool ScoreHistoryTable::ExcuteDataOperateCommand(const CreateCommandFunc createCommand, const DbData& data, QString& strErrorMsg)
{
    if (!CheckConnect(strErrorMsg))
    {
        return false;
    }

    int res = DatabaseInstence->BeginTransaction();
    if (0 == res)
    {
        foreach(auto row, data.rows)
        {
            if (row)
            {
                QString command((this->*createCommand)(data.fieldGroup, *row));
                res = DatabaseInstence->ExcuteCommand(command.toLocal8Bit());
                if (0 != res)
                {
                    res = DatabaseInstence->RollBackTransaction(nullptr);
                    strErrorMsg = QString::fromStdWString(L"命令：%1\r\n错误：%2").arg(command)
                                    .arg(QString::fromStdString(DatabaseInstence->GetQueryLastError()));
                    return false;
                }
            }
        }
        if (DatabaseInstence->CommitTransaction() != 0)
        {
            strErrorMsg = QString::fromStdString(DatabaseInstence->GetLastError());
            return false;
        }
        return true;
    }
    strErrorMsg = QString::fromStdString(DatabaseInstence->GetLastError());
    return false;
}

bool ScoreHistoryTable::ExcuteDataOperateCommand(const QString& cmd, QString& strErrorMsg)
{
    if (!CheckConnect(strErrorMsg))
    {
        return false;
    }

    int res = DatabaseInstence->BeginTransaction();
    if (0 == res)
    {
        res = DatabaseInstence->ExcuteCommand(cmd.toLocal8Bit());
        if (0 != res)
        {
            res = DatabaseInstence->RollBackTransaction(nullptr);
            strErrorMsg = QString::fromStdWString(L"命令：%1\r\n错误：%2").arg(cmd)
                .arg(QString::fromStdString(DatabaseInstence->GetQueryLastError()));
            return false;
        }
        if (DatabaseInstence->CommitTransaction() != 0)
        {
            strErrorMsg = QString::fromStdString(DatabaseInstence->GetLastError());
            return false;
        }
        return true;
    }
    strErrorMsg = QString::fromStdString(DatabaseInstence->GetLastError());
    return false;
}

QString ScoreHistoryTable::CreateSelectDataCommand(const DbFieldGroup& fields, const DbFieldGroup& values)
{
    int fieldsCount = fields.fields.count();
    int valuesCount = values.fields.count();
    if (fieldsCount != valuesCount)
    {
        return "";
    }

    QString strPredicate;
    for (int i = 0; i < valuesCount; ++i)
    {
        strPredicate += QString("%1 = \'%2\' and ")
            .arg(fields.fields[i].value())
            .arg(values.fields[i].value());
    }
    strPredicate = strPredicate.mid(0, strPredicate.length() - 5);
    return QString("SELECT * FROM %1 WHERE %2 LIMIT 1;").arg(m_tableName).arg(strPredicate);
}

//获取最新的100条数据
QString ScoreHistoryTable::CreateSelectDataCommand(const QString& orderByField, Qt::SortOrder order)
{
    QString strOrderBy("");
    if (!orderByField.isEmpty())
    {
        QString strSortOrder;
        if (order == Qt::SortOrder::DescendingOrder)
        {
            strSortOrder = "desc";
        }
        else
        {
            strSortOrder = "asc";
        }
        strOrderBy = QString("order by %1 %2").arg(orderByField).arg(strSortOrder); //"order by xxx desc"
    }
    return QString("SELECT %1,%2,%3 FROM %4 %5 LIMIT 100;")
        .arg(s_userDbKey).arg(s_scoreDbKey).arg(s_timeDbKey)
        .arg(m_tableName).arg(strOrderBy).toLocal8Bit();
}

bool ScoreHistoryTable::ExcuteDataSelectCommand(const QString& cmd, DataTable& outputData, QString& strErrorMsg)
{
    if (!DatabaseInstence->IsInit())
    {
        strErrorMsg = QString::fromStdString(DatabaseInstence->GetLastError());
        return false;
    }

    int res = DatabaseInstence->BeginTransaction();
    if (0 == res)
    {
        if (!DatabaseInstence->GetResultData(cmd.toLocal8Bit(), outputData))
        {
            res |= DatabaseInstence->CommitTransaction();
        }
        else
        {
            res |= DatabaseInstence->RollBackTransaction(NULL);
            res |= DatabaseInstence->CommitTransaction();
        }
    }

    if (res != 0)
    {
        strErrorMsg = QString::fromStdString(DatabaseInstence->GetLastError());
        return false;
    }
    return true;
}
