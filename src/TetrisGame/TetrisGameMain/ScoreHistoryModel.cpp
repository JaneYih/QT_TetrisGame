#include "ScoreHistoryModel.h"


const QByteArray s_roleName_display("role_display");
const int s_roleIndex_scoreHistory = Qt::DisplayRole;

ScoreHistoryModel::ScoreHistoryModel(QObject *parent)
	: QAbstractTableModel(parent)
{
	m_roleNames.clear();
	m_roleNames.insert(s_roleIndex_scoreHistory, s_roleName_display);
}

ScoreHistoryModel::~ScoreHistoryModel()
{}

DbData ScoreHistoryModel::getScoreHistoryData() const
{
	return m_scoreHistoryData;
}

void ScoreHistoryModel::setScoreHistoryData(const DbData& data)
{
	int rowCount = data.rows.count() - 1;
	int columnCount = data.fieldGroup.fields.size() - 1;
	if (rowCount >= 0 && columnCount >= 0)
	{
		ClearScoreHistoryData();
		beginInsertRows(QModelIndex(), 0, rowCount);
		beginInsertColumns(QModelIndex(), 0, columnCount);
		m_scoreHistoryData = data;
		endInsertColumns();
		endInsertRows();
		emit dataUpdated();
	}
}

void ScoreHistoryModel::ClearScoreHistoryData()
{
	int rowCount = m_scoreHistoryData.rows.count() - 1;
	int columnCount = m_scoreHistoryData.fieldGroup.fields.size() - 1;
	if (rowCount >= 0)
	{
		beginRemoveRows(QModelIndex(), 0, rowCount);
		m_scoreHistoryData.rows.clear();
		endRemoveRows();
	}
	if (columnCount >= 0)
	{
		beginRemoveColumns(QModelIndex(), 0, columnCount);
		m_scoreHistoryData.fieldGroup.clear();
		endRemoveColumns();
	}
}

QModelIndex ScoreHistoryModel::index(int row, int column, const QModelIndex& parent) const
{
	if (row >= 0 && column >= 0 && row < m_scoreHistoryData.rows.size())
	{
		pDbFieldGroup pRowData = m_scoreHistoryData.rows[row];
		if (pRowData != nullptr
			&& column < pRowData->fields.size())
		{
			return createIndex(row, column, &m_scoreHistoryData.rows[row]->fields[column]);
		}
	}
	return QModelIndex();
}

int ScoreHistoryModel::rowCount(const QModelIndex& parent) const
{
	return m_scoreHistoryData.rows.count();
}

int ScoreHistoryModel::columnCount(const QModelIndex& parent) const
{
	return m_scoreHistoryData.fieldGroup.fields.count();
}

QString ScoreHistoryModel::GetHorizontalHeaderName(int section) const
{
	return headerData(section, Qt::Horizontal, s_roleIndex_scoreHistory).toString();
}

QString ScoreHistoryModel::GetVerticalHeaderName(int section) const
{
	return headerData(section, Qt::Vertical, s_roleIndex_scoreHistory).toString();
}

QVariant ScoreHistoryModel::headerData(int section, Qt::Orientation orientation, int role) const
{
	if (s_roleIndex_scoreHistory == role)
	{
		if (Qt::Horizontal == orientation)
		{
			if (section < m_scoreHistoryData.fieldGroup.fields.size())
			{
				return QVariant(QString::fromStdWString(L"%1").arg(m_scoreHistoryData.fieldGroup.fields[section].value()));
			}
		}
		else
		{
			return QVariant(QString("%1").arg(section + 1));
		}
	}	
	return QVariant();
}

QVariant ScoreHistoryModel::data(const QModelIndex& index, int role) const
{
	if (index.isValid())
	{
		if (s_roleIndex_scoreHistory == role)
		{
			const auto rowIndex = index.row();
			const auto columnIndex = index.column();
			if (rowIndex >= 0 && columnIndex >= 0)
			{
				return m_scoreHistoryData.rows[index.row()]->fields[index.column()].value();
			}
		}
	}
	return QVariant();
}

Qt::ItemFlags ScoreHistoryModel::flags(const QModelIndex& index) const
{
	return Qt::NoItemFlags;
	//return Qt::ItemIsSelectable | Qt::ItemIsEnabled;
}

QHash<int, QByteArray> ScoreHistoryModel::roleNames() const
{
	return m_roleNames;
}
