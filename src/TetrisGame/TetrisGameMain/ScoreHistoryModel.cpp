#include "ScoreHistoryModel.h"

ScoreHistoryModel::ScoreHistoryModel(QObject *parent)
	: QAbstractTableModel(parent)
{}

ScoreHistoryModel::~ScoreHistoryModel()
{}

QModelIndex ScoreHistoryModel::index(int row, int column, const QModelIndex& parent) const
{
	return QModelIndex();
}

int ScoreHistoryModel::rowCount(const QModelIndex& parent) const
{
	return 5;
}

int ScoreHistoryModel::columnCount(const QModelIndex& parent) const
{
	return 5;
}

QVariant ScoreHistoryModel::headerData(int section, Qt::Orientation orientation, int role) const
{
	return QVariant();
}

QVariant ScoreHistoryModel::data(const QModelIndex& index, int role) const
{
	return QVariant();
}

Qt::ItemFlags ScoreHistoryModel::flags(const QModelIndex& index) const
{
	return	Qt::NoItemFlags;
}

QHash<int, QByteArray> ScoreHistoryModel::roleNames() const
{
	return QHash<int, QByteArray>();
}