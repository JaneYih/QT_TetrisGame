#include "TetrisBusiness.h"
#include <QDebug>
#include "ScoreHistoryModel.h"
#include <QDate>

TetrisBusiness::TetrisBusiness(QObject* parent)
	: QObject(parent)
	, m_hScoreHistoryModel(new ScoreHistoryModel())
{
	Q_ASSERT(m_hScoreHistoryModel);

	DbData* data = new DbData;
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"�û�")));
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"ʱ��")));
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"����")));
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

TetrisBusiness::~TetrisBusiness()
{

}

void TetrisBusiness::HelloWorld()
{
	qDebug() << "Welcome to Tetris!!";
}

ScoreHistoryModel* TetrisBusiness::getScoreHistoryModel() const
{
	return m_hScoreHistoryModel;
}
