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
	Q_INVOKABLE void changeScoreHistoryData();
	ScoreHistoryModel* getScoreHistoryModel() const;

signals:
	

private:
	ScoreHistoryModel* m_hScoreHistoryModel;
};

#endif // TETRISBUSINESS_H
