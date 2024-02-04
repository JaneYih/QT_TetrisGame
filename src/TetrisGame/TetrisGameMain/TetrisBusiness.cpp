#include "TetrisBusiness.h"
#include <QDebug>
#include "ScoreHistoryModel.h"
#include <QDate>

TetrisBusiness::TetrisBusiness(QObject* parent)
	: QObject(parent)
	, m_hScoreHistoryModel(new ScoreHistoryModel())
{
	Q_ASSERT(m_hScoreHistoryModel);
}

TetrisBusiness::~TetrisBusiness()
{

}

void TetrisBusiness::HelloWorld()
{
	qDebug() << "Welcome to Tetris!!";

	DbData* data = new DbData;
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"用户")));
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"时\r\n间-------------------------------AAAA")));
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"分\r\n\r\n数\r\n\r\n")));
	pDbFieldGroup a = new DbFieldGroup;
	a->fields.push_back(DbDataCell("xiaoming"));
	a->fields.push_back(DbDataCell(QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss")));
	a->fields.push_back(DbDataCell("9999"));
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	m_hScoreHistoryModel->setScoreHistoryData(*data);
}

void TetrisBusiness::changeScoreHistoryData()
{
	DbData* data = new DbData;
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"用\r\nQQ\r\nQ户")));
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"时间")));
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"分数")));
	pDbFieldGroup a = new DbFieldGroup;
	a->fields.push_back(DbDataCell("abcdefg"));
	a->fields.push_back(DbDataCell(QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss")));
	a->fields.push_back(DbDataCell("66\r\n66\r\n6"));
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	m_hScoreHistoryModel->setScoreHistoryData(*data);
}

ScoreHistoryModel* TetrisBusiness::getScoreHistoryModel() const
{
	return m_hScoreHistoryModel;
}
