import QtQuick 2.3

Item {
    id: boxGroup
    height: 100
    width: 100
    enum BoxShape {
        None = 0,
        Shape_I = 1,
        Shape_J,
        Shape_L,
        Shape_O,
        Shape_S,
        Shape_T,
        Shape_Z,
        Shape_Random
    }
    property int groupType: BoxGroup.BoxShape.None //方块组形状
    property var boxArray: [null, null, null, null]//小方块一维数组
    property var shapePostArray: [ //[4个方块的行列坐标]、[旋转后原点偏移]
        [[0,0], [0,0], [0,0], [0,0], [0,0]], //0度
        [[0,0], [0,0], [0,0], [0,0], [0,0]], //90度
        [[0,0], [0,0], [0,0], [0,0], [0,0]], //180度
        [[0,0], [0,0], [0,0], [0,0], [0,0]]  //270度
    ]
    enum AngleFlag {
        DEG_0 = 0,
        DEG_90 = 1,
        DEG_180 = 2,
        DEG_270 = 3
    }
    property int shapePostIndex: BoxGroup.AngleFlag.DEG_0 //当前旋转序号
    property Component oneboxComponent: null //小方块组件
    property int oneBoxEdgeLength: 10 //小方块边长
    property alias outlineRect: outlineRect
    property alias autoMoveDownTimer: autoMoveDownTimer //自动下落定时器
    property bool enableMove: true
    signal backgroundBoxsLightUp();

    //外边框
    Rectangle {
        id: outlineRect
        anchors.fill: boxGroup
        border.color: "red"
        border.width: 3
        opacity: 0.3
        color: "transparent"
        visible: false
    }

    Component.onCompleted: {

    }

    onOneBoxEdgeLengthChanged: {
        //console.log("onOneBoxEdgeLengthChanged");
        createBoxGroup(groupType);
    }

    onGroupTypeChanged: {
        //console.log("onGroupTypeChanged");
        createBoxGroup(groupType);
    }

    onShapePostIndexChanged: {
        //console.log("onShapePostIndexChanged");
        createBoxGroupShape(boxGroup.shapePostArray[shapePostIndex], false);
    }

    function createBoxGroup(type){
        switch (type){
        case BoxGroup.BoxShape.Shape_I:
            createBoxGroupShape_I();
            break;
        case BoxGroup.BoxShape.Shape_J:
            createBoxGroupShape_J();
            break;
        case BoxGroup.BoxShape.Shape_L:
            createBoxGroupShape_L();
            break;
        case BoxGroup.BoxShape.Shape_O:
            createBoxGroupShape_O();
            break;
        case BoxGroup.BoxShape.Shape_S:
            createBoxGroupShape_S();
            break;
        case BoxGroup.BoxShape.Shape_T:
            createBoxGroupShape_T();
            break;
        case BoxGroup.BoxShape.Shape_Z:
            createBoxGroupShape_Z();
            break;
        case BoxGroup.BoxShape.Shape_Random:
            createBoxGroupShape_Random();
            break;
        case BoxGroup.BoxShape.None:
            destroyBoxGroup();
            break;
        }
    }

    function createBoxGroupShape(postArray, bInit){
        if (postArray === null) {
            return false;
        }

        var rowMax = 0;
        var colMax = 0;
        for (var i in postArray){
            if (i >= 4){
                if (!bInit){
                    x += oneBoxEdgeLength * postArray[i][0];
                    y += oneBoxEdgeLength * postArray[i][1];
                }
            }
            else {
                var row = postArray[i][0];
                rowMax = Math.max(rowMax, row);
                var col = postArray[i][1];
                colMax = Math.max(colMax, col);
                if (boxArray[i] !== null){
                    boxArray[i].row = row;
                    boxArray[i].col = col;
                    boxArray[i].x = col * oneBoxEdgeLength;
                    boxArray[i].y = row * oneBoxEdgeLength;
                    boxArray[i].edgeLength = oneBoxEdgeLength;
                }
                else {
                    boxArray[i] = createOneBox(row, col);
                }
            }
        }

        width = oneBoxEdgeLength * (colMax+1);
        height = oneBoxEdgeLength * (rowMax+1);
        return true;
    }

    function setShapeDEGPost(deg, points){
        //[4个方块的行列坐标]
        boxGroup.shapePostArray[deg][0][0] = points[0][0];
        boxGroup.shapePostArray[deg][0][1] = points[0][1];

        boxGroup.shapePostArray[deg][1][0] = points[1][0];
        boxGroup.shapePostArray[deg][1][1] = points[1][1];

        boxGroup.shapePostArray[deg][2][0] = points[2][0];
        boxGroup.shapePostArray[deg][2][1] = points[2][1];

        boxGroup.shapePostArray[deg][3][0] = points[3][0];
        boxGroup.shapePostArray[deg][3][1] = points[3][1];

        //[旋转后原点偏移]
        boxGroup.shapePostArray[deg][4][0] = points[4][0];
        boxGroup.shapePostArray[deg][4][1] = points[4][1];
    }

    function createBoxGroupShape_I(){
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,   [[0,0],[0,1],[0,2],[0,3],  [-1,1]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90,  [[0,0],[1,0],[2,0],[3,0],  [1,-1]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180, [[0,0],[0,1],[0,2],[0,3],  [-1,1]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_270, [[0,0],[1,0],[2,0],[3,0],  [1,-1]]);
        createBoxGroupShape(boxGroup.shapePostArray[shapePostIndex], true);
    }

    function createBoxGroupShape_J(){
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,   [[0,1],[1,1],[2,0],[2,1],  [1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90,  [[0,0],[1,0],[1,1],[1,2],  [-1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180, [[0,0],[0,1],[1,0],[2,0],  [1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_270, [[0,0],[0,1],[0,2],[1,2],  [-1,0]]);
        createBoxGroupShape(boxGroup.shapePostArray[shapePostIndex], true);
    }

    function createBoxGroupShape_L(){
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,   [[0,0],[1,0],[2,0],[2,1],  [1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90,  [[0,0],[0,1],[0,2],[1,0],  [-1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180, [[0,0],[0,1],[1,1],[2,1],  [1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_270, [[0,2],[1,0],[1,1],[1,2],  [-1,0]]);
        createBoxGroupShape(boxGroup.shapePostArray[shapePostIndex], true);
    }

    function createBoxGroupShape_O(){
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,   [[0,0],[0,1],[1,0],[1,1],  [0,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90,  [[0,0],[0,1],[1,0],[1,1],  [0,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180, [[0,0],[0,1],[1,0],[1,1],  [0,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_270, [[0,0],[0,1],[1,0],[1,1],  [0,0]]);
        createBoxGroupShape(boxGroup.shapePostArray[shapePostIndex], true);
    }

    function createBoxGroupShape_S(){
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,   [[0,1],[0,2],[1,0],[1,1],  [-1,1]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90,  [[0,0],[1,0],[1,1],[2,1],  [1,-1]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180, [[0,1],[0,2],[1,0],[1,1],  [-1,1]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_270, [[0,0],[1,0],[1,1],[2,1],  [1,-1]]);
        createBoxGroupShape(boxGroup.shapePostArray[shapePostIndex], true);
    }

    function createBoxGroupShape_T(){
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,   [[0,0],[0,1],[0,2],[1,1],  [0,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90,  [[0,1],[1,0],[1,1],[2,1],  [0,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180, [[0,1],[1,0],[1,1],[1,2],  [0,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_270, [[0,0],[1,0],[1,1],[2,0],  [0,0]]);
        createBoxGroupShape(boxGroup.shapePostArray[shapePostIndex], true);
    }

    function createBoxGroupShape_Z(){
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,   [[0,0],[0,1],[1,1],[1,2],  [-1,1]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90,  [[0,1],[1,0],[1,1],[2,0],  [1,-1]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180, [[0,0],[0,1],[1,1],[1,2],  [-1,1]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_270, [[0,1],[1,0],[1,1],[2,0],  [1,-1]]);
        createBoxGroupShape(boxGroup.shapePostArray[shapePostIndex], true);
    }

    function createBoxGroupShape_Random(){
        var now = new Date();
        var rand =  Math.random(now.getSeconds()) * 10 + 1; //1~10随机数
        var typeNum = rand % (BoxGroup.BoxShape.Shape_Random - 1);
        groupType = typeNum + 1;
    }

    function createOneBox(row, col){
        if (oneboxComponent === null){
            oneboxComponent = Qt.createComponent("OneBox.qml");
        }

        var newBox = null;
        if (oneboxComponent.status === Component.Ready){
            newBox = oneboxComponent.createObject(boxGroup, {x: 0, y: 0});
        }

        if (newBox !== null){
            newBox.edgeLength = oneBoxEdgeLength;
            newBox.row = row;
            newBox.col = col;
            newBox.x = oneBoxEdgeLength * col;
            newBox.y = oneBoxEdgeLength * row;
            newBox.name = "boxUnit_%1_%2".arg(row).arg(col);
        }
        return newBox;
    }

    function destroyOneBox(row, col){
        for (var i in boxArray){
            if (boxArray[i] !== null){
                if (boxArray[i].row === row
                        && boxArray[i].col === col){
                    boxArray[i].destroy();
                    boxArray[i] = null;
                    break;
                }
            }
        }
    }

    function destroyOneBox_v2(index) {
        if (index < boxArray.length) {
            boxArray[index].destroy();
            boxArray[index] = null;
        }
    }

    function destroyBoxGroupRow(row){
        for (var i in boxArray){
            if (boxArray[i] !== null){
                if (boxArray[i].row === row){
                    boxArray[i].destroy();
                    boxArray[i] = null;
                }
            }
        }
    }

    function destroyBoxGroup(){
        for (var i in boxArray){
            if (boxArray[i] !== null){
                boxArray[i].destroy();
                boxArray[i] = null;
            }
        }
    }

    //冻结方块组，禁止移动，转移小方块（释放方块组的小方块，将游戏区域的背景方块点亮）
    function freezeBoxGroup() {
        autoMoveDownTimer.running = false; //停止方块自动下落
        enableMove = false;  //禁止移动
        boxGroup.backgroundBoxsLightUp(); //将游戏区域的背景方块点亮
        destroyBoxGroup();   //释放方块组的小方块
    }

    //上移
    //游戏区域边界矩形:gameAreaRect
    function moveUp(stepCount, gameAreaRect){
        if (enableMove){
            y -= stepCount*oneBoxEdgeLength;
            if (isBeyondBorder(gameAreaRect)){
                y += stepCount*oneBoxEdgeLength;
            }
        }
    }

    //下移
    //游戏区域边界矩形:gameAreaRect
    function moveDown(stepCount, gameAreaRect){
        if (enableMove){
            y += stepCount*oneBoxEdgeLength;
            if (isBeyondBorder(gameAreaRect)){
                y -= stepCount*oneBoxEdgeLength;
                freezeBoxGroup();
            }
        }
    }

    Timer {
        id: autoMoveDownTimer
        interval: 1000
        running: false
        repeat: true
        property var gameRect: null //游戏区域边界矩形
        onTriggered: {
            //console.log("autoMoveDownTimer.onTriggered");
            moveDown(1, gameAreaRect);
        }
    }

    //快速下移（坠落）
    //游戏区域边界矩形:gameAreaRect
     function moveQuickDown(gameAreaRect) {
        //autoMoveDownTimer.gameRect = gameAreaRect;
        autoMoveDownTimer.interval = 10;
     }

    //左移
    //游戏区域边界矩形:gameAreaRect
    function moveLeft(stepCount, gameAreaRect){
        if (enableMove){
            x -= stepCount*oneBoxEdgeLength;
            if (isBeyondBorder(gameAreaRect)){
                x += stepCount*oneBoxEdgeLength;
            }
        }
    }

    //右移
    //游戏区域边界矩形:gameAreaRect
    function moveRight(stepCount, gameAreaRect){
        if (enableMove){
            x += stepCount*oneBoxEdgeLength;
            if (isBeyondBorder(gameAreaRect)){
                x -= stepCount*oneBoxEdgeLength;
            }
        }
    }

    //旋转
    //游戏区域边界矩形:gameAreaRect
    function moveRotate(gameAreaRect) {
        if (enableMove){
            var oldPostIndex = shapePostIndex;
            var postIndex = shapePostIndex;
            postIndex++;
            postIndex = postIndex > BoxGroup.AngleFlag.DEG_270 ? BoxGroup.AngleFlag.DEG_0 : postIndex;
            shapePostIndex = postIndex;

            if (isBeyondBorder(gameAreaRect)){
                shapePostIndex = oldPostIndex;
            }
        }
    }

    //边界触碰检测
    //borderRect表示游戏边界矩形
    function isBeyondBorder(borderRect){
        var left = boxGroup.x;
        var right = boxGroup.x + boxGroup.width;
        var top = boxGroup.y;
        var bottom = boxGroup.y + boxGroup.height;
        if (left < borderRect.left
            || right > borderRect.right
            || top < borderRect.top-3*oneBoxEdgeLength
            || bottom > borderRect.bottom) {
            //console.log("超出边界");
            return true;
        }
        return false;
    }

    //方块碰撞、下落触底
    function boxCrashed(topBoxArray){
        var rowMax = height/oneBoxEdgeLength;
        var colMax = width/oneBoxEdgeLength;
        var boxMatrix = new Array; //方块组的BOX对象矩阵
        for (var j=0; j<rowMax; j++ ){
            var boxRow = new Array;
            for (var k=0; k<colMax; k++ ){
                boxRow.push(null);
            }
            boxMatrix.push(boxRow);
        }

        for (var i in boxArray){
            var row = boxArray[i].row;
            var col = boxArray[i].col;
            var obj = new Object;
            obj.boxArrayIndex = i;
            obj.boxObj = boxArray[i];
            boxMatrix[row][col] = obj;
        }

        //在topBoxArray中选出与方块组同垂直方位的几个box【最好是二次垂直下落不需要执行这个循环，因为垂直方位没有变化】
        var topboxArr = new Array;
        for (var b in topBoxArray) {
            if (b !== null
                 && b.x >= boxGroup.x
                    && b.x < boxGroup.x+boxGroup.width) {
                topboxArr.push(b);
            }
        }
    }
}





