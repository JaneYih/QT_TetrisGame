import QtQuick 2.9
import QtQuick.Controls 2.13
import QtMultimedia 5.0
import Yih.Tetris.Business 1.0

Rectangle {
    id: gameView
    //color: "#8aece3"
    color: "transparent"
    //border.color: "transparent"
    //border.color: "red"
    //border.width: 1
    //width: gamePage.width + gamePage.oneBoxEdge
    //height: gamePage.height

    property Component oneboxComponent: null
    property Component boxGroupComponent: null
    property alias oneBoxEdge: gamePage.oneBoxEdge
    property alias gameAreaRowSize: gamePage.gameAreaRowSize
    property int gameState: TetrisBusiness.Ready //游戏状态
    property int gameSpeed: 800 //方块下落速度(ms)
    property int gameScore: 0 //当前游戏分数
    property int gameHighestScoreRecord: 0 //游戏分数历史最高分
    property int gameLastScoreRecord: 0 //上一次游戏分数
    property var gameUserName: "tester"
    property int gameElapsedTime: 0 //游戏计时时间
    property bool bMute: false //是否静音
    signal skipPage(var viewType);

    onVisibleChanged: {
        if (gameView.visible) {
            gameView.gameHighestScoreRecord = businessInstance.getHighestScore();
            gameView.gameLastScoreRecord = businessInstance.getUserLastScore(gameUserName);
            setGameSpeed(businessInstance.gameState !== TetrisBusiness.Running && businessInstance.gameState !== TetrisBusiness.Pause);
            gamePage.forceActiveFocus();
        }
    }

    onFocusChanged: {
        focusScope.focus = true;
    }

    onGameStateChanged: {
        businessInstance.gameState = gameState;
        switch (gameState) {
        case TetrisBusiness.Ready:
            resetGame();
            break;
        case TetrisBusiness.Start:
            startGame();
            break;
        case TetrisBusiness.Running:
            continueGame();
            break;
        case TetrisBusiness.Pause:
            pauseGame();
            break;
        case TetrisBusiness.Over:
            gameOver();
            break;
        }
        var bgmFile;
        if (gameState === TetrisBusiness.Running
                || gameState === TetrisBusiness.Pause) {
            bgmFile = "qrc:/img/Westlife - Tonight.mp3";
        }
        else {
            bgmFile = "qrc:/img/雷诺儿 - 我的钢琴很简单.mp3";
        }
        if (bgmFile !== bgm.source) {
            bgm.source = bgmFile;
        }
        gamePage.forceActiveFocus();
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        z: 0
        opacity: 1
        source: "qrc:/img/Doraemon.jpg"
    }

    ImageButton {
        id: volumeBtn
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        imageSource: bMute ? "qrc:/img/mute.png" : "qrc:/img/volume.png"
        mouseArea.onClicked: {
            bMute = !bMute;
        }
    }

    MediaPlayer {
        id: bgm
        autoPlay: true
        muted: bMute
        source: "qrc:/img/雷诺儿 - 我的钢琴很简单.mp3"
    }

    FocusScope {
        id: focusScope
        anchors.centerIn: parent
        focus: true

        Rectangle {
            id: gamePage
            anchors.centerIn: parent
            //anchors.fill: parent
            z: 1
            //border.color: "red"
            border.color: "transparent"
            border.width: 1
            color: "transparent"
            property int oneBoxEdge: 20 //小方块边长
            property int gameAreaRowSize: 20 //游戏区域行数
            property int gameAreaColSize: 10 //游戏区域列数
            property var gameAreaRect: null //游戏区域矩形
            property int boxMountainTopRowIndex: 0 //当前方块山最顶端的行序号
            property var backgroundBoxArray: null //游戏区域背景方块二维数组
            property var previewBoxArray: null //预览区域背景方块二维数组
            property var curActiveBoxGroup: null //当前活动的方块组--唯一性，如果同时有多个活动方块自动下落，则背景不能多个同时点亮
            property var nextActiveBoxGroup: null //下一个方块组

            focus: true
            Keys.enabled: gameState === TetrisBusiness.Running
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
                case Qt.Key_0: //暂停\继续
                    btnPauseGame.onClicked();
                    break;
                default:
                    return;
                }
                event.accepted = true;
            }

            Component.onCompleted: {
                initBoxsBackgroud();
            }

            onOneBoxEdgeChanged: {
                initBoxsBackgroud();
                if (gamePage.nextActiveBoxGroup !== null) {
                    gamePage.nextActiveBoxGroup.oneBoxEdgeLength = gamePage.oneBoxEdge;
                }
                if (gamePage.curActiveBoxGroup !== null) {
                    gamePage.curActiveBoxGroup.oneBoxEdgeLength = gamePage.oneBoxEdge;
                }
            }

            function initBoxsBackgroud() {
                createBoxBackground(gamePage.gameAreaRowSize, gamePage.gameAreaColSize);
                createPreviewBackground(2, 4);
            }

            onCurActiveBoxGroupChanged: {
                if (gamePage.curActiveBoxGroup !== null) {
                    gamePage.curActiveBoxGroup.gameAreaRect = gamePage.gameAreaRect; //游戏区域矩形
                    gamePage.curActiveBoxGroup.backgroundBoxArray = gamePage.backgroundBoxArray; //设置游戏区域背景方块二维数组

                    //设置方块组自动下落
                    gamePage.curActiveBoxGroup.autoMoveDownTimer.interval = gameView.gameSpeed;
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
                        gameState = TetrisBusiness.Over; //游戏结束
                    }
                    else {
                        checkAndClearBoxMountainFullRow(curActiveBoxGroupTopRowIndex, curActiveBoxGroupBottomRowIndex); //消除方块山的满行，且山体下沉
                        nextBoxGroupEnter();
                    }
                }
            }

            Row {
                id: gamePageRow
                spacing: gamePage.oneBoxEdge

                onWidthChanged: {
                    gamePage.width = width;
                }

                onHeightChanged: {
                    gamePage.height = height;
                }

                Row {
                    spacing: 3
                    //行序号显示
                    Column {
                        id: rowIndex
                        spacing: 0
                        Repeater {
                            model: gamePage.gameAreaRowSize
                            Text {
                                width: gamePage.oneBoxEdge
                                height: gamePage.oneBoxEdge
                                text: index
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                visible: true
                            }
                        }
                    }

                    //游戏区域
                    Row {
                        spacing: 3
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

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    gamePage.forceActiveFocus();
                                }
                            }
                        }
                    }
                }

                //游戏信息显示与控制区
                Column {
                    id: gameInfoArea
                    spacing: gamePage.oneBoxEdge * 1

                    //下一个方块组预览区域
                    Item {
                        id: previewArea
                        x: 0
                        y: 0
                    }

                    //下落速度选择
                    ComboBox {
                        id: gameSpeedComboBox
                        width: gamePage.oneBoxEdge * 4
                        height: gamePage.oneBoxEdge * 1.6
                        editable: true
                        model: ListModel {
                            id: model
                            ListElement { text: "400" }
                            ListElement { text: "600" }
                            ListElement { text: "800" }
                            ListElement { text: "1000" }
                            ListElement { text: "300" }
                        }
                        enabled: (gameState !== TetrisBusiness.Running
                                  && gameState !== TetrisBusiness.Pause)
                        onAccepted: {
                            if (find(editText) === -1){
                                model.append({text: editText})
                            }
                        }
                        onCurrentTextChanged: {
                            gameView.gameSpeed = parseInt(currentText);
                            //console.log("下落速度：%1ms".arg(gameView.gameSpeed));
                        }
                        Component.onCompleted: {
                            currentIndex = 0;
                        }
                    }

                    //分数显示区域
                    Rectangle {
                        id: scoreArea
                        width: gamePage.oneBoxEdge * 4
                        height: 35
                        //border.color: "#881ad0"
                        border.color: "transparent"
                        color: "transparent"

                        Column {
                            spacing: 0
                            Text {
                                width: scoreArea.width
                                height: scoreArea.height/2
                                color: "red"
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                text: qsTr("历史最高:%1".arg(gameView.gameHighestScoreRecord))
                            }
                            Text {
                                width: scoreArea.width
                                height: scoreArea.height/2
                                color: "darkmagenta"
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                text: qsTr("上次分数:%1".arg(gameView.gameLastScoreRecord))
                            }
                            Text {
                                id: element
                                width: scoreArea.width
                                height: scoreArea.height/2
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                color: "blue"
                                text: qsTr("分数:%1".arg(gameView.gameScore))
                            }
                        }
                    }


                    //计时器显示区域
                    Rectangle {
                        id: timerArea
                        width: gamePage.oneBoxEdge * 4
                        height: 20
                        color: "transparent"

                        Text {
                            id: timerText
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("00:00:00:000")
                        }

                        Timer{
                            id: gameTimerItem
                            interval: 33
                            repeat: true
                            triggeredOnStart: true // gameTimerItem.start()、gameTimerItem.stop()

                            onTriggered: {
                                gameView.gameElapsedTime += gameTimerItem.interval;
                                //console.log(gameView.gameElapsedTime);
                                var ElapsedTime = new Date(gameView.gameElapsedTime) ;
                                timerText.text = toTimeString(ElapsedTime);
                            }

                            function toTimeString (millisecond) {
                                    var hours = parseInt((millisecond % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                                    var minutes = parseInt((millisecond % (1000 * 60 * 60)) / (1000 * 60));
                                    var seconds = parseInt((millisecond % (1000 * 60)) / 1000);
                                    var milliseconds = millisecond % 1000;

                                    var str = "%1:%2:%3:%4"
                                            .arg(hours.toString().padStart(2, '0'))
                                            .arg(minutes.toString().padStart(2, '0'))
                                            .arg(seconds.toString().padStart(2, '0'))
                                            .arg(milliseconds.toString().padStart(3, '0'));

                                    //console.log(str);
                                    return str;
                            }
                        }
                    }

                    //按钮区域
                    Column {
                        id: btnColumn
                        spacing: 10

                        Button {
                            id: btnStartGame
                            text: qsTr("开始")
                            enabled: (gameState === TetrisBusiness.Over
                                      || gameState === TetrisBusiness.Ready)
                            onClicked: {
                                gameState = TetrisBusiness.Start;
                            }
                        }

                        Button {
                            id: btnResetGame
                            text: qsTr("重新开始")
                            enabled: true
                            onClicked: {
                                //gameState = TetrisBusiness.Ready;
                                gameState = TetrisBusiness.Start;
                            }
                        }

                        Button {
                            id: btnPauseGame
                            text: qsTr("暂停")
                            enabled: (gameState === TetrisBusiness.Running || gameState === TetrisBusiness.Pause)
                            onClicked: {
                                if (gameState === TetrisBusiness.Running) {
                                    gameState = TetrisBusiness.Pause;
                                    btnPauseGame.text = qsTr("继续");
                                }
                                else if (gameState === TetrisBusiness.Pause){
                                    gameState = TetrisBusiness.Running;
                                    btnPauseGame.text = qsTr("暂停");
                                }
                            }
                        }

                        Button {
                            id: btnSkipScorePage
                            text: qsTr("历史分数")
                            enabled: true
                            onClicked: {
                                gameView.skipPage(TetrisBusiness.ScoreView);
                            }
                        }
                    }
                }
            }
        }
    }


    //检测方块山的满行，且满行消除且山体下落
    function checkAndClearBoxMountainFullRow(activeBoxTopRowIndex, activeBoxBottomRowIndex) {
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
                console.log("第%1行满行".arg(row));
                fullRowIndexArr.push(row);

                //满行消除，计分数
                for (var j = 0; j < gamePage.gameAreaColSize; j++) {
                    gamePage.backgroundBoxArray[row][j].lightOff = true;
                }

                gameView.gameScore++; //得分
                businessInstance.currentScore = gameView.gameScore;
                setGameSpeed(true); //可以调节这个时间，以划分游戏难度等级
            }
        }

        //山体下落
        var fullRowCount = fullRowIndexArr.length;
        if (fullRowCount > 0) {
            console.log("山顶：%1，方块底：%2"
                        .arg(gamePage.boxMountainTopRowIndex)
                        .arg(activeBoxBottomRowIndex));

            var peakMoveDownStep = 0; //山顶下落步数
            for (var f=fullRowCount-1; f>=0; f--) { //遍历满行序号数组
                if (f === 0) {
                    mountainRowMoveDown(gamePage.boxMountainTopRowIndex, fullRowIndexArr[0]-1, ++peakMoveDownStep);
                    gamePage.boxMountainTopRowIndex += peakMoveDownStep; //山顶更新
                }
                else {
                    var diffNum = fullRowIndexArr[f] - fullRowIndexArr[f-1];
                    if (diffNum > 1) { //不相邻的两个满行
                        mountainRowMoveDown(fullRowIndexArr[f-1]+1, fullRowIndexArr[f]-1, 1);
                        //peakMoveDownStep++;
                    }
                    //else if (diffNum === 1) { //相邻的两个满行
                        peakMoveDownStep++;
                    //}
                }
            }
        }
    }

    //山块下落
    //topRowIndex: 待下落山块最高行序号
    //buttomRowIndex: 待下落山块最低行序号
    //stepCount：下落格子数
    function mountainRowMoveDown(topRowIndex, buttomRowIndex, stepCount) {
        if (stepCount > 0) {
            console.log("山块行：%1<=x<=%2，下落%3个格子".arg(topRowIndex).arg(buttomRowIndex).arg(stepCount));
            for (var i= buttomRowIndex; i>= topRowIndex; i--) {
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
        setBackgroundLineRandomBox(); //增加游戏难度，在这里增加一个函数：设置背景底部随机小box
        createNextBoxGroup();
        gameState = TetrisBusiness.Running;
    }

    //背景底部放置随机小box
    function setBackgroundLineRandomBox() {
        if (businessInstance.gameLevel > TetrisBusiness.Simple
                && gamePage.backgroundBoxArray[gamePage.gameAreaRowSize - 1] !== null) {
            for (var i = 0; i < gamePage.gameAreaColSize; i++) {
                var now = new Date();
                var rand =  Math.random(now.getSeconds()) * 10 + 1; //1~10随机数
                var randomNum = rand % 2;
                gamePage.backgroundBoxArray[gamePage.gameAreaRowSize - 1][i].lightOff = randomNum < 1;
            }
        }
    }

    //游戏结束
    function gameOver() {
        gameOverText.visible = true;
        businessInstance.insertScoreData(gameView.gameUserName,  gameView.gameScore);
        gameTimerItem.stop();
        gameView.skipPage(TetrisBusiness.ScoreView);//跳转到分数页面
    }

    //重新开始游戏
    function resetGame() {
        gameTimerItem.stop();

        //这里是背景的消除，可以做一些动画在这里
        for (var i = 0; i < gamePage.gameAreaRowSize; i++) {
            for (var j = 0; j < gamePage.gameAreaColSize; j++) {
                gamePage.backgroundBoxArray[i][j].lightOff = true;
            }
        }
        gamePage.boxMountainTopRowIndex = gamePage.gameAreaRowSize-1;
        gameView.gameScore = 0;
        gameView.gameHighestScoreRecord = businessInstance.getHighestScore();
        setGameSpeed(true);
        gameView.gameElapsedTime = 0;
        gameOverText.visible = false;
    }

    //暂停游戏
    function pauseGame() {
        if (gamePage.curActiveBoxGroup !== null) {
            gamePage.curActiveBoxGroup.autoMoveDownTimer.running = false;
            gameTimerItem.stop();
        }
    }

    //继续游戏
    function continueGame() {
        if (gamePage.curActiveBoxGroup !== null) {
            gamePage.curActiveBoxGroup.autoMoveDownTimer.running = true;
            gameTimerItem.start();
        }
    }

    function setActiveBoxGroup(boxgroup) {
        if (gamePage.curActiveBoxGroup !== null) {
            gamePage.curActiveBoxGroup.autoMoveDownTimer.running = false; //禁止多个方块组同时下落
            gamePage.curActiveBoxGroup.gameAreaRect = null;
            gamePage.curActiveBoxGroup.backgroundBoxArray = null; //释放资源
            gamePage.curActiveBoxGroup.destroy(); //释放掉上一个方块组
        }

        boxgroup.parent = gameMainArea;
        boxgroup.hideBoxs(); //隐藏小方块
        boxgroup.setRandomShapePost();
        var topLeftOfBackground_Row = -boxgroup.rowCount;
        var topLeftOfBackground_Col = gamePage.gameAreaColSize/2 - 1;
        boxgroup.x = gameMainArea.x + gamePage.oneBoxEdge * topLeftOfBackground_Col;
        boxgroup.y = gameMainArea.y + gamePage.oneBoxEdge * topLeftOfBackground_Row;
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

        if (gamePage.previewBoxArray === null) {
            gamePage.previewBoxArray = new Array;
            for (var i = 0; i < row; i++){
                var rowArray = new Array;
                for (var j = 0; j < col; j++) {
                    if (oneboxComponent.status === Component.Ready){
                        var box = oneboxComponent.createObject(previewArea, {x: 0,y: 0});
                        box.x = 0 + j*gamePage.oneBoxEdge;
                        box.y = 0 + i*gamePage.oneBoxEdge;
                        box.edgeLength = gamePage.oneBoxEdge;
                        box.lightOff = true;
                        box.z = 1;
                        rowArray.push(box);
                    }
                    else {
                        console.log("createPreviewBackground ERROR");
                        return false;
                    }
                }
                gamePage.previewBoxArray.push(rowArray);
            }
        }
        else {
            for (var a = 0; a < row; a++){
                for (var b = 0; b < col; b++){
                    gamePage.previewBoxArray[a][b].x = 0 + b*gamePage.oneBoxEdge;
                    gamePage.previewBoxArray[a][b].y = 0 + a*gamePage.oneBoxEdge;
                    gamePage.previewBoxArray[a][b].edgeLength = gamePage.oneBoxEdge;
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
        }
        else {
            for (var a = 0; a < row; a++){
                for (var b = 0; b < col; b++){
                    gamePage.backgroundBoxArray[a][b].x = TopX + b*gamePage.oneBoxEdge;
                    gamePage.backgroundBoxArray[a][b].y = TopY + a*gamePage.oneBoxEdge;
                    gamePage.backgroundBoxArray[a][b].edgeLength = gamePage.oneBoxEdge;
                }
            }
        }

        gameMainArea.width = gamePage.gameAreaColSize * gamePage.oneBoxEdge;
        gameMainArea.height = gamePage.gameAreaRowSize * gamePage.oneBoxEdge;
        gamePage.gameAreaRect = Qt.rect(TopX, TopY, gameMainArea.width, gameMainArea.height);
        return true;
    }

    function setGameSpeed(bRecalculat) {
        if (bRecalculat) {
            var radix = 1.0;
            var initSpeed = 1000;
            switch (businessInstance.gameLevel) {
            case TetrisBusiness.Simple:
                initSpeed = 1000;
                radix = 1.0;
                break;
            case TetrisBusiness.Normal:
                initSpeed = 800;
                radix = 0.8;
                break;
            case TetrisBusiness.Hard:
                initSpeed = 600;
                radix = 0.5;
                break;
            }

             //分数越高，速度越快
            if (gameView.gameScore % 10 === 0 && gameView.gameScore > 0) {
                gameView.gameSpeed *= radix;
            }
            else {
                if (gameView.gameScore <= 0) {
                    gameView.gameSpeed = initSpeed;
                }
            }
        }
        gameSpeedComboBox.editText = "%1".arg(gameView.gameSpeed);
    }
}
