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
	Q_INVOKABLE bool refreshScoreHistoryData(); //ˢ�����µķ�����
	Q_INVOKABLE bool insertScoreData(const QString& user, int score); //����һ������
	Q_INVOKABLE int getCurrentScore() const; //��ȡ��ǰ����
	Q_INVOKABLE int getHighestScore(); //��ȡ��ʷ��߷�

	Q_INVOKABLE void changeScoreHistoryData(); //���ڵ���
	ScoreHistoryModel* getScoreHistoryModel() const;

signals:
	
private:
	ScoreHistoryModel* m_hScoreHistoryModel;
	QString m_dbPath;
	int m_iCurrentScore;
};

#endif // TETRISBUSINESS_H
