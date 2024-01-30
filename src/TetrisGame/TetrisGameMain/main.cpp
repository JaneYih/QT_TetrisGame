#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQml>
#include "TetrisBusiness.h"
#include "ScoreHistoryModel.h"

QObject* qobject_singletonBusiness_provider(QQmlEngine* engine, QJSEngine* scriptEngine);

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);
    //ע�ᵥ������-ҵ���߼���
    qmlRegisterSingletonType<TetrisBusiness>("Yih.Tetris.Business", 1, 0, "TetrisBusiness", qobject_singletonBusiness_provider);
    qmlRegisterType<ScoreHistoryModel>("Yih.Tetris.ScoreHistoryModel", 1, 0, "ScoreHistoryModel");

    QQmlApplicationEngine engine;

    //Ϊ���������������: "businessInstance" ����ֵΪ��TetrisBusiness busApp
    //TetrisBusiness busApp;
    //engine.rootContext()->setContextProperty("businessInstance", &busApp);

    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/tetrisgamemain/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}

QObject* qobject_singletonBusiness_provider(QQmlEngine* engine, QJSEngine* scriptEngine)
{
	Q_UNUSED(engine);
	Q_UNUSED(scriptEngine);
	return new TetrisBusiness();
}
