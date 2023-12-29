import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.13

Window {
    //property string oneboxQml: "OneBox.qml"

    id: mainWin
    visible: true
    width: 640
    height: 480
    title: "TetrisGameMain"
    color: "#8aece3"
    property int oneBoxEdgeLength: 20 //小方块边长
    property Component oneboxComponent: null
    property var backgroundArray: null

    Component.onCompleted: {
        createBoxBackground(20, 10);
    }

    OneBox{
        x: 259
        y: 149
        z: 2
    }

    OneBox{
        id: testBox
        x: 278
        y: 150
        z: 2
    }

    OneBox {
        x: 298
        y: 150
        z: 2
    }

    OneBox {
        x: 278
        y: 170
        z: 2
        boxGradient: null
    }

    OneBox {
        x: 293
        y: 201
        z: 2
        lightOff: true
    }

    OneBox {
        x: oneBoxEdgeLength * 1
        y: oneBoxEdgeLength * 15
        z: 2
        lightOff: true
    }

    OneBox {
        x: oneBoxEdgeLength * 2
        y: oneBoxEdgeLength * 15
        z: 2
        lightOff: true
    }

    Button {
        id: button
        x: 358
        y: 244
        z: 2
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
        z: 2
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
        z: 2
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
        z: 2
        width: 58
        height: 26
        text: qsTr("上")
        onClicked: {
            testBox.moveUp(1);
        }
    }

    BoxGroup {
        x: oneBoxEdgeLength * 2
        y: oneBoxEdgeLength * 2
        z: 2
        groupType: BoxGroup.BoxShape.Shape_I
    }
    BoxGroup {
        x: oneBoxEdgeLength * 2
        y: oneBoxEdgeLength * 4
        z: 2
        groupType: BoxGroup.BoxShape.Shape_O
    }

    BoxGroup {
        x: 215
        y: 9
        z: 2
        groupType: BoxGroup.BoxShape.Shape_L
    }

    BoxGroup {
        x: 290
        y: 19
        z: 2
        groupType: BoxGroup.BoxShape.Shape_S
    }

    BoxGroup {
        x: 396
        y: 19
        z: 2
        groupType: BoxGroup.BoxShape.Shape_Z
    }

    BoxGroup {
        id: lll
        x: oneBoxEdgeLength * 5
        y: oneBoxEdgeLength * 14
        z: 2
        groupType: BoxGroup.BoxShape.Shape_J
    }

    BoxGroup {
        x: oneBoxEdgeLength * 2
        y: oneBoxEdgeLength * 8
        z: 2
        groupType: BoxGroup.BoxShape.Shape_T
    }

    BoxGroup {
        id: randomBoxGroup
        x: oneBoxEdgeLength * 7
        y: oneBoxEdgeLength * 5
        z: 2
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
            randomBoxGroup.x += flag ? -oneBoxEdgeLength : oneBoxEdgeLength;
        }
    }

    Button {
        id: button4
        x: 450
        y: 129
        z: 2
        text: qsTr("旋转")
        onClicked: {
            lll.moveRotate();
        }
    }


    function createBoxBackground(row, col){
        var TopX = 0;
        var TopY = 0;
        if (oneboxComponent === null){
            oneboxComponent = Qt.createComponent("OneBox.qml");
        }

        if (mainWin.backgroundArray === null){
            mainWin.backgroundArray = new Array;
        }

        for (var i = 0; i < row; i++){
            var rowArray = new Array;
            for (var j = 0; j < col; j++){
                if (oneboxComponent.status === Component.Ready){
                    var box = oneboxComponent.createObject(mainWin, {x: 0,y: 0});
                    box.x = TopX + j*mainWin.oneBoxEdgeLength;
                    box.y = TopY + i*mainWin.oneBoxEdgeLength;
                    box.edgeLength = mainWin.oneBoxEdgeLength;
                    box.lightOff = true;
                    box.z = 1;
                    box.opacity = 0.3;
                    //console.log("box: %1,%2".arg(box.x).arg(box.y));
                    rowArray.push(box);
                }
                else {
                    console.log("oneboxComponent ERROR");
                    return false;
                }
            }
            mainWin.backgroundArray.push(rowArray);
        }

        return true;
    }
}
