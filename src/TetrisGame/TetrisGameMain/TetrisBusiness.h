#ifndef TETRISBUSINESS_H
#define TETRISBUSINESS_H

#include <QObject>

class ScoreHistoryModel;
class TetrisBusiness: public QObject
{
	Q_OBJECT
	Q_ENUMS(PageViewType)

public:
    explicit TetrisBusiness(QObject* parent = nullptr);
    ~TetrisBusiness();

	enum PageViewType {
		HomeView = 0,
		GameView,
		ScoreView,
		SettingView,
		PageViewCount
	};

	Q_INVOKABLE void HelloWorld();
	Q_INVOKABLE bool refreshScoreHistoryData(); //刷新最新的分数数
	Q_INVOKABLE bool insertScoreData(const QString& user, int score); //插入一条分数
	Q_INVOKABLE int getCurrentScore() const; //获取当前分数
	Q_INVOKABLE int getHighestScore(); //获取历史最高分

	Q_INVOKABLE void changeScoreHistoryData(); //用于调试
	ScoreHistoryModel* getScoreHistoryModel() const;

signals:
	
private:
	ScoreHistoryModel* m_hScoreHistoryModel;
	QString m_dbPath;
	int m_iCurrentScore;
};

#endif // TETRISBUSINESS_H
