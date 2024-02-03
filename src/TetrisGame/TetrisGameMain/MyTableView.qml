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

    property var rowHeaderWidth: 50 //行表头宽度
    property var rowHeaderHeightDef: 50 //行表头高度（默认值）
    property var columnHeaderWidthDef: 50 //列表头宽度（默认值）
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

        Component.onCompleted: {
        }

        //model数据更新信号槽
        Connections {
            target: tableView.model
            onDataUpdated: {
                root.refresh();
            }
        }
    }

    //表格内单元格委托
    Component {
        id: tableCellDelegate
        Rectangle {
            id: tableCell
            implicitWidth: root.columnHeaderWidthDef
            implicitHeight: root.rowHeaderHeightDef
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

                //单元格高度随内容调整(取最大)
                onContentHeightChanged: {
                    var index = model.row;
                    if (index < 0) {
                        return;
                    }
                    if (tableCellText.contentHeight > tableView.rowHeights[index]) {
                        setRowHeight(index, tableCellText.contentHeight);
                        //tableView.forceLayout();
                    }
                }

                //单元格宽度随内容调整(取最大)
                onContentWidthChanged: {
                    var index = model.column;
                    if (index < 0) {
                        return;
                    }
                    if (tableCellText.contentWidth > tableView.columnWidths[index]) {
                        setColumnWidth(index, tableCellText.contentWidth);
                        //为了避免警告：forceLayout(): Cannot do an immediate re-layout during an ongoing layout!
                        //将forceLayout在定时器中调用，控件首次显示时进行forceLayout
                        //tableView.forceLayout();

                        //利用右侧空白部分扩宽各行的宽度
                        if (tableView.columnWidths.length-1 === index) {
                            stretchTableWidth();
                        }
                    }
                }

            }
        }
    }

    //列表头
    Rectangle {
        id: columnHeaderArea
        x: rowHeaderArea.width
        y: 0
        implicitWidth: root.width - rowHeaderArea.width
        implicitHeight: columnHeaderItem.height
        color: "transparent"
        border.color: root.columnHeaderBorderColor
        border.width: 1
        clip: true

        Rectangle {
            id: columnHeaderItem
            x: originX
            y: 0
            width: columnHeaderRow.width
            height: columnHeaderRow.height
            color: "transparent"
            clip: false
            property int originX: 0

            Row {
                id: columnHeaderRow
                spacing: root.rowColumnSpacing

                Repeater {
                    id: columnHeaderRepeater
                    model: tableView.columns > 0 ? tableView.columns : 0

                    Rectangle {
                        id: columnHeaderCell
                        implicitWidth: root.columnHeaderWidthDef
                        implicitHeight: root.rowHeaderHeightDef
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
                                if (columnHeaderCellText.contentWidth > tableView.columnWidths[index]) {
                                    root.setColumnWidth(index, columnHeaderCellText.contentWidth);
                                }
                            }

                            onContentHeightChanged: {
                                if (columnHeaderCellText.contentHeight > columnHeaderItem.height
                                        && columnHeaderItem.height > 10) {
                                    for (var i=0; i<columnHeaderRepeater.count; i++) {
                                        columnHeaderRepeater.itemAt(i).height = columnHeaderCellText.contentHeight;
                                    }
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
                                if (-curItem.width+10 < offset) {
                                    root.adjustColumnWidth(index, offset);
                                    tableView.forceLayout();
                                }
                            }
                        }
                    }

                    onCountChanged: {
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
        implicitWidth: rowHeaderItem.width
        implicitHeight: root.height - columnHeaderArea.height
        color: "transparent"
        border.color: root.rowHeaderBorderColor
        border.width: 1
        clip: true

        Rectangle {
            id: rowHeaderItem
            x: 0
            y: originY
            width: rowHeaderRow.width;
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

                    Rectangle {
                        id: rowHeaderCell
                        implicitWidth: root.rowHeaderWidth
                        implicitHeight: root.rowHeaderHeightDef
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
                                if (rowHeaderCellText.contentWidth > rowHeaderItem.width
                                        && rowHeaderItem.width > 10) {
                                    for (var i=0; i<rowHeaderRepeater.count; i++) {
                                        rowHeaderRepeater.itemAt(i).width = rowHeaderCellText.contentWidth;
                                    }
                                }
                            }

                            onContentHeightChanged: {
                                if (rowHeaderCellText.contentHeight > tableView.rowHeights[index]) {
                                    root.setRowHeight(index, rowHeaderCellText.contentHeight);
                                }
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

                            onMouseXChanged: {
                                var offset = mouse.y-pressedY;
                                var curItem = rowHeaderRepeater.itemAt(index);
                                if (-curItem.height+10 < offset) {
                                    root.adjustRowHeight(index, offset);
                                    tableView.forceLayout();
                                }
                            }
                        }
                    }

                    onCountChanged: {
                        tableView.rowHeights.length = 0;
                        for (var i=0; i<rowHeaderRepeater.count; i++) {
                            tableView.rowHeights.push(rowHeaderRepeater.itemAt(i).height);
                        }
                    }
                }
            }
       }
    }

    function setColumnWidth(index, width) {
        columnHeaderRepeater.itemAt(index).width = width; //列表头宽度修改
        tableView.columnWidths[index] = width; //表格内容宽度修改
    }
    function adjustColumnWidth(index, offsetWidth) {
        columnHeaderRepeater.itemAt(index).width += offsetWidth; //表头宽度
        tableView.columnWidths[index] += offsetWidth; //内容宽度
    }
    function setRowHeight(index, height) {
        rowHeaderRepeater.itemAt(index).height = height; //行表头高度修改
        tableView.rowHeights[index] = height; //表格内容高度修改
    }
    function adjustRowHeight(index, offsetHeight) {
        rowHeaderRepeater.itemAt(index).height += offsetHeight;
        tableView.rowHeights[index] += offsetHeight;
    }

    //利用右侧空白部分扩宽各行的宽度
    function stretchTableWidth() {
        var newContentWidth = 0;
        for (var i in tableView.columnWidths) {
            newContentWidth += tableView.columnWidths[i];
            newContentWidth += tableView.columnSpacing;
        }
        newContentWidth -= tableView.columnSpacing;

        var areaWidth = root.width - rowHeaderArea.width;
        if (newContentWidth < areaWidth && tableView.columnWidths.length > 0) {
            var offset = (areaWidth - newContentWidth) / tableView.columnWidths.length;
            for (var j in tableView.columnWidths) {
                adjustColumnWidth(j, offset);
            }
        }
    }

    //刷新
    function refresh() {
        //仅更新列表头内容，表头布局会随内容变化而更新
        for (var i=0; i<columnHeaderRepeater.count; i++) {
            columnHeaderRepeater.itemAt(i).text = root.columnHeaderNameFunc(i);
        }

        //刷新表格布局
        tableView.contentX = 0;
        tableView.contentY = 0;
        tableView.forceLayout();
    }

    Timer {
        id: initRefreshTableTimer
        interval: 300
        running: false
        repeat: false
        onTriggered: {
            root.refresh();
        }
    }
    onVisibleChanged: { //控件重新显示时，启动定时器进行表格布局刷新
        initRefreshTableTimer.running = root.visible;
    }
}

