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
    property Component oneboxComponent: null
    property Component boxGroupComponent: null
    property int gameState: Tetris.GameState.Ready //游戏状态

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
        gamePage.forceActiveFocus();
    }

    Rectangle {
        id: gamePage
        x: 20
        y: 20
        z: 0
        border.color: "red"
        //border.color: "transparent"
        border.width: 1
        color: "transparent"
        property int oneBoxEdge: 20 //小方块边长
        property int gameAreaRowSize: 20 //游戏区域行数
        property int gameAreaColSize: 10 //游戏区域列数
        property var gameAreaRect: null //游戏区域矩形
        property int boxMountainTopRowIndex: 0 //当前方块山最顶端的行序号
        property var backgroundBoxArray: null //游戏区域背景方块二维数组
        property var curActiveBoxGroup: null //当前活动的方块组--唯一性，如果同时有多个活动方块自动下落，则背景不能多个同时点亮
        property var nextActiveBoxGroup: null //下一个方块组

        focus: true
        Keys.enabled: gameState === Tetris.GameState.Running
        Keys.onPressed: {
            if (gamePage.curActiveBoxGroup === null) {
                return;
            }

            switch (event.key){
            case Qt.Key_Left:
                gamePage.curActiveBoxGroup.moveLeft(1);
                break;
            case Qt.Key_Right:
                gamePage.curActiveBoxGroup.moveRight(1);
                break;
            //case Qt.Key_Up:
            //    gamePage.curActiveBoxGroup.moveUp(1);
            //    break;
            case Qt.Key_Down:
                gamePage.curActiveBoxGroup.moveDown(1);
                break;
            case Qt.Key_Space: //快速下移（坠落）
                gamePage.curActiveBoxGroup.moveQuickDown();
                break;
            case Qt.Key_Up: //旋转
                gamePage.curActiveBoxGroup.moveRotate();
                break;
            default:
                return;
            }
            event.accepted = true;
        }

        Component.onCompleted: {
            createBoxBackground(gamePage.gameAreaRowSize, gamePage.gameAreaColSize);
            createPreviewBackground(2, 4);
        }

        onCurActiveBoxGroupChanged: {
            if (gamePage.curActiveBoxGroup !== null) {
                gamePage.curActiveBoxGroup.gameAreaRect = gamePage.gameAreaRect; //游戏区域矩形
                gamePage.curActiveBoxGroup.backgroundBoxArray = gamePage.backgroundBoxArray; //设置游戏区域背景方块二维数组

                //设置方块组自动下落
                gamePage.curActiveBoxGroup.autoMoveDownTimer.interval = 500;   //可以调节这个时间，以划分游戏难度等级
                gamePage.curActiveBoxGroup.autoMoveDownTimer.running = true;
            }
        }

        //将游戏区域的背景方块点亮--槽函数
        Connections {
            target: gamePage.curActiveBoxGroup
            onBackgroundBoxsLightUp: {
                //console.log("onBackgroundBoxsLightUp");

                var originRow = (gamePage.curActiveBoxGroup.y - gameMainArea.y) / gamePage.oneBoxEdge;
                var originCol = (gamePage.curActiveBoxGroup.x - gameMainArea.x) / gamePage.oneBoxEdge;
                //console.log("%1   %2".arg(originRow).arg(originCol));

                var bGameOver = false;
                var curActiveBoxGroupBottomRowIndex = 0;
                var curActiveBoxGroupTopRowIndex = gamePage.gameAreaRowSize-1;
                for (var i in gamePage.curActiveBoxGroup.boxArray) {
                    var row = originRow + gamePage.curActiveBoxGroup.boxArray[i].row;
                    var col = originCol + gamePage.curActiveBoxGroup.boxArray[i].col;

                    if (row < gamePage.gameAreaRowSize && row >= 0
                           && col < gamePage.gameAreaColSize && col >= 0) {

                        gamePage.backgroundBoxArray[row][col].lightOff = false;

                        gamePage.boxMountainTopRowIndex = Math.min(gamePage.boxMountainTopRowIndex, row);
                        curActiveBoxGroupBottomRowIndex = Math.max(curActiveBoxGroupBottomRowIndex, row);
                        curActiveBoxGroupTopRowIndex = Math.min(curActiveBoxGroupTopRowIndex, row);

                        //console.log("curActiveBoxGroupTopRowIndex:%1".arg(curActiveBoxGroupTopRowIndex));
                        //console.log("curActiveBoxGroupBottomRowIndex:%1".arg(curActiveBoxGroupBottomRowIndex));
                        //console.log("gamePage.boxMountainTopRowIndex:%1".arg(gamePage.boxMountainTopRowIndex));
                    }

                    if (row < 0) {
                        bGameOver = true;
                    }
                }

                //销毁当前方块组
                gamePage.curActiveBoxGroup.destroy();
                gamePage.curActiveBoxGroup = null;

                if (bGameOver) {
                    gameState = Tetris.GameState.Over; //游戏结束
                }
                else {
                    checkAndClearBoxMountainFullRow(gamePage.boxMountainTopRowIndex, curActiveBoxGroupTopRowIndex, curActiveBoxGroupBottomRowIndex); //消除方块山的满行，且山体下沉
                    nextBoxGroupEnter();
                }
            }
        }

        Row {
            id: gamePageRow
            spacing: gamePage.oneBoxEdge * 2

            onWidthChanged: {
                gamePage.width = width;
            }

            onHeightChanged: {
                gamePage.height = height;
            }

            Item {
                id: gameMainArea
                x: 0
                y: 0

                Text {
                    id: gameOverText
                    anchors.fill: parent
                    z: 3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Arial"
                    font.pointSize: 20
                    color: "#ff0000"
                    text: qsTr("Game Over!!")
                    visible: false
                }
            }

            Column {
                id: gameInfoArea
                spacing: gamePage.oneBoxEdge * 1

                //下一个方块组预览区域
                Item {
                    id: previewArea
                    x: 0
                    y: 0

                }

                //分数显示区域
                Rectangle {
                    id: scoreArea
                    width: 100
                    height: 50

                    Text {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("分数显示区域")
                    }
                }

                //计时器显示区域
                Rectangle {
                    id: timerArea
                    width: 100
                    height: 50

                    Text {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("计时器显示区域")
                    }
                }
            }
        }
    }

    Column {
        id: btnColumn
        x: 430
        y: 67
        spacing: 10

        Button {
            id: btnStartGame
            text: qsTr("开始")
            enabled: (gameState === Tetris.GameState.Over
                      || gameState === Tetris.GameState.Ready)
            onClicked: {
                gameState = Tetris.GameState.Start;
            }
        }

        Button {
            id: btnResetGame
            text: qsTr("重新开始")
            enabled: true
            onClicked: {
                //gameState = Tetris.GameState.Ready;
                gameState = Tetris.GameState.Start;
            }
        }

        Button {
            id: btnPauseGame
            text: qsTr("暂停")
            enabled: gameState === Tetris.GameState.Running
            onClicked: {
                gameState = Tetris.GameState.Pause;
            }
        }

        Button {
            id: btnContinueGame
            text: qsTr("继续")
            enabled: gameState === Tetris.GameState.Pause
            onClicked: {
                gameState = Tetris.GameState.Running;
            }
        }


    }

    //检测方块山的满行，且满行消除且山体下落
    function checkAndClearBoxMountainFullRow(mountainTopRowIndex, activeBoxTopRowIndex, activeBoxBottomRowIndex) {
        //检测方块山的满行
        var fullRowIndexArr = new Array; //用于记录满行序号
        for (var row = activeBoxTopRowIndex; row <= activeBoxBottomRowIndex; row++) {
            var bAllLightOn = true;
            for (var col = 0; col < gamePage.gameAreaColSize; col++) {
                if (gamePage.backgroundBoxArray[row][col].lightOff) {
                    bAllLightOn = false;
                    break;
                }
            }

            //记录满行序号
            if (bAllLightOn) {
                //console.log("第%1行满行".arg(row));
                fullRowIndexArr.push(row);

                //满行消除，计分数
                for (var j = 0; j < gamePage.gameAreaColSize; j++) {
                    gamePage.backgroundBoxArray[row][j].lightOff = true;
                }
            }
        }

        //山体下落
        var stepCount = fullRowIndexArr.length;
        for (var i= activeBoxBottomRowIndex; i>= mountainTopRowIndex; i--) {
            for (var k = 0; k < gamePage.gameAreaColSize; k++) {
                if (!gamePage.backgroundBoxArray[i][k].lightOff) { //将点亮的方块下移（熄灭当前点，点亮新的点）
                    var newRowIndex = i + stepCount;
                    if (newRowIndex >= 0 && newRowIndex < gamePage.gameAreaRowSize) {
                        gamePage.backgroundBoxArray[i][k].lightOff = true; //熄灭当前点
                        gamePage.backgroundBoxArray[newRowIndex][k].lightOff = false; //点亮新的点
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
        if (gamePage.nextActiveBoxGroup === null) {
            gamePage.nextActiveBoxGroup = createRandomShapeBoxGroup();
        }
        setActiveBoxGroup(gamePage.nextActiveBoxGroup);
        gamePage.nextActiveBoxGroup = createRandomShapeBoxGroup();
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
    function resetGame() {
        //这里是背景的消除，可以做一些动画在这里
        for (var i = 0; i < gamePage.gameAreaRowSize; i++) {
            for (var j = 0; j < gamePage.gameAreaColSize; j++) {
                gamePage.backgroundBoxArray[i][j].lightOff = true;
            }
        }
        gamePage.boxMountainTopRowIndex = gamePage.gameAreaRowSize-1;
        gameOverText.visible = false;
    }

    //暂停游戏
    function pauseGame() {
        if (gamePage.curActiveBoxGroup !== null) {
            gamePage.curActiveBoxGroup.autoMoveDownTimer.running = false;
        }
    }

    //继续游戏
    function continueGame() {
        if (gamePage.curActiveBoxGroup !== null) {
            gamePage.curActiveBoxGroup.autoMoveDownTimer.running = true;
        }
    }

    function setActiveBoxGroup(boxgroup) {
        if (gamePage.curActiveBoxGroup !== null) {
            gamePage.curActiveBoxGroup.autoMoveDownTimer.running = false; //禁止多个方块组同时下落
            gamePage.curActiveBoxGroup.gameAreaRect = null;
            gamePage.curActiveBoxGroup.backgroundBoxArray = null; //释放资源
            gamePage.curActiveBoxGroup.destroy(); //释放掉上一个方块组
        }

        var topLeftOfBackground_Row = -2;
        var topLeftOfBackground_Col = gamePage.gameAreaColSize/2 - 1;
        boxgroup.parent = gameMainArea;
        boxgroup.x = gameMainArea.x + gamePage.oneBoxEdge * topLeftOfBackground_Col;
        boxgroup.y = gameMainArea.y + gamePage.oneBoxEdge * topLeftOfBackground_Row;
        boxgroup.setRandomShapePost();
        gamePage.curActiveBoxGroup = boxgroup;  //这里是浅拷贝
    }

    function createRandomShapeBoxGroup() {
        if (boxGroupComponent === null){
            boxGroupComponent = Qt.createComponent("BoxGroup.qml");
        }

        if (boxGroupComponent.status === Component.Ready) {
            var boxgtoup = boxGroupComponent.createObject(previewArea, {z: 2});
            boxgtoup.x = 0;
            boxgtoup.y = 0;
            boxgtoup.oneBoxEdgeLength = gamePage.oneBoxEdge;
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
            for (var j = 0; j < col; j++) {
                if (oneboxComponent.status === Component.Ready){
                    var box = oneboxComponent.createObject(previewArea, {x: 0,y: 0});
                    box.x = 0 + j*gamePage.oneBoxEdge;
                    box.y = 0 + i*gamePage.oneBoxEdge;
                    box.edgeLength = gamePage.oneBoxEdge;
                    box.lightOff = true;
                    box.z = 1;
                }
                else {
                    console.log("createPreviewBackground ERROR");
                    return false;
                }
            }
        }
        previewArea.width = col * gamePage.oneBoxEdge;
        previewArea.height = row * gamePage.oneBoxEdge;
    }

    function createBoxBackground(row, col) {
        var TopX = gameMainArea.x;
        var TopY = gameMainArea.y;
        if (oneboxComponent === null) {
            oneboxComponent = Qt.createComponent("OneBox.qml");
        }

        if (gamePage.backgroundBoxArray === null){
            gamePage.backgroundBoxArray = new Array;
        }

        for (var i = 0; i < row; i++){
            var rowArray = new Array;
            for (var j = 0; j < col; j++){
                if (oneboxComponent.status === Component.Ready){
                    var box = oneboxComponent.createObject(gameMainArea, {x: 0,y: 0});
                    box.x = TopX + j*gamePage.oneBoxEdge;
                    box.y = TopY + i*gamePage.oneBoxEdge;
                    box.edgeLength = gamePage.oneBoxEdge;
                    box.lightOff = true;
                    box.z = 1;
                    rowArray.push(box);
                }
                else {
                    console.log("oneboxComponent ERROR");
                    return false;
                }
            }
            gamePage.backgroundBoxArray.push(rowArray);
        }
        gameMainArea.width = gamePage.gameAreaColSize * gamePage.oneBoxEdge;
        gameMainArea.height = gamePage.gameAreaRowSize * gamePage.oneBoxEdge;
        gamePage.gameAreaRect = Qt.rect(TopX, TopY, gameMainArea.width, gameMainArea.height);
        return true;
    }
}
