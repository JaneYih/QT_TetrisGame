import QtQuick 2.9

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
    property var rowCount: 0 //方块组行数
    property var colCount: 0 //方块组列数
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
    property bool isHideBoxs: false
    signal backgroundBoxsLightUp();

    property var gameAreaRect: null //游戏区域矩形
    property var backgroundBoxArray: null //游戏区域背景方块二维数组

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
        //console.log("创建一个方块组");
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

        boxGroup.visible = false; //方块形状生成过程中的隐藏方格组
        var rowMax = 0;
        var colMax = 0;
        for (var i in postArray){
            if (i >= 4){
                if (!bInit){ //调整旋转后的位置
                    x += oneBoxEdgeLength * postArray[i][0];
                    y += oneBoxEdgeLength * postArray[i][1];
                }
            }
            else {
                var row = postArray[i][0];
                rowMax = Math.max(rowMax, row);
                var col = postArray[i][1];
                colMax = Math.max(colMax, col);
                if (boxArray[i] !== null) { //移动小方块
                    boxArray[i].row = row;
                    boxArray[i].col = col;
                    boxArray[i].x = col * oneBoxEdgeLength;
                    boxArray[i].y = row * oneBoxEdgeLength;
                    boxArray[i].edgeLength = oneBoxEdgeLength;
                }
                else {
                    boxArray[i] = createOneBox(row, col); //创建小方块
                }
            }
        }

        boxGroup.rowCount = rowMax+1;
        boxGroup.colCount = colMax+1;
        width = oneBoxEdgeLength * (boxGroup.colCount);
        height = oneBoxEdgeLength * (boxGroup.rowCount);

        showBoxsWhenEnterGameArea(); //超出游戏区域的y的小方块的显示处理
        boxGroup.visible = true; //还原方块组的可见
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
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,  [[0,0],[1,0],[1,1],[1,2],    [-1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90, [[0,0],[0,1],[1,0],[2,0],    [1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180,[[0,0],[0,1],[0,2],[1,2],    [-1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_270,[[0,1],[1,1],[2,0],[2,1],    [1,0]]);
        createBoxGroupShape(boxGroup.shapePostArray[shapePostIndex], true);
    }

    function createBoxGroupShape_L(){
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,  [[0,0],[0,1],[0,2],[1,0],    [-1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90, [[0,0],[0,1],[1,1],[2,1],    [1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180,[[0,2],[1,0],[1,1],[1,2],    [-1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_270,[[0,0],[1,0],[2,0],[2,1],    [1,0]]);
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
        //console.log("释放一个方块组");
    }

    //冻结方块组，禁止移动，转移小方块（释放方块组的小方块，将游戏区域的背景方块点亮）
    function freezeBoxGroup() {
        autoMoveDownTimer.running = false; //停止方块自动下落
        enableMove = false;  //禁止移动
        boxGroup.backgroundBoxsLightUp(); //将游戏区域的背景方块点亮
        destroyBoxGroup();   //释放方块组的小方块
    }

    //上移
    function moveUp(stepCount){
        if (enableMove){
            y -= stepCount*oneBoxEdgeLength;
            if (isCrashed()){
                y += stepCount*oneBoxEdgeLength;
            }
        }
    }

    //下移
    function moveDown(stepCount){
        if (enableMove){
            y += stepCount*oneBoxEdgeLength;
            if (isCrashed()){
                y -= stepCount*oneBoxEdgeLength;
                freezeBoxGroup();
            }
            showBoxsWhenEnterGameArea();
        }
    }

    NumberAnimation {
        id: animation
        target: boxGroup
        property: "y"
        //from: y
        //to: y + stepCount*oneBoxEdgeLength
        duration: 20
        easing.type: Easing.Linear
        running: false
    }

    Timer {
        id: autoMoveDownTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            //console.log("autoMoveDownTimer.onTriggered");
            moveDown(1);
        }
    }

    //快速下移（坠落）
     function moveQuickDown() {
        autoMoveDownTimer.interval = 10;
     }

    //左移
    function moveLeft(stepCount){
        if (enableMove){
            x -= stepCount*oneBoxEdgeLength;
            if (isCrashed()){
                x += stepCount*oneBoxEdgeLength;
            }
        }
    }

    //右移
    function moveRight(stepCount){
        if (enableMove){
            x += stepCount*oneBoxEdgeLength;
            if (isCrashed()){
                x -= stepCount*oneBoxEdgeLength;
            }
        }
    }

    //旋转
    function moveRotate() {
        if (enableMove){
            var oldPostIndex = shapePostIndex;
            var postIndex = shapePostIndex;
            postIndex++;
            postIndex = postIndex > BoxGroup.AngleFlag.DEG_270 ? BoxGroup.AngleFlag.DEG_0 : postIndex;
            shapePostIndex = postIndex;

            if (isCrashed()){
                shapePostIndex = oldPostIndex;
            }
        }
    }

    //设置随机角度的方块
    function setRandomShapePost() {
        var now = new Date();
        var rand =  Math.random(now.getSeconds()) * 10 + 1; //1~10随机数
        var postIndex = rand % (BoxGroup.AngleFlag.DEG_270 - 1);
        shapePostIndex = postIndex + 1;
    }

    //隐藏小方块
    function hideBoxs() {
        for(var i = 0; i < boxArray.length; i++)
        {
            boxArray[i].visible = false;
        }
        boxGroup.isHideBoxs = true;
    }

    //显示小方块---超出游戏区域的y的小方块的显示处理
    function showBoxsWhenEnterGameArea() {
        if (boxGroup.gameAreaRect !== null) {
            if(boxGroup.y <= (boxGroup.gameAreaRect.top + boxGroup.outlineRect.height))
            {
                for(var i = 0; i < boxArray.length; i++)
                {
                    if (boxArray[i] !== null) {
                        if (!boxArray[i].visible) {
                            boxArray[i].visible = (boxGroup.y + boxArray[i].y) >= boxGroup.gameAreaRect.y;
                        }
                    }
                }
            }
        }
    }

    function isCrashed() {
        if (boxGroup.backgroundBoxArray === null
                || boxGroup.gameAreaRect === null){
            return false;  //如果还没传入这两个数据，则不检测碰撞
        }

        return (isBeyondBorder(boxGroup.gameAreaRect)
                || boxMountainCrashed(boxGroup.backgroundBoxArray, boxGroup.gameAreaRect.y, boxGroup.gameAreaRect.x))
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

    //方块与游戏区域背景的点亮方块重叠（即：与方块山的碰撞检测）
    function boxMountainCrashed(backgroundArray, gameAreaY, gameAreaX) {
        var bCrashed = false;
        //var rowIndexMax = height/oneBoxEdgeLength - 1;
        //var colIndexMax = width/oneBoxEdgeLength - 1;

        var originRow = (y - gameAreaY) / oneBoxEdgeLength;
        var originCol = (x - gameAreaX) / oneBoxEdgeLength;
        for (var i in boxArray) {
            var row = originRow + boxArray[i].row;
            var col = originCol + boxArray[i].col;
            if (row >= 0 && col >= 0) {
                if (!backgroundArray[row][col].lightOff) {
                    bCrashed = true;
                    break;
                }
            }
        }
        return bCrashed;
    }
}





