import QtQuick 2.9

Rectangle {
    id: homeView
    color: "transparent"
    //border.color: "transparent"
    //border.color: "red"
    //border.width: 1

    Image {
        id: backgroundImage
        anchors.fill: parent
        z: 0
        opacity: 1
        source: "qrc:/img/background.png"
    }

    Text {
        id: text
        anchors.fill: parent
        text: qsTr("login View")
        color: "red"
    }
}
