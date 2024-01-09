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
    property int gameState: Tetris.GameState.Ready //游戏状态
    property int oneBoxEdge: 20 //小方块边长
    property Component oneboxComponent: null
    property Component boxGroupComponent: null
    property int gameAreaX: 40 //游戏区域x
    property int gameAreaY: 60 //游戏区域y
    property int gameAreaRowSize: 20 //游戏区域行数
    property int gameAreaColSize: 10 //游戏区域列数
    property var gameAreaRect: null //游戏区域矩形
    property int boxMountainTopRowIndex: 0 //当前方块山最顶端的行序号
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

            var bGameOver = false;
            var curActiveBoxGroupBottomRowIndex = 0;
            var curActiveBoxGroupTopRowIndex = gameAreaRowSize-1;
            for (var i in curActiveBoxGroup.boxArray) {
                var row = originRow + curActiveBoxGroup.boxArray[i].row;
                var col = originCol + curActiveBoxGroup.boxArray[i].col;

                if (row < gameAreaRowSize && row >= 0
                       && col < gameAreaColSize && col >= 0) {

                    mainWin.backgroundBoxArray[row][col].lightOff = false;

                    boxMountainTopRowIndex = Math.min(boxMountainTopRowIndex, row);
                    curActiveBoxGroupBottomRowIndex = Math.max(curActiveBoxGroupBottomRowIndex, row);
                    curActiveBoxGroupTopRowIndex = Math.min(curActiveBoxGroupTopRowIndex, row);

                    //console.log("curActiveBoxGroupTopRowIndex:%1".arg(curActiveBoxGroupTopRowIndex));
                    //console.log("curActiveBoxGroupBottomRowIndex:%1".arg(curActiveBoxGroupBottomRowIndex));
                    //console.log("boxMountainTopRowIndex:%1".arg(boxMountainTopRowIndex));
                }

                if (row < 0) {
                    bGameOver = true;
                }
            }

            //销毁当前方块组
            curActiveBoxGroup.destroy();
            curActiveBoxGroup = null;

            if (bGameOver) {
                gameState = Tetris.GameState.Over; //游戏结束
            }
            else {
                checkAndClearBoxMountainFullRow(boxMountainTopRowIndex, curActiveBoxGroupTopRowIndex, curActiveBoxGroupBottomRowIndex); //消除方块山的满行，且山体下沉
                nextBoxGroupEnter();
            }
        }
    }

    //检测方块山的满行，且满行消除且山体下落
    function checkAndClearBoxMountainFullRow(mountainTopRowIndex, activeBoxTopRowIndex, activeBoxBottomRowIndex) {
        //检测方块山的满行
        var fullRowIndexArr = new Array; //用于记录满行序号
        for (var row = activeBoxTopRowIndex; row <= activeBoxBottomRowIndex; row++) {
            var bAllLightOn = true;
            for (var col = 0; col < gameAreaColSize; col++) {
                if (mainWin.backgroundBoxArray[row][col].lightOff) {
                    bAllLightOn = false;
                    break;
                }
            }

            //记录满行序号
            if (bAllLightOn) {
                //console.log("第%1行满行".arg(row));
                fullRowIndexArr.push(row);

                //满行消除
                for (var j = 0; j < gameAreaColSize; j++) {
                    mainWin.backgroundBoxArray[row][j].lightOff = true;
                }
            }
        }

        //山体下落
        var stepCount = fullRowIndexArr.length;
        for (var i= activeBoxBottomRowIndex; i>= mountainTopRowIndex; i--) {
            for (var k = 0; k < gameAreaColSize; k++) {
                if (!mainWin.backgroundBoxArray[i][k].lightOff) { //将点亮的方块下移（熄灭当前点，点亮新的点）
                    var newRowIndex = i + stepCount;
                    if (newRowIndex >= 0 && newRowIndex < gameAreaRowSize) {
                        mainWin.backgroundBoxArray[i][k].lightOff = true; //熄灭当前点
                        mainWin.backgroundBoxArray[newRowIndex][k].lightOff = false; //点亮新的点
                    }
                }
            }
        }
    }

    //下一个方块组下落
    function nextBoxGroupEnter() {
        createNextBoxGroup(); //创建新的方块组
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
        Keys.enabled: gameState === Tetris.GameState.Running
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
            //case Qt.Key_Up:
            //    curActiveBoxGroup.moveUp(1);
            //    break;
            case Qt.Key_Down:
                curActiveBoxGroup.moveDown(1);
                break;
            case Qt.Key_Space: //快速下移（坠落）
                curActiveBoxGroup.moveQuickDown();
                break;
            case Qt.Key_Up: //旋转
                curActiveBoxGroup.moveRotate();
                break;
            default:
                return;
            }
            event.accepted = true;
        }
    }

    Text {
        id: gameOverText
        x: gameAreaX + 1 * oneBoxEdge
        y: gameAreaY + (gameAreaRowSize / 3) * oneBoxEdge
        z: 5
        font.family: "Arial"
        font.pointSize: 20
        color: "#ff0000"
        text: qsTr("Game Over!!")
        visible: false
    }

    onGameStateChanged: {
        switch (gameState) {
        case Tetris.GameState.Ready:
            resetGame();
            break;
        case Tetris.GameState.Start:
            startGame();
            break;
        case Tetris.GameState.Running:
            continueGame();
            break;
        case Tetris.GameState.Pause:
            pauseGame();
            break;
        case Tetris.GameState.Over:
            gameOver();
            break;
        }
        gameAreaArea.forceActiveFocus();
    }

    //开始游戏
    function startGame() {
        resetGame();
        //.......//增加游戏难度，可以在这里增加一个函数：设置背景底部随机小box
        createNextBoxGroup();
        gameState = Tetris.GameState.Running;
    }

    //游戏结束
    function gameOver() {
        gameOverText.visible = true;
    }

    //重新开始游戏
    function resetGame(){
        //这里是背景的消除，可以做一些动画在这里
        for (var i = 0; i < gameAreaRowSize; i++) {
            for (var j = 0; j < gameAreaColSize; j++) {
                mainWin.backgroundBoxArray[i][j].lightOff = true;
            }
        }
        boxMountainTopRowIndex = gameAreaRowSize-1;
        gameOverText.visible = false;
    }

    //暂停游戏
    function pauseGame() {
        if (curActiveBoxGroup !== null) {
            curActiveBoxGroup.autoMoveDownTimer.running = false;
        }
    }

    //继续游戏
    function continueGame() {
        if (curActiveBoxGroup !== null) {
            curActiveBoxGroup.autoMoveDownTimer.running = true;
        }
    }

    Button {
        id: btnStartGame
        x: 434
        y: 241
        text: qsTr("开始")
        enabled: (gameState === Tetris.GameState.Over
                  || gameState === Tetris.GameState.Ready)
        onClicked: {
            gameState = Tetris.GameState.Start;
        }
    }

    Button {
        id: btnResetGame
        x: 434
        y: 188
        text: qsTr("重新开始")
        enabled: true
        onClicked: {
            //gameState = Tetris.GameState.Ready;
            gameState = Tetris.GameState.Start;
        }
    }

    Button {
        id: btnPauseGame
        x: 434
        y: 293
        text: qsTr("暂停")
        enabled: gameState === Tetris.GameState.Running
        onClicked: {
            gameState = Tetris.GameState.Pause;
        }
    }

    Button {
        id: btnContinueGame
        x: 434
        y: 345
        text: qsTr("继续")
        enabled: gameState === Tetris.GameState.Pause
        onClicked: {
            gameState = Tetris.GameState.Running;
        }
    }

    onCurActiveBoxGroupChanged: {
        if (curActiveBoxGroup !== null) {
            curActiveBoxGroup.gameAreaRect = mainWin.gameAreaRect; //游戏区域矩形
            curActiveBoxGroup.backgroundBoxArray = mainWin.backgroundBoxArray; //设置游戏区域背景方块二维数组

            //设置方块组自动下落
            curActiveBoxGroup.autoMoveDownTimer.interval = 500;   //可以调节这个时间，以划分游戏难度等级
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
