#ifndef TETRISBUSINESS_H
#define TETRISBUSINESS_H

#include <QObject>

class ScoreHistoryModel;
class TetrisBusiness: public QObject
{
	Q_OBJECT
	Q_ENUMS(PageViewType)
	Q_ENUMS(GameLevel)
	Q_ENUMS(GameState)
	Q_PROPERTY(int gameState READ gameState WRITE setGameState NOTIFY gameStateChanged)
	Q_PROPERTY(int gameLevel READ gameLevel WRITE setGameLevel NOTIFY gameLevelChanged)

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

	enum GameState {
		Ready = 0,
		Start,
		Running,
		Pause,
		Over
	};

	enum GameLevel {
		Simple = 0, //简单
		Normal, //普通
		Hard, //困难
	};

	Q_INVOKABLE void HelloWorld();
	Q_INVOKABLE bool refreshScoreHistoryData(); //刷新最新的分数数
	Q_INVOKABLE bool insertScoreData(const QString& user, int score); //插入一条分数
	Q_INVOKABLE int getCurrentScore() const; //获取当前分数
	Q_INVOKABLE int getHighestScore(); //获取历史最高分
	Q_INVOKABLE void changeScoreHistoryData(); //用于调试
	ScoreHistoryModel* getScoreHistoryModel() const;

	int gameState() const;
	void setGameState(int state);
	int gameLevel() const;
	void setGameLevel(int level);

signals:
	void gameStateChanged(int state);
	void gameLevelChanged(int level);

private:
	ScoreHistoryModel* m_hScoreHistoryModel;
	QString m_dbPath;
	int m_iCurrentScore;
	GameState m_iCurrentGameState;
	GameLevel m_eGameLevel;
};

#endif // TETRISBUSINESS_H
