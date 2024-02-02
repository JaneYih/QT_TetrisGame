import QtQuick 2.13
import QtQuick.Controls 2.9
import Yih.Tetris.Business 1.0

Rectangle {
    id: scoreView
    color: "transparent"
    signal skipPage(var viewType);

    Image {
        id: backgroundImage
        anchors.fill: parent
        z: 0
        opacity: 1
        source: "qrc:/img/background02.png"
    }

    ImageButton {
        id: btnSkipGamePage
        z: 2
        width: 30
        height: 30
        visible: true
        anchors.top: parent.top
        anchors.left: parent.left
        imageSource: "qrc:/img/return.png"
        mouseArea.onClicked: {
            skipPage(TetrisBusiness.GameView);
        }
    }

    Column {
        z: 1
        anchors.centerIn: parent
        //spacing: 10

        Text {
            id: scoreText
            width: scoreView.width * 0.9
            height: scoreView.height * 0.3
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("----")
            color: "red"
            font.weight: Font.Black
            font.pointSize: 50
        }


        //历史分数表格
        Rectangle {
            id: tableViewArea
            width: scoreView.width * 0.9
            height: scoreView.height * 0.65
            color: "transparent"
            border.color: "white"
            border.width: 1
            clip: true
            property var rowHeaderWidth: 50 //行-表头宽度
            property var rowHeaderHeightDef: 50 //行-表头高度（默认值）
            property var columnHeaderWidthDef: 30 //列-表头宽度（默认值）
            property var rowColumnSpacing: 3 //行列间隙

            //表格内容
            TableView {
                id: scoreTableView
                z: 3
                anchors.fill: parent
                anchors.topMargin: tableViewArea.rowHeaderHeightDef
                anchors.leftMargin: tableViewArea.rowHeaderWidth
                rowSpacing: tableViewArea.rowColumnSpacing
                columnSpacing: tableViewArea.rowColumnSpacing
                clip: true
                model: scoreHistoryModelInstance
                delegate: scoreTableCellDelegate

                property var columnWidths: []
                columnWidthProvider: function (column) { return columnWidths[column] }

                property var rowHeights: []
                rowHeightProvider: function (row) { return rowHeights[row] }

                onContentXChanged: {
                    columnHeaderItem.x = columnHeaderItem.originX - (scoreTableView.contentX - scoreTableView.originX);
                }

                onContentYChanged: {
                    rowHeaderItem.y = rowHeaderItem.originY - (scoreTableView.contentY - scoreTableView.originY);
                }

                Component.onCompleted: {
                }

                Connections {
                    target: scoreTableView.model
                    onDataUpdated: {
                        tableViewArea.refreshTableView();
                    }
                }
            }

            //表格内单元格委托
            Component {
                id: scoreTableCellDelegate
                Rectangle {
                    id: scoreTableCell
                    implicitWidth: tableViewArea.columnHeaderWidthDef
                    implicitHeight: tableViewArea.rowHeaderHeightDef
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
                            if (scoreTableCellText.contentHeight > scoreTableView.rowHeights[index]) {
                                //表头高度修改
                                rowHeaderRepeater.itemAt(index).height = scoreTableCellText.contentHeight;
                                //表格内容高度修改
                                scoreTableView.rowHeights[index] = scoreTableCellText.contentHeight;
                                //scoreTableCell.height = scoreTableCellText.contentHeight;
                                //scoreTableView.forceLayout();
                            }
                        }

                        //单元格宽度随内容调整(取最大)
                        onContentWidthChanged: {
                            var index = model.column;
                            if (index < 0) {
                                return;
                            }
                            if (scoreTableCellText.contentWidth > scoreTableView.columnWidths[index]) {
                                //表头宽度修改
                                columnHeaderRepeater.itemAt(index).width = scoreTableCellText.contentWidth;
                                //表格内容宽度修改
                                scoreTableView.columnWidths[index] = scoreTableCellText.contentWidth;
                                //scoreTableCell.width = scoreTableCellText.contentWidth;
                                //scoreTableView.forceLayout();

                                //自动扩宽最后一列的空白部分
                                if (scoreTableView.columnWidths.length-1 === index) {
                                    var newContentWidth = 0;
                                    for (var i in scoreTableView.columnWidths) {
                                        newContentWidth += scoreTableView.columnWidths[i];
                                        newContentWidth += scoreTableView.columnSpacing;
                                    }
                                    newContentWidth -= scoreTableView.columnSpacing;
                                    var areaWidth = tableViewArea.width - rowHeaderArea.width;
                                    if (newContentWidth < areaWidth) {
                                        console.log(areaWidth);
                                        console.log(newContentWidth);

                                        var offset = areaWidth - newContentWidth;
                                        columnHeaderRepeater.itemAt(index).width += offset; //表头宽度
                                        scoreTableView.columnWidths[index] += offset; //内容宽度
                                    }
                                }
                            }
                        }
                    }
                }
            }

            //左上角刷新按钮
            ImageButton {
                x: 0
                y: 0
                width: rowHeaderArea.width
                height: columnHeaderArea.height
                imageSource: "qrc:/img/refresh.png"
                mouseArea.onClicked: {
                    tableViewArea.refreshTableView();
                    businessInstance.changeScoreHistoryData();
                }
            }
            function refreshTableView() {
                //更新列表头内容
                for (var i=0; i<columnHeaderRepeater.count; i++) {
                    columnHeaderRepeater.itemAt(i).text = scoreHistoryModelInstance.GetHorizontalHeaderName(i);
                }

                //更新表格内容
                scoreTableView.contentX = 0;
                scoreTableView.contentY = 0;
                scoreTableView.forceLayout();
            }

            Timer {
                id: initRefreshTableTimer
                interval: 300
                running: false
                repeat: false
                onTriggered: {
                    tableViewArea.refreshTableView();
                }
            }
            onVisibleChanged: { //重新显示时，刷新表格布局
                initRefreshTableTimer.running = tableViewArea.visible;
            }

            //列表头
            Rectangle {
                id: columnHeaderArea
                x: scoreTableView.x
                y: 0
                z: 4
                implicitWidth: tableViewArea.width - scoreTableView.x
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
                        spacing: tableViewArea.rowColumnSpacing
                        Repeater {
                            id: columnHeaderRepeater
                            model: scoreTableView.columns > 0 ? scoreTableView.columns : 0
                            Rectangle {
                                property alias text: columnHeaderCellText.text
                                implicitWidth: tableViewArea.columnHeaderWidthDef
                                implicitHeight: tableViewArea.rowHeaderHeightDef
                                color: "transparent"
                                border.color: "red"
                                border.width: 1
                                clip: true
                                Text {
                                    id: columnHeaderCellText
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    text: scoreHistoryModelInstance.GetHorizontalHeaderName(index)
                                    color: "white"
                                    font.weight: Font.Bold
                                    font.pointSize: 20
                                    onContentWidthChanged: {
                                        if (columnHeaderCellText.contentWidth > scoreTableView.columnWidths[index]) {
                                            //表头宽度修改
                                            columnHeaderRepeater.itemAt(index).width = columnHeaderCellText.contentWidth;
                                            //表格内容宽度修改
                                            scoreTableView.columnWidths[index] = columnHeaderCellText.contentWidth;
                                        }
                                    }
                                }
                                Rectangle {
                                    anchors.left: parent.right
                                    width: tableViewArea.rowColumnSpacing
                                    height: tableViewArea.rowHeaderHeightDef
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
                                                scoreTableView.columnWidths[index] += offset;
                                                scoreTableView.forceLayout();
                                            }
                                        }
                                    }
                                }
                            }
                            onCountChanged: {
                                scoreTableView.columnWidths.length = 0;
                                for (var i=0; i<columnHeaderRepeater.count; i++) {
                                    scoreTableView.columnWidths.push(columnHeaderRepeater.itemAt(i).width);
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
                y: scoreTableView.y
                z: 4
                implicitWidth: tableViewArea.rowHeaderWidth
                implicitHeight: tableViewArea.height - scoreTableView.y
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
                        spacing: tableViewArea.rowColumnSpacing
                        Repeater {
                            id: rowHeaderRepeater
                            model: scoreTableView.rows > 0 ? scoreTableView.rows : 0
                            Rectangle {
                                implicitWidth: tableViewArea.rowHeaderWidth
                                implicitHeight: tableViewArea.rowHeaderHeightDef
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
                                    width: tableViewArea.rowHeaderWidth
                                    height: tableViewArea.rowColumnSpacing
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
                                                scoreTableView.rowHeights[index] += offset;
                                                scoreTableView.forceLayout();
                                            }
                                        }
                                    }
                                }
                            }
                            onCountChanged: {
                                scoreTableView.rowHeights.length = 0;
                                for (var i=0; i<rowHeaderRepeater.count; i++) {
                                    scoreTableView.rowHeights.push(rowHeaderRepeater.itemAt(i).height);
                                }
                            }
                        }
                    }
               }
            }
        }
    }
}

