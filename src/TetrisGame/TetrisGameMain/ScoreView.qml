import QtQuick 2.9
import QtQuick.Controls 2.13

Rectangle {
    id: scoreView
    color: "transparent"
    //border.color: "transparent"
    //border.color: "red"
    //border.width: 1
    signal skipPage(var viewType);

    Image {
        id: backgroundImage
        anchors.fill: parent
        z: 0
        opacity: 1
        source: "qrc:/img/background02.png"
    }

    Column {
        anchors.centerIn: parent

        Text {
            id: text
            text: qsTr("score View")
            color: "red"
        }

        Button {
            id: btnSkipGamePage
            text: qsTr("游戏页面")
            enabled: true
            onClicked: {
                skipPage(Tetris.PageViewType.GameView);
            }
        }
    }
}
