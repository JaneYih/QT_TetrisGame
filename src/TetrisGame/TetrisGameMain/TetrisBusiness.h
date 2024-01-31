#ifndef TETRISBUSINESS_H
#define TETRISBUSINESS_H

#include <QObject>

class ScoreHistoryModel;
class TetrisBusiness: public QObject
{
	Q_OBJECT
	Q_ENUMS(PageViewType)
	Q_PROPERTY(ScoreHistoryModel* scoreHistoryModel READ getScoreHistoryModel NOTIFY scoreHistoryModelChanged)

public:
    TetrisBusiness(QObject* parent = nullptr);
    ~TetrisBusiness();

	enum PageViewType {
		HomeView = 0,
		GameView,
		ScoreView,
		SettingView,
		PageViewCount
	};

	Q_INVOKABLE void HelloWorld();

	ScoreHistoryModel* getScoreHistoryModel() const;

signals:
	void scoreHistoryModelChanged();

private:
	ScoreHistoryModel* m_hScoreHistoryModel;
};

#endif // TETRISBUSINESS_H
