import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.13

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
        x: 147
        y: 180
    }

    OneBox{
        id: testBox
        x: 167
        y: 180
    }

    OneBox {
        x: 187
        y: 180
    }

    OneBox {
        x: 167
        y: 200
        boxGradient: null
    }

    OneBox {
        x: 293
        y: 201
        lightOff: true
    }

    OneBox {
        x: 146
        y: 282
        lightOff: true
    }

    OneBox {
        x: 166
        y: 282
        lightOff: true
    }

    Button {
        id: button
        x: 358
        y: 244
        width: 58
        height: 33
        text: qsTr(" 左")
        onClicked: {
            testBox.moveLeft(1);
        }
    }

    Button {
        id: button1
        x: 531
        y: 244
        width: 75
        height: 33
        text: qsTr("右")
        onClicked: {
            testBox.moveRight(1);
        }
    }

    Button {
        id: button2
        x: 442
        y: 244
        width: 62
        height: 33
        text: qsTr("下")
        onClicked: {
            testBox.moveDown(1);
        }
    }


    Button {
        id: button3
        x: 442
        y: 192
        width: 58
        height: 26
        text: qsTr("上")
        onClicked: {
            testBox.moveUp(1);
        }
    }
}
