import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.13

Window {
    id: mainWin
    visible: true
    width: 640
    height: 640
    title: "TetrisGameMain"
    color: "#8aece3"
    property int oneBoxEdge: 20 //小方块边长
    property Component oneboxComponent: null
    property var backgroundArray: null //游戏区域背景方块二维数组
    property int gameAreaX: 40 //游戏区域x
    property int gameAreaY: 60 //游戏区域y
    property int gameAreaRowSize: 20 //游戏区域行数
    property int gameAreaColSize: 25 //游戏区域列数
    property var gameAreaRect: null //游戏区域矩形
    property var curActiveBoxGroup: null //当前活动的方块组--唯一性，如果同时有多个活动方块自动下落，则背景不能多个同时点亮

    Component.onCompleted: {
        createBoxBackground(gameAreaRowSize, gameAreaColSize);
        ///curActiveBoxGroup = ttt;
    }

    /* 将游戏区域的背景方块点亮--槽函数*/
    Connections {
        target: curActiveBoxGroup
        onBackgroundBoxsLightUp: {
            //console.log("onBackgroundBoxsLightUp");
            var originRow = (curActiveBoxGroup.y - gameAreaY) / oneBoxEdge;
            var originCol = (curActiveBoxGroup.x - gameAreaX) / oneBoxEdge;
            //console.log("%1   %2".arg(originRow).arg(originCol));
            for (var i in curActiveBoxGroup.boxArray){
                var row = originRow + curActiveBoxGroup.boxArray[i].row;
                var col = originCol + curActiveBoxGroup.boxArray[i].col;
                backgroundArray[row][col].lightOff = false;
            }
            curActiveBoxGroup.destroy(); //销毁当前方块组（目前不是动态创建方块组的，后面要动态创建方块组即可）
        }
    }

    MouseArea {
        id: mousearea
        anchors.fill: parent
        focus: true
        Keys.enabled: true
        Keys.onPressed: {
            if (curActiveBoxGroup === null) {
                return;
            }

            switch (event.key){
            case Qt.Key_Left:
                curActiveBoxGroup.moveLeft(1, gameAreaRect);
                break;
            case Qt.Key_Right:
                curActiveBoxGroup.moveRight(1, gameAreaRect);
                break;
            case Qt.Key_Up:
                curActiveBoxGroup.moveUp(1, gameAreaRect);
                break;
            case Qt.Key_Down:
                curActiveBoxGroup.moveDown(1, gameAreaRect);
                break;
            case Qt.Key_Tab: //快速下移（坠落）
                curActiveBoxGroup.moveQuickDown(gameAreaRect);
                break;
            case Qt.Key_Space: //旋转
                curActiveBoxGroup.moveRotate(gameAreaRect);
                break;
            default:
                return;
            }
            event.accepted = true;
        }
    }

    function boxgroupClickedAction(boxgroup) {
        if (curActiveBoxGroup !== null) {
            curActiveBoxGroup.autoMoveDownTimer.running = false; //禁止多个方块组同时下落
        }
        curActiveBoxGroup = boxgroup;
    }

    onCurActiveBoxGroupChanged: {
        if (curActiveBoxGroup !== null) {
            //设置方块组自动下落
            curActiveBoxGroup.autoMoveDownTimer.gameRect = gameAreaRect;
            curActiveBoxGroup.autoMoveDownTimer.interval = 500;
            curActiveBoxGroup.autoMoveDownTimer.running = true;
        }
    }

    BoxGroup {
        id: iii
        x: oneBoxEdge * 3
        y: oneBoxEdge * 2
        z: 2
        oneBoxEdgeLength: oneBoxEdge
        groupType: BoxGroup.BoxShape.Shape_I

        MouseArea {
            anchors.fill: parent
            onClicked: {
                boxgroupClickedAction(parent);
            }
        }
    }

    BoxGroup {
        id: ooo
        x: oneBoxEdge * 3
        y: oneBoxEdge * 5
        z: 2
        oneBoxEdgeLength: oneBoxEdge
        groupType: BoxGroup.BoxShape.Shape_O

        MouseArea {
            anchors.fill: parent
            onClicked: {
                boxgroupClickedAction(parent);
            }
        }
    }

    BoxGroup {
        id: lll
        x: oneBoxEdge * 9
        y: oneBoxEdge * 10
        z: 2
        oneBoxEdgeLength: oneBoxEdge
        groupType: BoxGroup.BoxShape.Shape_L

        MouseArea {
            anchors.fill: parent
            onClicked: {
                boxgroupClickedAction(parent);
            }
        }
    }

    BoxGroup {
        id: sss
        x: oneBoxEdge * 10
        y: oneBoxEdge * 3
        z: 2
        oneBoxEdgeLength: oneBoxEdge
        groupType: BoxGroup.BoxShape.Shape_S

        MouseArea {
            anchors.fill: parent
            onClicked: {
                boxgroupClickedAction(parent);
            }
        }
    }

    BoxGroup {
        id: zzz
        x: oneBoxEdge * 12
        y: oneBoxEdge * 5
        z: 2
        oneBoxEdgeLength: oneBoxEdge
        groupType: BoxGroup.BoxShape.Shape_Z

        MouseArea {
            anchors.fill: parent
            onClicked: {
                boxgroupClickedAction(parent);
            }
        }
    }

    BoxGroup {
        id: jjj
        x: oneBoxEdge * 5
        y: oneBoxEdge * 14
        z: 2
        oneBoxEdgeLength: oneBoxEdge
        groupType: BoxGroup.BoxShape.Shape_J

        MouseArea {
            anchors.fill: parent
            onClicked: {
                boxgroupClickedAction(parent);
            }
        }
    }

    BoxGroup {
        id: ttt
        x: oneBoxEdge * 3
        y: oneBoxEdge * 9
        z: 2
        oneBoxEdgeLength: oneBoxEdge
        groupType: BoxGroup.BoxShape.Shape_T

        MouseArea {
            anchors.fill: parent
            onClicked: {
                boxgroupClickedAction(parent);
            }
        }
    }

    BoxGroup {
        id: randomBoxGroup
        x: oneBoxEdge * 7
        y: oneBoxEdge * 5
        z: 2
        oneBoxEdgeLength: oneBoxEdge
        groupType: BoxGroup.BoxShape.Shape_Random
        MouseArea {
            anchors.fill: parent
            onClicked: {
                boxgroupClickedAction(parent);
            }
        }
    }

    Timer{
        id: randTimer
        interval: 500
        running: false
        repeat: true
        property bool flag: false
        onTriggered: {
            flag = !flag;
            randomBoxGroup.groupType = BoxGroup.BoxShape.Shape_Random;
            randomBoxGroup.x += flag ? -oneBoxEdge : oneBoxEdge;
        }
    }

    function createBoxBackground(row, col){
        var TopX = gameAreaX;
        var TopY = gameAreaY;
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
                    box.x = TopX + j*mainWin.oneBoxEdge;
                    box.y = TopY + i*mainWin.oneBoxEdge;
                    box.edgeLength = mainWin.oneBoxEdge;
                    box.lightOff = true;
                    box.z = 1;
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
        mainWin.gameAreaRect = Qt.rect(gameAreaX, gameAreaY, gameAreaColSize*oneBoxEdge, gameAreaRowSize*oneBoxEdge);
        return true;
    }
}
