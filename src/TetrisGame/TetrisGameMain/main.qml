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

    BoxGroup {
        x: 26
        y: 32
        groupType: BoxGroup.BoxShape.Shape_I
    }
    BoxGroup {
        x: 127
        y: 19
        groupType: BoxGroup.BoxShape.Shape_O
    }

    BoxGroup {
        x: 215
        y: 9
        groupType: BoxGroup.BoxShape.Shape_L
    }

    BoxGroup {
        x: 290
        y: 19
        groupType: BoxGroup.BoxShape.Shape_S
    }

    BoxGroup {
        x: 396
        y: 19
        groupType: BoxGroup.BoxShape.Shape_Z
    }

    BoxGroup {
        x: 531
        y: 9
        groupType: BoxGroup.BoxShape.Shape_J
    }

    BoxGroup {
        x: 26
        y: 119
        groupType: BoxGroup.BoxShape.Shape_T
    }

    BoxGroup {
        id: randomBoxGroup
        x: 147
        y: 109
        groupType: BoxGroup.BoxShape.Shape_Random
    }

    Timer{
        id: randTimer
        interval: 500
        running: true
        repeat: true
        property bool flag: false
        onTriggered: {
            flag = !flag;
            randomBoxGroup.groupType = BoxGroup.BoxShape.Shape_Random;
            randomBoxGroup.x += flag ? -50 : 50;
        }
    }
}
