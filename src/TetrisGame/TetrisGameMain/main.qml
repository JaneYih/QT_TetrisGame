import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    property string oneboxQml: "OneBox.qml"

    visible: true
    width: 640
    height: 480
    title: "TetrisGameMain"
    color: "#8aece3"
    Text {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.bold: true
        font.pointSize: 42
        text: "Tetris"
        anchors.leftMargin: 376
        anchors.topMargin: 9
        anchors.rightMargin: 0
        anchors.bottomMargin: 259
    }

    OneBox{
        x: 146
        y: 180
        edgeLength: 20
    }

    OneBox{
        x: 167
        y: 180
        edgeLength: 20
    }

    OneBox {
        x: 188
        y: 180
        edgeLength: 20
    }

    OneBox {
        x: 167
        y: 201
        edgeLength: 20
        boxGradient: null
    }

    OneBox {
        x: 293
        y: 201
        edgeLength: 20
        lightOff: true
    }

    OneBox {
        x: 146
        y: 282
        edgeLength: 20
        lightOff: true
    }

    OneBox {
        x: 167
        y: 282
        edgeLength: 20
        lightOff: true
    }


}
