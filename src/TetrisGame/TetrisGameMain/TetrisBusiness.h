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
	Q_INVOKABLE bool refreshScoreHistoryData();
	Q_INVOKABLE bool InsertScoreData(const QString& user, int score);

	Q_INVOKABLE void changeScoreHistoryData(); //���ڵ���
	ScoreHistoryModel* getScoreHistoryModel() const;

signals:
	

private:
	ScoreHistoryModel* m_hScoreHistoryModel;
	QString m_dbPath;
};

#endif // TETRISBUSINESS_H
