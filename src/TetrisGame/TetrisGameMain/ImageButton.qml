import QtQuick 2.0

Item {
    id: imageButton
    z: 1
    opacity: 0.5
    height: 45
    width: 45
    property alias imageSource: imageItem.source
    property alias mouseArea: mouseArea
    property var idleStateOpacity: 0.5

    onIdleStateOpacityChanged: {
        imageButton.opacity = idleStateOpacity;
    }

    Image {
        id: imageItem
        anchors.fill: parent
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                imageButton.opacity = 1;
            }
            onExited: {
                imageButton.opacity = idleStateOpacity;
            }
        }
    }
}
