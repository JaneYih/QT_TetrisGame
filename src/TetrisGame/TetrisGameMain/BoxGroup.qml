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

    function createBoxGroupShape(postArray){
        if (boxArray.length !== postArray.length){
            return false;
        }

        var rowMax = 0;
        var colMax = 0;
        for (var i in postArray){
            var row = postArray[i].x;
            rowMax = Math.max(rowMax, row);
            var col = postArray[i].y;
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

        width = oneBoxEdgeLength * (colMax+1);
        height = oneBoxEdgeLength * (rowMax+1);
        //anchorRotate = Qt.point(oneBoxEdgeLength*2, 0);
        return true;
    }

    function createBoxGroupShape_I(){
        var postArray = new Array;
        postArray.push(Qt.point(0, 0));
        postArray.push(Qt.point(0, 1));
        postArray.push(Qt.point(0, 2));
        postArray.push(Qt.point(0, 3));
        createBoxGroupShape(postArray);
    }

    function createBoxGroupShape_J(){
        var postArray = new Array;
        postArray.push(Qt.point(0, 1));
        postArray.push(Qt.point(1, 1));
        postArray.push(Qt.point(2, 0));
        postArray.push(Qt.point(2, 1));
        createBoxGroupShape(postArray);
    }

    function createBoxGroupShape_L(){
        var postArray = new Array;
        postArray.push(Qt.point(0, 0));
        postArray.push(Qt.point(1, 0));
        postArray.push(Qt.point(2, 0));
        postArray.push(Qt.point(2, 1));
        createBoxGroupShape(postArray);
    }

    function createBoxGroupShape_O(){
        var postArray = new Array;
        postArray.push(Qt.point(0, 0));
        postArray.push(Qt.point(0, 1));
        postArray.push(Qt.point(1, 0));
        postArray.push(Qt.point(1, 1));
        createBoxGroupShape(postArray);
    }

    function createBoxGroupShape_S(){
        var postArray = new Array;
        postArray.push(Qt.point(0, 1));
        postArray.push(Qt.point(0, 2));
        postArray.push(Qt.point(1, 0));
        postArray.push(Qt.point(1, 1));
        createBoxGroupShape(postArray);
    }

    function createBoxGroupShape_T(){
        var postArray = new Array;
        postArray.push(Qt.point(0, 0));
        postArray.push(Qt.point(0, 1));
        postArray.push(Qt.point(0, 2));
        postArray.push(Qt.point(1, 1));
        createBoxGroupShape(postArray);
    }

    function createBoxGroupShape_Z(){
        var postArray = new Array;
        postArray.push(Qt.point(0, 0));
        postArray.push(Qt.point(0, 1));
        postArray.push(Qt.point(1, 1));
        postArray.push(Qt.point(1, 2));
        createBoxGroupShape(postArray);
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





