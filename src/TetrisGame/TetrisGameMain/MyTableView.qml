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
    property var rowHeaderWidth: 50 //行-表头宽度
    property var rowHeaderHeightDef: 50 //行-表头高度（默认值）
    property var columnHeaderWidthDef: 30 //列-表头宽度（默认值）
    property var rowColumnSpacing: 3 //行列间隙

    //左上角刷新按钮
    ImageButton {
        id: refreshButton
        width: rowHeaderArea.width
        height: columnHeaderArea.height
        imageSource: "qrc:/img/refresh.png"
    }

    //表格内容
    TableView {
        id: tableView
        z: 3
        anchors.fill: parent
        anchors.topMargin: root.rowHeaderHeightDef
        anchors.leftMargin: root.rowHeaderWidth
        rowSpacing: root.rowColumnSpacing
        columnSpacing: root.rowColumnSpacing
        clip: true
        delegate: scoreTableCellDelegate
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

        Connections {
            target: tableView.model
            onDataUpdated: {
                root.refresh();
            }
        }
    }

    //表格内单元格委托
    Component {
        id: scoreTableCellDelegate
        Rectangle {
            id: scoreTableCell
            implicitWidth: root.columnHeaderWidthDef
            implicitHeight: root.rowHeaderHeightDef
            color: "transparent"
            border.color: "white"
            border.width: 1
            clip: true
            Text {
                id: scoreTableCellText
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: role_display //"%1".arg(model.row)
                color: "white"
                font.weight: Font.Bold
                font.pointSize: 20

                //单元格高度随内容调整(取最大)
                onContentHeightChanged: {
                    var index = model.row;
                    if (index < 0) {
                        return;
                    }
                    if (scoreTableCellText.contentHeight > tableView.rowHeights[index]) {
                        //表头高度修改
                        rowHeaderRepeater.itemAt(index).height = scoreTableCellText.contentHeight;
                        //表格内容高度修改
                        tableView.rowHeights[index] = scoreTableCellText.contentHeight;
                        //scoreTableCell.height = scoreTableCellText.contentHeight;
                        //tableView.forceLayout();
                    }
                }

                //单元格宽度随内容调整(取最大)
                onContentWidthChanged: {
                    var index = model.column;
                    if (index < 0) {
                        return;
                    }
                    if (scoreTableCellText.contentWidth > tableView.columnWidths[index]) {
                        //表头宽度修改
                        columnHeaderRepeater.itemAt(index).width = scoreTableCellText.contentWidth;
                        //表格内容宽度修改
                        tableView.columnWidths[index] = scoreTableCellText.contentWidth;
                        //scoreTableCell.width = scoreTableCellText.contentWidth;
                        //tableView.forceLayout();

                        //自动扩宽最后一列的空白部分
                        if (tableView.columnWidths.length-1 === index) {
                            var newContentWidth = 0;
                            for (var i in tableView.columnWidths) {
                                newContentWidth += tableView.columnWidths[i];
                                newContentWidth += tableView.columnSpacing;
                            }
                            newContentWidth -= tableView.columnSpacing;
                            var areaWidth = root.width - rowHeaderArea.width;
                            if (newContentWidth < areaWidth) {
                                var offset = areaWidth - newContentWidth;
                                var subOffset = offset / tableView.columnWidths.length;
                                for (var j in tableView.columnWidths) {
                                    columnHeaderRepeater.itemAt(j).width += subOffset; //表头宽度
                                    tableView.columnWidths[j] += subOffset; //内容宽度
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function refresh() {
        //更新列表头内容
        for (var i=0; i<columnHeaderRepeater.count; i++) {
            columnHeaderRepeater.itemAt(i).text = tableView.model.GetHorizontalHeaderName(i);
        }

        //更新表格内容
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
    onVisibleChanged: { //重新显示时，刷新表格布局
        initRefreshTableTimer.running = root.visible;
    }

    //列表头
    Rectangle {
        id: columnHeaderArea
        x: tableView.x
        y: 0
        z: 4
        implicitWidth: root.width - tableView.x
        implicitHeight: columnHeaderItem.height
        color: "transparent"
        border.color: "red"
        border.width: 1
        clip: true

        Rectangle {
            id: columnHeaderItem
            property int originX: 0
            x: originX
            y: 0
            width: columnHeaderRow.width;
            height: columnHeaderRow.height
            color: "transparent"
            clip: true
            Row {
                id: columnHeaderRow
                spacing: root.rowColumnSpacing
                Repeater {
                    id: columnHeaderRepeater
                    model: tableView.columns > 0 ? tableView.columns : 0
                    Rectangle {
                        property alias text: columnHeaderCellText.text
                        implicitWidth: root.columnHeaderWidthDef
                        implicitHeight: root.rowHeaderHeightDef
                        color: "transparent"
                        border.color: "red"
                        border.width: 1
                        clip: true
                        Text {
                            id: columnHeaderCellText
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: tableView.model.GetHorizontalHeaderName(index)
                            color: "white"
                            font.weight: Font.Bold
                            font.pointSize: 20
                            onContentWidthChanged: {
                                if (columnHeaderCellText.contentWidth > tableView.columnWidths[index]) {
                                    //表头宽度修改
                                    columnHeaderRepeater.itemAt(index).width = columnHeaderCellText.contentWidth;
                                    //表格内容宽度修改
                                    tableView.columnWidths[index] = columnHeaderCellText.contentWidth;
                                }
                            }
                        }
                        Rectangle {
                            anchors.left: parent.right
                            width: root.rowColumnSpacing
                            height: root.rowHeaderHeightDef
                            color: "transparent"
                            border.color: "transparent"
                            border.width: 1
                            //visible: index < columnHeaderRepeater.model-1
                            MouseArea {
                                anchors.fill: parent
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
                                        //表头宽度修改
                                        curItem.width += offset;
                                        //表格内容宽度修改
                                        tableView.columnWidths[index] += offset;
                                        tableView.forceLayout();
                                    }
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
        y: tableView.y
        z: 4
        implicitWidth: root.rowHeaderWidth
        implicitHeight: root.height - tableView.y
        color: "transparent"
        border.color: "green"
        border.width: 1
        clip: true

        Rectangle {
            id: rowHeaderItem
            property int originY: 0
            x: 0
            y: originY
            width: rowHeaderRow.width;
            height: rowHeaderRow.height
            color: "transparent"
            clip: true
            Column {
                id: rowHeaderRow
                spacing: root.rowColumnSpacing
                Repeater {
                    id: rowHeaderRepeater
                    model: tableView.rows > 0 ? tableView.rows : 0
                    Rectangle {
                        implicitWidth: root.rowHeaderWidth
                        implicitHeight: root.rowHeaderHeightDef
                        color: "transparent"
                        border.color: "green"
                        border.width: 1
                        clip: true
                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: index
                            color: "white"
                            font.weight: Font.Bold
                            font.pointSize: 20
                        }
                        Rectangle {
                            anchors.top: parent.bottom
                            width: root.rowHeaderWidth
                            height: root.rowColumnSpacing
                            color: "transparent"
                            border.color: "transparent"
                            border.width: 1
                            //visible: index < rowHeaderRepeater.model-1
                            MouseArea {
                                anchors.fill: parent
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
                                        //表头高度修改
                                        curItem.height += offset;
                                        //表格内容高度修改
                                        tableView.rowHeights[index] += offset;
                                        tableView.forceLayout();
                                    }
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
}

