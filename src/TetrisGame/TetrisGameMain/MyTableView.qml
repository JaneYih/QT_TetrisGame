import QtQuick 2.13
import QtQuick.Controls 2.9

Rectangle {
    id: root
    height: 480
    width: 640
    color: "transparent"
    border.color: "white"
    border.width: 1
    clip: true
    property alias model: tableView.model
    property alias refreshButton: refreshButton

    property var columnHeaderNameFunc: null //列表头内容回调函数
    property var rowHeaderNameFunc: null //行表头内容回调函数

    property var rowHeaderCellWidthMin: 40 //行表头单元格宽度（最小值）
    property var rowHeaderCellHeightMin: 38 //行表头单元格高度（最小值）

    property var columnHeaderCellWidthMin: 40 //列表头单元格宽度（最小值）
    property var columnHeaderCellHeightMin: 40 //列表头单元格高度（最小值）

    property var rowColumnSpacing: 3 //行列间隙

    property var textPointSize: 20 //字体大小
    property var contentTextColor: "white" //表格内容字体颜色
    property var contentBorderColor: "darkorchid" //表格内容边框颜色
    property var rowHeaderTextColor: "gold" //行表头字体颜色
    property var rowHeaderBorderColor: "red" //行表头边框颜色
    property var columnHeaderTextColor: "cyan" //列表头字体颜色
    property var columnHeaderBorderColor: "green" //列表头边框颜色

    //左上角刷新按钮
    ImageButton {
        id: refreshButton
        x: 0
        y: 0
        width: rowHeaderArea.width
        height: columnHeaderArea.height
        imageSource: "qrc:/img/refresh.png"
    }

    onWidthChanged: {
        refresh();
    }

    //列表头
    Rectangle {
        id: columnHeaderArea
        x: rowHeaderArea.width
        y: 0
        width: root.width - rowHeaderArea.width
        height: columnHeaderItem.height
        color: "transparent"
        border.color: root.columnHeaderBorderColor
        border.width: 1
        clip: true

        onWidthChanged: {
            root.stretchTableWidth();
        }

        Rectangle {
            id: columnHeaderItem
            x: originX
            y: 0
            width: columnHeaderRow.width
            height: root.columnHeaderCellHeightMin
            color: "transparent"
            clip: false
            property int originX: 0

            Row {
                id: columnHeaderRow
                spacing: root.rowColumnSpacing

                Repeater {
                    id: columnHeaderRepeater
                    model: tableView.columns > 0 ? tableView.columns : 0
                    property var cellHeightMax: 0

                    Rectangle {
                        id: columnHeaderCell
                        implicitWidth: root.columnHeaderCellWidthMin
                        implicitHeight: columnHeaderItem.height
                        color: "transparent"
                        border.color: root.columnHeaderBorderColor
                        border.width: 1
                        clip: false
                        property alias text: columnHeaderCellText.text

                        Text {
                            id: columnHeaderCellText
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: root.columnHeaderNameFunc(index)
                            color: root.columnHeaderTextColor
                            font.weight: Font.Bold
                            font.pointSize: root.textPointSize
                            clip: true

                            onContentWidthChanged: {
                                var curWidth = columnHeaderCellText.contentWidth;
                                if (curWidth < root.columnHeaderCellWidthMin || curWidth === columnHeaderCell.width) {
                                    return;
                                }
                                root.setColumnWidth(index, curWidth);
                            }

                            onContentHeightChanged: {
                                columnHeaderRepeater.cellHeightMax = Math.max(columnHeaderCellText.contentHeight, columnHeaderRepeater.cellHeightMax);
                                if (columnHeaderRepeater.cellHeightMax > columnHeaderItem.height) {
                                    columnHeaderItem.height = columnHeaderRepeater.cellHeightMax;
                                }
                                else {
                                    columnHeaderItem.height = Math.max(columnHeaderRepeater.cellHeightMax, root.columnHeaderCellHeightMin);
                                }
                            }
                        }

                        MouseArea {
                            z: 10
                            width: root.rowColumnSpacing
                            height: columnHeaderCell.height
                            anchors.left: columnHeaderCell.right
                            cursorShape: Qt.SplitHCursor
                            hoverEnabled: false
                            property var pressedX: 0

                            onPressAndHold: {
                                pressedX = mouse.x;
                            }

                            onMouseXChanged: {
                                var offset = mouse.x-pressedX;
                                var curItem = columnHeaderRepeater.itemAt(index);
                                if (-curItem.width+root.columnHeaderCellWidthMin < offset) {
                                    root.adjustColumnWidth(index, offset);
                                    tableView.forceLayout();
                                }
                            }
                        }
                    }

                    onCountChanged: {
                        //表格单元格宽度数组初始化
                        tableView.columnWidths.length = 0;
                        for (var i=0; i<columnHeaderRepeater.count; i++) {
                            tableView.columnWidths.push(columnHeaderRepeater.itemAt(i).width);
                        }
                    }
                }
            }
        }
    }

    //行表头
    Rectangle {
        id: rowHeaderArea
        x: 0
        y: columnHeaderArea.height
        width: rowHeaderItem.width
        height: root.height - columnHeaderArea.height
        color: "transparent"
        border.color: root.rowHeaderBorderColor
        border.width: 1
        clip: true

        Rectangle {
            id: rowHeaderItem
            x: 0
            y: originY
            width: root.rowHeaderCellWidthMin
            height: rowHeaderRow.height
            color: "transparent"
            clip: false
            property int originY: 0

            Column {
                id: rowHeaderRow
                spacing: root.rowColumnSpacing
                Repeater {
                    id: rowHeaderRepeater
                    model: tableView.rows > 0 ? tableView.rows : 0
                    property var cellWidthMax: 0

                    Rectangle {
                        id: rowHeaderCell
                        width: rowHeaderItem.width
                        height: root.rowHeaderCellHeightMin
                        color: "transparent"
                        border.color: root.rowHeaderBorderColor
                        border.width: 1
                        clip: false
                        property alias text: rowHeaderCellText.text

                        Text {
                            id: rowHeaderCellText
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: root.rowHeaderNameFunc(index)
                            color: root.rowHeaderTextColor
                            font.weight: Font.Bold
                            font.pointSize: root.textPointSize
                            clip: true

                            onContentWidthChanged: {
                                rowHeaderRepeater.cellWidthMax = Math.max(rowHeaderCellText.contentWidth, rowHeaderRepeater.cellWidthMax);
                                if (rowHeaderRepeater.cellWidthMax > rowHeaderItem.width) {
                                    rowHeaderItem.width = rowHeaderRepeater.cellWidthMax;
                                }
                                else {
                                    rowHeaderItem.width = Math.max(rowHeaderRepeater.cellWidthMax, root.rowHeaderCellWidthMin);
                                }
                            }

                            onContentHeightChanged: {
                                var curheight = rowHeaderCellText.contentHeight;
                                if (curheight < root.rowHeaderCellHeightMin || rowHeaderCell.height === curheight) {
                                    return;
                                }
                                root.setRowHeight(index, curheight);
                            }
                        }

                        MouseArea {
                            z: 10
                            width: rowHeaderCell.width
                            height: root.rowColumnSpacing
                            anchors.top: rowHeaderCell.bottom
                            cursorShape: Qt.SplitVCursor
                            hoverEnabled: false
                            property var pressedY: 0

                            onPressAndHold: {
                                pressedY = mouse.y;
                            }

                            onMouseYChanged: {
                                var offset = mouse.y-pressedY;
                                var curItem = rowHeaderRepeater.itemAt(index);
                                if (-curItem.height+root.rowHeaderCellHeightMin < offset) {
                                    root.adjustRowHeight(index, offset);
                                    tableView.forceLayout();
                                }
                            }
                        }
                    }

                    onCountChanged: {
                        //表格单元格高度数组初始化
                        tableView.rowHeights.length = 0;
                        for (var i=0; i<rowHeaderRepeater.count; i++) {
                            tableView.rowHeights.push(rowHeaderRepeater.itemAt(i).height);
                        }
                    }
                }
            }
       }
    }

    //表格内单元格委托
    Component {
        id: tableCellDelegate
        Rectangle {
            id: tableCell
            implicitWidth: root.columnHeaderCellWidthMin
            implicitHeight: root.rowHeaderCellHeightMin
            color: "transparent"
            border.color: root.contentBorderColor
            border.width: 1
            clip: true

            Text {
                id: tableCellText
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: role_display //"%1".arg(model.row)
                color: root.contentTextColor
                font.weight: Font.Bold
                font.pointSize: root.textPointSize

                onContentHeightChanged: {
                    setRowHeightByTextHeight();
                }

                onContentWidthChanged: {
                    setColumnWidthByTextWidth();
                }
            }

            TableView.onReused: {
                setRowHeightByTextHeight();
                setColumnWidthByTextWidth();
            }

            //单元格高度随内容调整(由小变大)，不能有大变小，不然手动拖拽拉大后，又会自动变回文本高度
            function setRowHeightByTextHeight() {
                var index = model.row;
                if (index < 0) {
                    return;
                }
                var curHeight = tableCellText.contentHeight;
                if (curHeight > root.rowHeaderCellHeightMin
                        && curHeight > tableView.rowHeights[index]) {
                    setRowHeight(index, curHeight);
                }
            }

            //单元格宽度随内容调整(由小变大)，不能有大变小，不然手动拖拽拉大后，又会自动变回文本宽度
            function setColumnWidthByTextWidth() {
                var index = model.column;
                if (index < 0) {
                    return;
                }

                var curWidth = tableCellText.contentWidth;
                if (curWidth > root.columnHeaderCellWidthMin
                        && curWidth > tableView.columnWidths[index]) {
                    setColumnWidth(index, curWidth);
                }

                if (tableView.columnWidths.length-1 === index) {
                    stretchTableWidth(); //利用右侧空白部分扩宽各行的宽度
                }
            }
        }
    }

    //表格内容
    TableView {
        id: tableView
        anchors.fill: parent
        anchors.topMargin: columnHeaderArea.height
        anchors.leftMargin: rowHeaderArea.width
        rowSpacing: root.rowColumnSpacing
        columnSpacing: root.rowColumnSpacing
        clip: true
        delegate: tableCellDelegate
        reuseItems: true
        model: null

        property var columnWidths: []
        columnWidthProvider: function (column) { return columnWidths[column] }
        property var rowHeights: []
        rowHeightProvider: function (row) { return rowHeights[row] }

        onContentXChanged: {
            columnHeaderItem.x = columnHeaderItem.originX - (tableView.contentX - tableView.originX);
        }

        onContentYChanged: {
            rowHeaderItem.y = rowHeaderItem.originY - (tableView.contentY - tableView.originY);
        }
    }

    Connections {
        target: tableView.model

        onDataChanged: {
            //void dataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = QVector<int>());
            root.refresh();
            console.log("onDataChanged");
        }

        onHeaderDataChanged: {
            //void headerDataChanged(Qt::Orientation orientation, int first, int last);
            console.log("onHeaderDataChanged");
            root.refresh();
        }

        onAllDataUpdated: {
            console.log("onAllDataUpdated");
            root.refresh();
        }
    }

    function setColumnWidth(index, width) {
        if (index < 0) {
            return;
        }

        if (index < columnHeaderRepeater.count) {
            var header = columnHeaderRepeater.itemAt(index);
            /*if (header.width > width) {
                width = header.width;
            }
            else {*/
                header.width = width; //列表头宽度修改
            //}
        }

        if (index < tableView.columnWidths.length) {
            tableView.columnWidths[index] = width; //表格内容宽度修改
        }
    }

    function adjustColumnWidth(index, offsetWidth) {
        if (index < 0) {
            return;
        }

        if (index < columnHeaderRepeater.count) {
            columnHeaderRepeater.itemAt(index).width += offsetWidth; //表头宽度
        }

        if (index < tableView.columnWidths.length) {
            tableView.columnWidths[index] += offsetWidth; //内容宽度
        }
    }

    function setRowHeight(index, height) {
        if (index < 0) {
            return;
        }

        if (index < rowHeaderRepeater.count) {
            var header = rowHeaderRepeater.itemAt(index);
            /*if (header.height > height) {
                height = header.height;
            }
            else {*/
                header.height = height; //行表头高度修改
            //}
        }

        if (index < tableView.rowHeights.length) {
            tableView.rowHeights[index] = height; //表格内容高度修改
        }
    }

    function adjustRowHeight(index, offsetHeight) {
        if (index < 0) {
            return;
        }

        if (index < rowHeaderRepeater.count) {
            rowHeaderRepeater.itemAt(index).height += offsetHeight;
        }

        if (index < tableView.rowHeights.length) {
            tableView.rowHeights[index] += offsetHeight;
        }
    }

    //利用右侧空白部分扩宽各行的宽度
    function stretchTableWidth() {
        var newContentWidth = 0;
        //for (var i=0; i<columnHeaderRepeater.count; i++) {
        for (var i in tableView.columnWidths) {
            newContentWidth += tableView.columnWidths[i]; //columnHeaderRepeater.itemAt(i).width;
            newContentWidth += tableView.columnSpacing;
        }
        newContentWidth -= tableView.columnSpacing;
        //console.log("newContentWidth: %1".arg(newContentWidth));

        var areaWidth = root.width - rowHeaderArea.width;
        //console.log("root.width: %1".arg(root.width));
        //console.log("rowHeaderArea.width: %1".arg(rowHeaderArea.width));
        //console.log("areaWidth: %1".arg(areaWidth));

        if (newContentWidth < areaWidth && tableView.columnWidths.length > 0) {
            var offset = (areaWidth - newContentWidth) / tableView.columnWidths.length;
            for (var j in tableView.columnWidths) {
                adjustColumnWidth(j, offset);
            }
        }
    }

    function updateColumnHeaderText() {
        columnHeaderRepeater.cellHeightMax = 0;
        //仅更新列表头内容，表头布局会随内容变化而更新
        for (var i=0; i<columnHeaderRepeater.count; i++) {
            columnHeaderRepeater.itemAt(i).text = "";
            columnHeaderRepeater.itemAt(i).text = root.columnHeaderNameFunc(i);
        }
    }

    function updateRowHeaderText() {
        rowHeaderRepeater.cellWidthMax = 0;
        //仅更新列表头内容，表头布局会随内容变化而更新
        for (var i=0; i<rowHeaderRepeater.count; i++) {
            rowHeaderRepeater.itemAt(i).text = "";
            rowHeaderRepeater.itemAt(i).text = root.rowHeaderNameFunc(i);
        }
    }


    //刷新
    function refresh() {
        //表头内容更新
        updateRowHeaderText();
        updateColumnHeaderText();

        //刷新表格布局
        tableView.contentX = 0;
        tableView.contentY = 0;
        tableView.forceLayout();

        stretchTableWidth();
        tableView.forceLayout();
    }

    Timer {
        id: forceLayoutTimer
        interval: 200
        running: false
        repeat: true
        onTriggered: {
            if (tableView !== null) {
                //为了避免警告：forceLayout(): Cannot do an immediate re-layout during an ongoing layout!
                //将forceLayout放在定时器中调用
                tableView.forceLayout();
            }
        }
    }
    onVisibleChanged: { //控件重新显示时，启动定时器进行表格布局刷新
        forceLayoutTimer.running = root.visible;
    }
}

