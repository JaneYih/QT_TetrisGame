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
        MyTableView {
            id: scoreHistoryTable
            width: scoreView.width * 0.9
            height: scoreView.height * 0.6
            model: scoreHistoryModelInstance
            functionButton.imageSource: "qrc:/img/refresh.png"
            functionButton.mouseArea.onClicked: {
                businessInstance.refreshScoreHistoryData();
                //scoreHistoryTable.refresh();
            }
            columnHeaderNameFunc: function (index) {
                return scoreHistoryTable.model.headerData(index, Qt.Horizontal, Qt.DisplayRole);
            }
            rowHeaderNameFunc: function (index) {
                return scoreHistoryTable.model.headerData(index, Qt.Vertical, Qt.DisplayRole);
            }
            onVisibleChanged: {
                if (scoreHistoryTable.visible) {
                    businessInstance.refreshScoreHistoryData();
                    scoreText.text = businessInstance.currentScore;
                }
            }
        }
    }

    Connections {
        target: businessInstance
        onCurrentScoreChanged: {
            scoreText.text = businessInstance.currentScore;
        }
    }
}

