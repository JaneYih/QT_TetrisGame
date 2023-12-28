import QtQuick 2.3


Item {
    id: onebox
    property int edgeLength: 20 //边长
    property real gapRatio: 0.2 //空白间隙与边长的占比
    property bool lightOff: false //颜色亮灭控制开关

    /*注意：渐变（Gradient）的优先级大于普通颜色（color）*/
    property alias boxColor: insideRect.color //颜色
    property alias boxGradient: insideRect.rectGradient //渐变色,若设置为null，则渐变色失效

    width: edgeLength
    height: edgeLength
    opacity: 1
    z:1

    Rectangle {
        id: outsideRect
        anchors.fill: parent
        //color: "snow"
        border.color: "black"
        border.width: 1.2
        opacity: 0.5 //透明度
        z:2
    }

    Rectangle {
        id: insideRect
        anchors.fill: parent
        anchors.margins: parent.width * gapRatio
        border.width: 0
        opacity: 1
        z:3

        property var rectGradient: Gradient {
            GradientStop {
                position: 0
                color: "#ff9a9e"
            }

            GradientStop {
                position: 0.99
                color: "#fad0c4"
            }

            GradientStop {
                position: 1
                color: "#fad0c4"
            }
        }
        color: lightOff ? "darkgrey" : "black"
        gradient: lightOff ? null : rectGradient
    }
}


