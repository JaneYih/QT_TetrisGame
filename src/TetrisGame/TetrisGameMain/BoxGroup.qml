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
    property var boxArray: [ //小方块二维数组
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null],
        [null, null, null, null]
    ]
    property Component oneboxComponent: null //小方块组件
    property int oneBoxEdgeLength: 20 //小方块边长
    property point anchorRotate: Qt.point(0, 0) //旋转锚点

    //旋转锚点标记
    Rectangle {
        id: anchorRotatePoint
        x: anchorRotate.x
        y: anchorRotate.y
        height: 3
        width: 3
        color: "blue"
        visible: true
    }

    Component.onCompleted: {

    }

    onGroupTypeChanged: {
        createBoxGroup(boxGroup.groupType);
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

    function createBoxGroupShape_I(){
        for (var row = 0; row < boxArray.length; row++){
            var colLength = boxArray[row].length;
            for (var col = 0; col < colLength; col++){
                if (row === 0) {
                    createOneBox(row, col);
                }
                else {
                    destroyOneBox(row, col);
                }
            }
        }
        boxGroup.width = oneBoxEdgeLength * 4;
        boxGroup.height = oneBoxEdgeLength * 1;
        boxGroup.anchorRotate = Qt.point(oneBoxEdgeLength*2, 0);
    }

    function createBoxGroupShape_J(){
        for (var row = 0; row < boxArray.length; row++){
            var colLength = boxArray[row].length;
            for (var col = 0; col < colLength; col++){
                if ((row === 0 && col === 1)
                    || (row === 1 && col === 1)
                    || (row === 2 && col === 0)
                    || (row === 2 && col === 1)){
                    createOneBox(row, col);
                }
                else {
                    destroyOneBox(row, col);
                }
            }
        }
        boxGroup.width = oneBoxEdgeLength * 2;
        boxGroup.height = oneBoxEdgeLength * 3;
        boxGroup.anchorRotate = Qt.point(oneBoxEdgeLength, oneBoxEdgeLength*2);
    }
    function createBoxGroupShape_L(){
        for (var row = 0; row < boxArray.length; row++){
            var colLength = boxArray[row].length;
            for (var col = 0; col < colLength; col++){
                if ((row === 0 && col === 0)
                    || (row === 1 && col === 0)
                    || (row === 2 && col === 0)
                    || (row === 2 && col === 1)){
                    createOneBox(row, col);
                }
                else {
                    destroyOneBox(row, col);
                }
            }
        }
        boxGroup.width = oneBoxEdgeLength * 2;
        boxGroup.height = oneBoxEdgeLength * 3;
        boxGroup.anchorRotate = Qt.point(oneBoxEdgeLength, oneBoxEdgeLength*2);
    }
    function createBoxGroupShape_O(){
        for (var row = 0; row < boxArray.length; row++){
            var colLength = boxArray[row].length;
            for (var col = 0; col < colLength; col++){
                if ((row === 0 && col === 0)
                    || (row === 0 && col === 1)
                    || (row === 1 && col === 0)
                    || (row === 1 && col === 1)){
                    createOneBox(row, col);
                }
                else {
                    destroyOneBox(row, col);
                }
            }
        }
        boxGroup.width = oneBoxEdgeLength * 2;
        boxGroup.height = oneBoxEdgeLength * 2;
        boxGroup.anchorRotate = Qt.point(oneBoxEdgeLength, oneBoxEdgeLength);
    }
    function createBoxGroupShape_S(){
        for (var row = 0; row < boxArray.length; row++){
            var colLength = boxArray[row].length;
            for (var col = 0; col < colLength; col++){
                if ((row === 0 && col === 1)
                    || (row === 0 && col === 2)
                    || (row === 1 && col === 0)
                    || (row === 1 && col === 1)){
                    createOneBox(row, col);
                }
                else {
                    destroyOneBox(row, col);
                }
            }
        }
        boxGroup.width = oneBoxEdgeLength * 3;
        boxGroup.height = oneBoxEdgeLength * 2;
        boxGroup.anchorRotate = Qt.point(oneBoxEdgeLength, oneBoxEdgeLength);
    }
    function createBoxGroupShape_T(){
        for (var row = 0; row < boxArray.length; row++){
            var colLength = boxArray[row].length;
            for (var col = 0; col < colLength; col++){
                if ((row === 0 && col === 0)
                    || (row === 0 && col === 1)
                    || (row === 0 && col === 2)
                    || (row === 1 && col === 1)){
                    createOneBox(row, col);
                }
                else {
                    destroyOneBox(row, col);
                }
            }
        }
        boxGroup.width = oneBoxEdgeLength * 3;
        boxGroup.height = oneBoxEdgeLength * 2;
        boxGroup.anchorRotate = Qt.point(oneBoxEdgeLength, oneBoxEdgeLength);
    }
    function createBoxGroupShape_Z(){
        for (var row = 0; row < boxArray.length; row++){
            var colLength = boxArray[row].length;
            for (var col = 0; col < colLength; col++){
                if ((row === 0 && col === 0)
                    || (row === 0 && col === 1)
                    || (row === 1 && col === 1)
                    || (row === 1 && col === 2)){
                    createOneBox(row, col);
                }
                else {
                    destroyOneBox(row, col);
                }
            }
        }
        boxGroup.width = oneBoxEdgeLength * 3;
        boxGroup.height = oneBoxEdgeLength * 2;
        boxGroup.anchorRotate = Qt.point(oneBoxEdgeLength, oneBoxEdgeLength);
    }

    function createBoxGroupShape_Random(){
        var now = new Date();
        var rand =  Math.random(now.getSeconds()) * 10 + 1; //1~10随机数
        var typeNum = rand % (BoxGroup.BoxShape.Shape_Random - 1);
        boxGroup.groupType = typeNum + 1;
    }

    function createOneBox(row, col){
        if (oneboxComponent === null){
            oneboxComponent = Qt.createComponent("OneBox.qml");
        }

        if (boxArray[row][col] === null){
            if (oneboxComponent.status === Component.Ready){
                  boxArray[row][col] = oneboxComponent.createObject(boxGroup, {x: 0, y: 0, edgeLength: boxGroup.oneBoxEdgeLength});
            }
            else{
                return false;
            }
        }

        if (boxArray[row][col] !== null){
            boxArray[row][col].x = boxGroup.oneBoxEdgeLength * col;
            boxArray[row][col].y = boxGroup.oneBoxEdgeLength * row;
        }
        return true;
    }


    function destroyOneBox(row, col){
        if (boxArray[row][col] !== null){
            boxArray[row][col].destroy();
            boxArray[row][col] = null;
        }
    }

    function destroyBoxGroupRow(row){
        var rowData = boxArray[row];
        if (rowData !== null){
            for (var col = 0; col < rowData.length; col++){
                destroyOneBox(row, col);
            }
        }
    }

    function destroyBoxGroup(){
        for (var row = 0; row < boxArray.length; row++){
            var rowData = boxArray[row];
            if (rowData !== null){
                for (var col = 0; col < rowData.length; col++){
                    destroyOneBox(row, col);
                }
            }
        }
    }

    function moveUp(stepCount){

    }
    function moveDown(stepCount){

    }
    function moveLeft(stepCount){

    }
    function moveRight(stepCount){

    }
    function moveRotate() {
        boxGroup.transformOrigin.x = boxGroup.anchorRotate.x;
        boxGroup.transformOrigin.y = boxGroup.anchorRotate.y;

        var r = boxGroup.rotation;
        r += 90;
        r = r >= 360 ? 0 : r;
        boxGroup.rotation = r;
    }
}





