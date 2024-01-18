import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.13

Window {
    id: mainWin
    visible: true
    width: gamePage.width
    height: gamePage.height
    title: "TetrisGameMain"

    GameView {
        id: gamePage
        x: 0
        y: 0
        //anchors.fill: parent
    }
}
