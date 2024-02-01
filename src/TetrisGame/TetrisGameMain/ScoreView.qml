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
            property var rowHeaderHeight: 50 //行表头高度
            property var columnHeaderWidth: 50 //列表头宽度
            property var rowColumnSpacing: 3 //行列间隙
            property var movementStartedContentX: 0
            property var movementStartedContentY: 0

            //表格内容
            TableView {
                id: scoreTableView
                anchors.fill: parent
                anchors.topMargin: tableViewArea.rowHeaderHeight
                anchors.leftMargin: tableViewArea.columnHeaderWidth
                rowSpacing: tableViewArea.rowColumnSpacing
                columnSpacing: tableViewArea.rowColumnSpacing
                clip: true
                model: scoreHistoryModelInstance
                delegate: scoreTableCellDelegate

                onMovementStarted: {
                    tableViewArea.movementStartedContentX = contentX;
                    tableViewArea.movementStartedContentY = contentY;
                }

                onMovementEnded: {
                    var xVelocity = tableViewArea.movementStartedContentX - contentX;
                    var yVelocity = tableViewArea.movementStartedContentY - contentY;
                    columnHeaderItem.x += xVelocity;
                }
            }

            //表格内单元格委托
            Component {
                id: scoreTableCellDelegate
                Rectangle {
                    implicitWidth: 230
                    implicitHeight: 60
                    color: "transparent"
                    border.color: "white"
                    border.width: 1
                    clip: true
                    Text {
                        id: text
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

                implicitWidth: tableViewArea.width
                implicitHeight: 50
                color: "transparent"
                border.color: "red"
                border.width: 1
                clip: true

                Rectangle {
                    id: columnHeaderItem
                    width: columnHeaderRow.width;
                    height: columnHeaderRow.height
                    x: 0
                    y: 0
                    color: "transparent"
                    clip: true
                    z: 5
                    Row {
                        id: columnHeaderRow
                        spacing: 1
                        Repeater {
                            model: scoreTableView.columns > 0 ? scoreTableView.columns : 0
                            Rectangle {
                                implicitWidth: 230
                                implicitHeight: 50
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
            //...
        }
    }
}
