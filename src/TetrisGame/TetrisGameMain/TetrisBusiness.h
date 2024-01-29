#ifndef TETRISBUSINESS_H
#define TETRISBUSINESS_H

#include <QObject>

class TetrisBusiness: public QObject
{
    Q_OBJECT
	
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
	Q_ENUMS(PageViewType)

    Q_INVOKABLE void HelloWorld();
};

#endif // TETRISBUSINESS_H
