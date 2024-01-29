#include "TetrisBusiness.h"
#include <QDebug>

TetrisBusiness::TetrisBusiness(QObject* parent)
	: QObject(parent)
{

}

TetrisBusiness::~TetrisBusiness()
{

}

void TetrisBusiness::HelloWorld()
{
	qDebug() << "Hello World!!";
	qDebug() << "Welcome to Tetris!!";
}
