#pragma once

#include "ITableManage.h"
#include "Database_def.h"
#include <QMap>

class ScoreHistoryTable;
typedef QString(ScoreHistoryTable::* CreateCommandFunc)(const DbFieldGroup&, const DbFieldGroup&);
class ScoreHistoryTable : public ITableManage
{
public:
    explicit ScoreHistoryTable(const QString& db);
    virtual ~ScoreHistoryTable();

public:
    bool TestConnect(QString& strErrorMsg);
    bool CheckConnect(QString& strErrorMsg);
    bool GetTableFullFields(DbFieldGroup& Fields, QString& strErrorMsg);
    bool InsertData(const DbData& data, QString& strErrorMsg);
    bool DeleteDataByTimeLimit(unsigned saveDays, QString& strErrorMsg);
    bool DeleteData(const DbData& data, QString& strErrorMsg);
    bool UpdateData(const DbData& data, QString& strErrorMsg);
    bool SelectData(DataTable& outputData, QString& strErrorMsg);
    bool SelectHighestScore(int& highestScore, QString& strErrorMsg);
    bool SelectUserLastScore(const QString& user, int& lastScore, QString& strErrorMsg);
    QString dbKeyName(const QString& key);

private:
    virtual bool CreateTable() override;
    bool GetTableFullData(DbData& outData, QString& strErrorMsg, const QString& orderByField = "", Qt::SortOrder order = Qt::AscendingOrder);
    QString CreateInsertDataCommand(const DbFieldGroup& fields, const DbFieldGroup& values);
    QString CreateDeleteDataCommand(const DbFieldGroup& fields, const DbFieldGroup& values);
    QString CreateUpdateDataCommand(const DbFieldGroup& fields, const DbFieldGroup& values);
    QString CreateSelectDataCommand(const DbFieldGroup& fields, const DbFieldGroup& values);
    QString CreateSelectDataCommand(const QString& orderByField, Qt::SortOrder order);
    bool ExcuteDataOperateCommand(const CreateCommandFunc createCommand, const DbData& data, QString& strErrorMsg);
    bool ExcuteDataOperateCommand(const QString& cmd, QString& strErrorMsg);
    bool ExcuteDataSelectCommand(const QString& cmd, DataTable& outputData, QString& strErrorMsg);

private:
    QString m_tableName;
    QMap<QString, QString> m_dbKeyNameMap;

public:
	static const QString s_timeDbKey;
    static const QString s_userDbKey;
    static const QString s_scoreDbKey;
};


