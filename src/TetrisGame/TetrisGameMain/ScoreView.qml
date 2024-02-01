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
            property var rowHeaderHeight: 50 //行-表头高度
            property var rowHeaderWidth: 50 //行-表头宽度
            property var columnHeaderWidth: 230 //列-表头宽度
            property var rowColumnSpacing: 3 //行列间隙

            //表格内容
            TableView {
                id: scoreTableView
                z: 3
                anchors.fill: parent
                anchors.topMargin: tableViewArea.rowHeaderHeight
                anchors.leftMargin: tableViewArea.rowHeaderWidth
                rowSpacing: tableViewArea.rowColumnSpacing
                columnSpacing: tableViewArea.rowColumnSpacing
                clip: true
                model: scoreHistoryModelInstance
                delegate: scoreTableCellDelegate

                onFlickEnded: {
                    forcedUpdateHeaderPosition();
                }

                onMovementEnded: {
                    forcedUpdateHeaderPosition();
                }

                function forcedUpdateHeaderPosition() {
                    columnHeaderItem.x = columnHeaderItem.originX - (scoreTableView.contentX - scoreTableView.originX);
                    rowHeaderItem.y = rowHeaderItem.originY - (scoreTableView.contentY - scoreTableView.originY);
                 }

                Component.onCompleted: {
                }
            }

            //表格内单元格委托
            Component {
                id: scoreTableCellDelegate
                Rectangle {
                    implicitWidth: tableViewArea.columnHeaderWidth
                    implicitHeight: tableViewArea.rowHeaderHeight
                    color: "transparent"
                    border.color: "white"
                    border.width: 1
                    clip: true
                    Text {
                        id: scoreTableCellText
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: role_display
                        color: "white"
                        font.weight: Font.Bold
                        font.pointSize: 20
                    }
                }
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
                            model: scoreTableView.columns > 0 ? scoreTableView.columns : 0
                            Rectangle {
                                implicitWidth: tableViewArea.columnHeaderWidth
                                implicitHeight: tableViewArea.rowHeaderHeight
                                color: "transparent"
                                border.color: "red"
                                border.width: 1
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    text: scoreHistoryModelInstance.GetHorizontalHeaderName(index)
                                    color: "white"
                                    font.weight: Font.Bold
                                    font.pointSize: 20
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
                            model: scoreTableView.rows > 0 ? scoreTableView.rows : 0
                            Rectangle {
                                implicitWidth: tableViewArea.rowHeaderWidth
                                implicitHeight: tableViewArea.rowHeaderHeight
                                color: "transparent"
                                border.color: "green"
                                border.width: 1
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    text: index
                                    color: "white"
                                    font.weight: Font.Bold
                                    font.pointSize: 20
                                }
                            }
                        }
                    }
               }
            }
        }
    }
}

