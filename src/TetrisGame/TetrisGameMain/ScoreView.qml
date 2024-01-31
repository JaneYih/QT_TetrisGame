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

        Rectangle {
            id: tableViewArea
            width: scoreView.width * 0.9
            height: scoreView.height * 0.65
            color: "transparent"
            border.color: "white"
            border.width: 1

            TableView {
                id: scoreTableView
                anchors.fill: parent
                rowSpacing: 3
                columnSpacing: 3
                clip: true
                model: scoreHistoryModelInstance
                delegate: scoreTableCellDelegate

                Component.onCompleted: {
                    //打印表格标题
                    console.log(scoreHistoryModelInstance.GetHorizontalHeaderName(0));
                    console.log(scoreHistoryModelInstance.GetHorizontalHeaderName(1));
                    console.log(scoreHistoryModelInstance.GetHorizontalHeaderName(2));
                }
            }
            Component {
                id: scoreTableCellDelegate
                Rectangle {
                    implicitWidth: 230
                    implicitHeight: 60
                    color: "transparent"
                    border.color: "white"
                    border.width: 1
                    Text {
                        id: text
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: scoreHistory
                        color: "white"
                        font.weight: Font.Bold
                        font.pointSize: 20
                    }
                }
            }
        }
    }
}
