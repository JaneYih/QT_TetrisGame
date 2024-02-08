#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQml>
#include "TetrisBusiness.h"
#include "ScoreHistoryModel.h"

QObject* qobject_singletonBusiness_provider(QQmlEngine* engine, QJSEngine* scriptEngine)
{
	Q_UNUSED(engine);
	Q_UNUSED(scriptEngine);
    return new TetrisBusiness(nullptr);
}

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    //注册单例类型-业务逻辑类
    qmlRegisterSingletonType<TetrisBusiness>("Yih.Tetris.Business", 1, 0, "TetrisBusiness", qobject_singletonBusiness_provider); 

	QQmlApplicationEngine engine;
    TetrisBusiness business(engine.rootContext());
    engine.rootContext()->setContextProperty("scoreHistoryModelInstance", business.getScoreHistoryModel());
    engine.rootContext()->setContextProperty("businessInstance", &business);

    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/tetrisgamemain/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}

