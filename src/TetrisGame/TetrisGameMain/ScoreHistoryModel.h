#pragma once

#include <QObject>
#include <QHash>
#include <QAbstractTableModel>
#include "Database_def.h"

class ScoreHistoryModel  : public QAbstractTableModel
{
	Q_OBJECT

public:
	ScoreHistoryModel(QObject* parent = nullptr);
	~ScoreHistoryModel();

	DbData getScoreHistoryData() const;
	void setScoreHistoryData(const DbData& data);
	Q_INVOKABLE QString GetHorizontalHeaderName(int section) const;

protected:
	virtual QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const override;
	virtual int rowCount(const QModelIndex& parent = QModelIndex()) const override;
	virtual int columnCount(const QModelIndex& parent = QModelIndex()) const override;
	virtual QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
	virtual QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
	virtual Qt::ItemFlags flags(const QModelIndex& index) const override;
	virtual QHash<int, QByteArray> roleNames() const;

signals:
	void dataUpdated(); //数据更新信号，用于qml表格内容布局刷新

private:
	void ClearScoreHistoryData();

private:
	QHash<int, QByteArray> m_roleNames;
	mutable DbData m_scoreHistoryData;

};
