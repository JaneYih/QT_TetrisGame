#include "TetrisBusiness.h"
#include <QDebug>
#include "ScoreHistoryModel.h"
#include "ScoreHistoryTable.h"
#include <QDate>
#include <QMessageBox>
#include <QDir>
#include <QApplication>

const QString s_tetrisDbName = "Tetris.db";

TetrisBusiness::TetrisBusiness(QObject* parent)
	: QObject(parent)
	, m_iCurrentScore(0)
{
	m_dbPath = QApplication::applicationDirPath() + "/" + s_tetrisDbName;
    if (parent != nullptr) {
        m_hScoreHistoryModel = new ScoreHistoryModel();
        Q_ASSERT(m_hScoreHistoryModel);
		//insertScoreData(QString::fromStdWString(L"小米"), 456);
		//insertScoreData(QString::fromStdWString(L"小张"), 1000);
		//insertScoreData("Yih", 2000);
		//insertScoreData("Jane", 3210);
		refreshScoreHistoryData();
    }
}

TetrisBusiness::~TetrisBusiness()
{

}

bool TetrisBusiness::insertScoreData(const QString& user, int score)
{
	m_iCurrentScore = score;

	ScoreHistoryTable* pDb = new ScoreHistoryTable(m_dbPath);
	if (pDb)
	{
		DbData newData;
		pDbFieldGroup oneRowData = new DbFieldGroup();

		newData.fieldGroup.fields.push_back(ScoreHistoryTable::s_userDbKey);
		oneRowData->fields.push_back(user);

		newData.fieldGroup.fields.push_back(ScoreHistoryTable::s_timeDbKey);
		oneRowData->fields.push_back(QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss"));

		newData.fieldGroup.fields.push_back(ScoreHistoryTable::s_scoreDbKey);
		oneRowData->fields.push_back(QString("%1").arg(score));

		newData.rows.push_back(oneRowData);

		QString strErrorMsg;
		return pDb->InsertData(newData, strErrorMsg);
	}
	return false;
}

//查询并刷新历史分数表格内容
bool TetrisBusiness::refreshScoreHistoryData()
{
	ScoreHistoryTable* pDb = new ScoreHistoryTable(m_dbPath);
	if (pDb)
	{
		QString strErrorMsg;
		DataTable outputData;
		if (pDb->SelectData(outputData, strErrorMsg))
		{
			DbData data(outputData);
			for (auto item = data.fieldGroup.fields.begin(); item != data.fieldGroup.fields.end(); ++item)
			{
				auto name = pDb->dbKeyName(item->value());
				item->setValue(name);
			}
			m_hScoreHistoryModel->setScoreHistoryData(data);
			return true;
		}
	}
	return false;
}

int TetrisBusiness::getCurrentScore() const
{
	return m_iCurrentScore;
}

//获取历史最高分
int TetrisBusiness::getHighestScore()
{
	
	ScoreHistoryTable* pDb = new ScoreHistoryTable(m_dbPath);
	if (pDb)
	{
		QString strErrorMsg;
		int highestScore = 0;
		if (pDb->SelectHighestScore(highestScore, strErrorMsg))
		{
			return highestScore;
		}
	}
	return -9999;
}

void TetrisBusiness::HelloWorld()
{
	qDebug() << "Welcome to Tetris!!";

/*	DbData* data = new DbData;
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"用户")));
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"时间")));
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"分数")));
	//data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"--\r\n用户\r\n--------------")));
	//data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"--\r\n\r\n\r\n时间--")));
	//data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"--\r\n\r\n分数--")));
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
    m_hScoreHistoryModel->setScoreHistoryData(*data);*/
}

void TetrisBusiness::changeScoreHistoryData()
{
	DbData* data = new DbData;
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"--用户--")));
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"--时间--")));
	data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"--分数--")));
	//data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"--\r\n用户\r\n--------------")));
	//data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"--\r\n\r\n\r\n时间--")));
	//data->fieldGroup.fields.push_back(DbDataCell(QString::fromStdWString(L"--\r\n\r\n分数--")));
	pDbFieldGroup a = new DbFieldGroup;
	a->fields.push_back(DbDataCell("abc\r\nef\r\ng"));
	a->fields.push_back(DbDataCell(QDateTime::currentDateTime().toString("--yyyy-MM-dd hh:mm:ss--")));
	a->fields.push_back(DbDataCell("8888\r\n55555"));
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
	data->rows.push_back(a);
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

int TetrisBusiness::gameState() const
{
	return static_cast<int>(m_iCurrentGameState);
}

void TetrisBusiness::setGameState(int state)
{
	if (m_iCurrentGameState != state) {
		m_iCurrentGameState = static_cast<GameState>(state);
		emit gameStateChanged(state);
	}
}

int TetrisBusiness::gameLevel() const
{
	return static_cast<int>(m_eGameLevel);
}

void TetrisBusiness::setGameLevel(int level)
{
	if (m_eGameLevel != level) {
		m_eGameLevel = static_cast<GameLevel>(level);
		emit gameLevelChanged(level);
	}
}
