import QtQuick 2.9
import Yih.Tetris.Business 1.0

Rectangle {
    id: settingView
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
        source: "qrc:/img/background01.png"
    }

    Text {
        id: text
        anchors.centerIn: parent
        text: qsTr("设置页面先不做了")
        font.pointSize: 50
        color: "aliceblue"
    }
}
