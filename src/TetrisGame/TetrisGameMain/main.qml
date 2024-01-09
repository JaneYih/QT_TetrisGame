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
    property Component boxGroupComponent: null
    property int gameAreaX: 40 //游戏区域x
    property int gameAreaY: 60 //游戏区域y
    property int gameAreaRowSize: 20 //游戏区域行数
    property int gameAreaColSize: 10 //游戏区域列数
    property var gameAreaRect: null //游戏区域矩形
    property var backgroundBoxArray: null //游戏区域背景方块二维数组
    property var curActiveBoxGroup: null //当前活动的方块组--唯一性，如果同时有多个活动方块自动下落，则背景不能多个同时点亮
    property var nextActiveBoxGroup: null //下一个方块组
    property int previewAreaX: gameAreaX + oneBoxEdge *  (gameAreaColSize+2)//下一个方块组预览区域x
    property int previewAreaY: gameAreaY + oneBoxEdge * 1 //下一个方块组预览区域y

    Component.onCompleted: {
        createBoxBackground(gameAreaRowSize, gameAreaColSize);
        createPreviewBackground(2, 4);
    }

    //将游戏区域的背景方块点亮--槽函数
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
                if (row < gameAreaRowSize && row >= 0
                       && col < gameAreaColSize && col >= 0) {
                    mainWin.backgroundBoxArray[row][col].lightOff = false;
                }
            }

            //销毁当前方块组
            curActiveBoxGroup.destroy();
            curActiveBoxGroup = null;

            //创建新的方块组
            createNextBoxGroup();
        }
    }

    // 设置新的方块组、预置下一个方块组
    function createNextBoxGroup() {
        if (nextActiveBoxGroup === null) {
            nextActiveBoxGroup = createRandomShapeBoxGroup(previewAreaX, previewAreaY);
        }
        setActiveBoxGroup(nextActiveBoxGroup);
        nextActiveBoxGroup = createRandomShapeBoxGroup(previewAreaX, previewAreaY);
    }

    MouseArea {
        id: gameAreaArea
        x: gameAreaRect.x
        y: gameAreaRect.y
        width: gameAreaRect.width
        height: gameAreaRect.height
        focus: true
        Keys.enabled: true
        Keys.onPressed: {
            if (curActiveBoxGroup === null) {
                return;
            }

            switch (event.key){
            case Qt.Key_Left:
                curActiveBoxGroup.moveLeft(1);
                break;
            case Qt.Key_Right:
                curActiveBoxGroup.moveRight(1);
                break;
            case Qt.Key_Up:
                curActiveBoxGroup.moveUp(1);
                break;
            case Qt.Key_Down:
                curActiveBoxGroup.moveDown(1);
                break;
            case Qt.Key_Tab: //快速下移（坠落）
                curActiveBoxGroup.moveQuickDown();
                break;
            case Qt.Key_Space: //旋转
                curActiveBoxGroup.moveRotate();
                break;
            default:
                return;
            }
            event.accepted = true;
        }
    }

    Button {
        id: button
        x: 434
        y: 234
        text: qsTr("开始游戏")
        onClicked: {
            createNextBoxGroup();
            gameAreaArea.forceActiveFocus();
        }
    }

    Button {
        id: button1
        x: 434
        y: 300
        text: qsTr("重置游戏")
    }

    onCurActiveBoxGroupChanged: {
        if (curActiveBoxGroup !== null) {
            curActiveBoxGroup.gameAreaRect = mainWin.gameAreaRect; //游戏区域矩形
            curActiveBoxGroup.backgroundBoxArray = mainWin.backgroundBoxArray; //设置游戏区域背景方块二维数组

            //设置方块组自动下落
            curActiveBoxGroup.autoMoveDownTimer.interval = 500;
            curActiveBoxGroup.autoMoveDownTimer.running = true;
        }
    }

    function setActiveBoxGroup(boxgroup) {
        if (curActiveBoxGroup !== null) {
            curActiveBoxGroup.autoMoveDownTimer.running = false; //禁止多个方块组同时下落
            curActiveBoxGroup.gameAreaRect = null;
            curActiveBoxGroup.backgroundBoxArray = null; //释放资源
            curActiveBoxGroup.destroy(); //释放掉上一个方块组
        }

        var topLeftOfBackground_Row = -2;
        var topLeftOfBackground_Col = gameAreaColSize/2 - 1;
        boxgroup.x = gameAreaX + oneBoxEdge * topLeftOfBackground_Col;
        boxgroup.y = gameAreaY + oneBoxEdge * topLeftOfBackground_Row;
        boxgroup.setRandomShapePost();
        curActiveBoxGroup = boxgroup;  //这里是浅拷贝
    }

    function createRandomShapeBoxGroup(boxGroupX, boxGroupY) {
        if (boxGroupComponent === null){
            boxGroupComponent = Qt.createComponent("BoxGroup.qml");
        }

        if (boxGroupComponent.status === Component.Ready) {
            var boxgtoup = boxGroupComponent.createObject(mainWin, {z: 2});
            boxgtoup.x = boxGroupX;
            boxgtoup.y = boxGroupY;
            boxgtoup.oneBoxEdgeLength = oneBoxEdge;
            boxgtoup.groupType = BoxGroup.BoxShape.Shape_Random
            return boxgtoup;
        }
        else {
            console.log("boxGroupComponent ERROR");
            return null;
        }
    }

    function createPreviewBackground(row, col) {
        if (oneboxComponent === null){
            oneboxComponent = Qt.createComponent("OneBox.qml");
        }

        for (var i = 0; i < row; i++){
            for (var j = 0; j < col; j++){
                if (oneboxComponent.status === Component.Ready){
                    var box = oneboxComponent.createObject(mainWin, {x: 0,y: 0});
                    box.x = previewAreaX + j*mainWin.oneBoxEdge;
                    box.y = previewAreaY + i*mainWin.oneBoxEdge;
                    box.edgeLength = mainWin.oneBoxEdge;
                    box.lightOff = true;
                    box.z = 1;
                }
                else {
                    console.log("createPreviewBackground ERROR");
                    return false;
                }
            }
        }
    }

    function createBoxBackground(row, col) {
        var TopX = gameAreaX;
        var TopY = gameAreaY;
        if (oneboxComponent === null){
            oneboxComponent = Qt.createComponent("OneBox.qml");
        }

        if (mainWin.backgroundBoxArray === null){
            mainWin.backgroundBoxArray = new Array;
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
            mainWin.backgroundBoxArray.push(rowArray);
        }
        mainWin.gameAreaRect = Qt.rect(gameAreaX, gameAreaY, gameAreaColSize*oneBoxEdge, gameAreaRowSize*oneBoxEdge);
        return true;
    }
}
