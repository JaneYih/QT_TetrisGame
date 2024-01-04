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
    property int oneBoxEdgeLength: 20 //小方块边长
    //property point anchorRotate: Qt.point(0, 0) //旋转锚点
    property alias outlineRect: outlineRect

    /*//旋转锚点标记
    Rectangle {
        id: anchorRotatePoint
        x: anchorRotate.x
        y: anchorRotate.y
        height: 3
        width: 3
        color: "blue"
        visible: true
    }*/
    //外边框
    Rectangle {
        id: outlineRect
        anchors.fill: boxGroup
        border.color: "red"
        border.width: 3
        opacity: 0.3
        color: "transparent"
        visible: true
    }

    Component.onCompleted: {

    }

    onGroupTypeChanged: {
        createBoxGroup(groupType);
    }

    onShapePostIndexChanged: {
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
                }
                else {
                    boxArray[i] = createOneBox(row, col);
                }
            }
        }

        width = oneBoxEdgeLength * (colMax+1);
        height = oneBoxEdgeLength * (rowMax+1);
        //anchorRotate = Qt.point(oneBoxEdgeLength*2, 0);
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
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,   [[0,0],[0,1],[0,2],[0,3],  [-2,2]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90,  [[0,0],[1,0],[2,0],[3,0],  [2,-2]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180, [[0,0],[0,1],[0,2],[0,3],  [-2,2]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_270, [[0,0],[1,0],[2,0],[3,0],  [2,-2]]);
        createBoxGroupShape(boxGroup.shapePostArray[shapePostIndex], true);
    }

    function createBoxGroupShape_J(){
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,   [[0,1],[1,1],[2,0],[2,1],  [1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90,  [[0,0],[1,0],[1,1],[1,2],  [0,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180, [[0,0],[0,1],[1,0],[2,0],  [0,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_270, [[0,0],[0,1],[0,2],[1,2],  [-1,0]]);
        createBoxGroupShape(boxGroup.shapePostArray[shapePostIndex], true);
    }

    function createBoxGroupShape_L(){
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,   [[0,0],[1,0],[2,0],[2,1],  [1,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90,  [[0,0],[0,1],[0,2],[1,0],  [0,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180, [[0,0],[0,1],[1,1],[2,1],  [0,0]]);
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
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_0,   [[0,0],[0,1],[0,2],[1,1],  [-1,1]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_90,  [[0,1],[1,0],[1,1],[2,1],  [0,-1]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_180, [[0,1],[1,0],[1,1],[1,2],  [0,0]]);
        setShapeDEGPost(BoxGroup.AngleFlag.DEG_270, [[0,0],[1,0],[1,1],[2,0],  [1,0]]);
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
            newBox = oneboxComponent.createObject(boxGroup, {x: 0, y: 0, edgeLength: oneBoxEdgeLength});
        }

        if (newBox !== null){
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

    function moveUp(stepCount){
        y -= stepCount*oneBoxEdgeLength;
    }

    function moveDown(stepCount){
        y += stepCount*oneBoxEdgeLength;
    }

    function moveLeft(stepCount){
        x -= stepCount*oneBoxEdgeLength;
    }

    function moveRight(stepCount){
        x += stepCount*oneBoxEdgeLength;
    }

    function moveRotate() {
        /*var r = rotationItem.angle;
        r += 90;
        r = r >= 360 ? 0 : r;
        rotationItem.angle = r;
        rotationItem.origin.x = anchorRotate.x;
        rotationItem.origin.y = anchorRotate.y;
        boxGroup.transform = rotationItem;
        console.log("anchorRotatePoint:x=%2,y=%3".arg(anchorRotate.x).arg(anchorRotate.y));*/

        var r = shapePostIndex;
        r++;
        r = r > BoxGroup.AngleFlag.DEG_270 ? BoxGroup.AngleFlag.DEG_0 : r;
        shapePostIndex = r;

        for (var i in boxGroup.children){
            var curChild = boxGroup.children[i];
            var name = "%1".arg(curChild.name);
            if (name.indexOf("boxUnit") !== -1){
                console.log("%1:x=%2,y=%3".arg(name).arg(curChild.x).arg(curChild.y));
            }
        }
    }
    /*//旋转-对象
    Rotation {
        id: rotationItem
        angle: 0
    }*/
}





