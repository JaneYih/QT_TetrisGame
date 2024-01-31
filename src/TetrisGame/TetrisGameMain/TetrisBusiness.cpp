#include "TetrisBusiness.h"
#include <QDebug>
#include "ScoreHistoryModel.h"

TetrisBusiness::TetrisBusiness(QObject* parent)
	: QObject(parent)
	, m_hScoreHistoryModel(new ScoreHistoryModel(this))
{

}

TetrisBusiness::~TetrisBusiness()
{

}

void TetrisBusiness::HelloWorld()
{
	qDebug() << "Hello World!!";
	qDebug() << "Welcome to Tetris!!";
}

ScoreHistoryModel* TetrisBusiness::getScoreHistoryModel() const
{
	return m_hScoreHistoryModel;
}