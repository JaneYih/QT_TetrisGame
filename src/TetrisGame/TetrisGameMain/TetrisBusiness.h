#ifndef TETRISBUSINESS_H
#define TETRISBUSINESS_H

#include <QObject>

class TetrisBusiness: public QObject
{
    Q_OBJECT

public:
    TetrisBusiness(QObject* parent = nullptr);
    ~TetrisBusiness();

};

#endif // TETRISBUSINESS_H
